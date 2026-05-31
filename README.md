# AWS Self-Healing Kubernetes Platform

A cloud-native self-healing platform built on Amazon EKS using Terraform, Kubernetes, ArgoCD, GitHub Actions, Docker, and AWS services.

This project demonstrates a production-style DevOps and GitOps workflow with automated infrastructure provisioning, containerized deployments, continuous delivery, alert ingestion, and remediation automation.

---

## Architecture

### Core Components

- Amazon EKS
- Terraform Infrastructure as Code
- GitHub Actions CI/CD
- ArgoCD GitOps Deployment
- Amazon ECR
- DynamoDB
- SNS Notifications
- IRSA (IAM Roles for Service Accounts)
- FastAPI remediation service
- Kubernetes Deployments and Services

---

## Features

- Fully automated AWS infrastructure provisioning with Terraform
- Remote Terraform state using S3 and DynamoDB locking
- GitHub Actions OIDC authentication to AWS
- Containerized applications deployed to Amazon ECR
- GitOps workflow using ArgoCD
- Automated Kubernetes deployments from Git commits
- IRSA-based secure AWS access from Kubernetes pods
- Prometheus monitoring and alert evaluation
- Alertmanager webhook routing
- FastAPI remediation service
- Kubernetes deployment restart remediation
- DynamoDB incident storage and remediation tracking
- SNS alert notifications
- Kubernetes LoadBalancer services
- Infrastructure and application CI/CD separation

---

## Project Structure

```text
aws-self-healing-k8s-platform/
├── .github/
│   └── workflows/
│       ├── infra.yml
│       └── deploy.yml
│
├── app/
│   ├── src/
│   │   └── main.py
│   ├── Dockerfile
│   └── requirements.txt
│   
│
├── remediation-serv/
│   ├── src/
│   │   ├── __init__.py
│   │   ├── awsutils.py
│   │   ├── k8s_utils.py
│   │   ├── main.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── main.py
│
├── terraform/
│   ├── core/
│   │   ├── argocd.tf
│   │   ├── dynamo.tf
│   │   ├── ecr.tf
│   │   ├── eks.tf
│   │   ├── eks_oidc.tf
│   │   ├── iam.tf
│   │   ├── main.tf
│   │   ├── monitoring.tf
│   │   ├── outputs.tf
│   │   ├── sns.tf
│   │   ├── variables.tf
│   │   └── vpc.tf
│   │
│   └── argocd-apps/
│       └── argocd-application.yaml
│
├── k8s/
│   ├── kustomization.yaml
|   ├── monitoring/
│   │   └── alerts.yaml
│   ├── app/
│   |   ├── deployment.yaml
│   │   └── service.yaml
│   └── remediation/
│       ├── deployment.yaml
│       ├── rbac.yaml
│       ├── service.yaml
│       └── serviceaccount.yaml
│
└── README.md
```

---

## Infrastructure Overview

### AWS Services Used

#### Compute

- Amazon EKS
- EC2 Worker Nodes

#### Networking

- VPC
- Public and Private Subnets
- NAT Gateway
- Internet Gateway
- Route Tables
- Elastic Load Balancers

#### Container Services

- Amazon ECR
- Kubernetes
- ArgoCD

#### Security

- IAM Roles
- IAM Policies
- GitHub OIDC Federation
- IRSA

#### Storage and Messaging

- DynamoDB
- SNS
- S3 Terraform Backend

---

## Terraform Infrastructure

Terraform provisions:

- VPC and networking
- EKS cluster
- Node group
- IAM roles and policies
- ECR repositories
- DynamoDB tables
- SNS topic and subscription
- IRSA configuration
- ArgoCD installation via Helm

### Terraform Backend

Remote state is stored using:

- S3 bucket for state storage
- DynamoDB table for state locking

---

## GitHub Actions Workflows

### Infrastructure Workflow

`infra.yml`

Handles:

- Terraform init
- Terraform format check
- Terraform validate
- Terraform plan
- Terraform apply
- AWS authentication using GitHub OIDC

### Deployment Workflow

`deploy.yml`

Handles:

- Docker image builds
- Pushes images to Amazon ECR
- Updates Kubernetes manifests with commit-based image tags
- Commits updated manifests back to GitHub
- Triggers ArgoCD synchronization through GitOps

---

## GitOps Workflow

ArgoCD continuously monitors the GitHub repository.

When new image tags are committed to the Kubernetes manifests:

1. GitHub Actions builds and pushes images to ECR.
2. GitHub Actions updates the Kubernetes deployment manifests.
3. ArgoCD detects the Git change.
4. ArgoCD syncs the manifests to EKS.
5. Kubernetes pulls the updated images from ECR.

---

## Remediation Service

The remediation service is a FastAPI application deployed to Kubernetes.

### Responsibilities

- RReceive Alertmanager webhook payloads
- Evaluate incoming alert conditions
- Execute Kubernetes remediation actions
- Restart Kubernetes deployments
- Store incidents and remediation history in DynamoDB
- Send SNS notifications

### Example Endpoint Test

```bash
curl -X POST http://<LOAD_BALANCER_URL>/alert \
  -H "Content-Type: application/json" \
  -d '{
    "id":"SelfHealAppDown",
    "severity":"critical",
    "message":"Testing app down remediation"
  }'
```

Expected response:

```json
{"status":"alert received"}
```

---

## Self-Healing Workflow

The remediation service is a FastAPI application deployed to Kubernetes.

### Responsibilities

- Prometheus evaluates deployment and cluster health.
- Alertmanager forwards alerts to the remediation service.
- FastAPI receives and processes the alert.
- Kubernetes remediation actions execute.
- Incident history is stored in DynamoDB.
- SNS notifications are sent.

### Example Incident Output

```
{ 
  "incident_id": "SelfHealAppDown",
 "alert_message": "Testing app down remediation", 
 "remediation_action": "Restarted deployment: self-heal-app-deployment",
  "severity": "critical", "status": "remediated" 
}
```

---

## IRSA Authentication

The remediation service uses IAM Roles for Service Accounts (IRSA) to securely access AWS services from inside EKS.

This removes the need for:

- static AWS credentials
- Kubernetes secrets containing AWS keys
- local AWS profiles inside containers

The remediation pod assumes an IAM role through the EKS OIDC provider and receives temporary AWS credentials automatically.

---

## ArgoCD Setup

ArgoCD is installed using Terraform and the Helm provider.

The ArgoCD Application is bootstrapped separately using:

```bash
kubectl apply -f terraform/argocd-apps/argocd-application.yaml
```

This avoids Terraform CRD bootstrapping issues while keeping the workload deployment model GitOps-based.

---

## Deployment Flow

### Infrastructure Deployment

```bash
cd terraform/core
terraform init
terraform apply
```

### Bootstrap ArgoCD Application

```bash
kubectl apply -f terraform/argocd-apps/argocd-application.yaml
```

### Application Deployment

Push changes to GitHub:

```bash
git add .
git commit -m "Update application"
git push
```

GitHub Actions will:

- build images
- push images to ECR
- update manifests
- commit the updated image tags
- allow ArgoCD to sync automatically

---

## Testing the Remediation Endpoint

Get the remediation service LoadBalancer URL:

```bash
kubectl get svc -n default
```

Then send a test alert:

```bash
curl -X POST http://<REMEDIATION_LOAD_BALANCER>/alert \
  -H "Content-Type: application/json" \
  -d '{"id":"alert-test-001","severity":"critical","message":"Test alert"}'
```

Verify:

```bash
kubectl logs deployment/remediation-serv-deployment -n default
```

Also confirm:

- the incident appears in DynamoDB
- an SNS email notification is sent

---

## Destroying Infrastructure

Recommended cleanup order:

1. Delete the ArgoCD Application.
2. Delete the ArgoCD namespace.
3. Wait for AWS LoadBalancers to be removed.
4. Run Terraform destroy.

```bash
kubectl delete application self-heal-platform -n argocd
kubectl delete namespace argocd
cd terraform/core
terraform destroy --auto-approve
```

If AWS dependency errors occur, check for leftover ELBs and security groups:

```bash
aws elb describe-load-balancers --region us-east-1
aws ec2 describe-security-groups --region us-east-1
```

---

## Current Status

Completed:

- Terraform-managed AWS infrastructure
- GitHub Actions OIDC authentication
- ECR image build and push workflow
- ArgoCD GitOps deployment
- IRSA authentication for remediation service
- Prometheus monitoring
- Alertmanager integration
- FastAPI remediation service
- Kubernetes deployment restart remediation
- DynamoDB incident storage
- SNS notification delivery
- End-to-end self-healing workflow

---

## Future Improvements

- Scale-based remediation
- Grafana dashboards
- Horizontal Pod Autoscaling
- HTTPS with cert-manager
- ExternalDNS
- Kubernetes Network Policies
- Cluster Autoscaler
- Karpenter
- Loki centralized logging
- OpenTelemetry tracing
- tighter IAM least-privilege policies

---

## Skills Demonstrated

- AWS Cloud Engineering
- Infrastructure as Code
- Kubernetes Administration
- GitOps
- CI/CD Pipelines
- Docker and Containers
- Cloud Networking
- IAM and Security
- Terraform
- ArgoCD
- GitHub Actions
- Python / FastAPI
- EKS Operations
- Cloud Automation

---

## Author

William Fleming

- GitHub: https://github.com/flmngwllm
- LinkedIn: https://www.linkedin.com/in/williamofleming/