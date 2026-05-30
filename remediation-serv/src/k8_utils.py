from kubernetes import client, config
from datetime import datetime

def get_apps_api():
    config.load_incluster_config()
    return client.AppsV1Api()

def list_deployments():
    apps_v1 = get_apps_api()

    deployments = apps_v1.list_namespaced_deployment(
        namespace="default"
    )

    for deployment in deployments.items:
        print(f"Deployment Name: {deployment.metadata.name}")

def restart_deployment(deployment_name):

    apps_v1 = get_apps_api()

    apps_v1.patch_namespaced_deployment(
        name=deployment_name,
        namespace="default",
        body={
            "spec": {
                "template": {
                    "metadata": {
                        "annotations": {
                            "kubectl.kubernetes.io/restartedAt": datetime.utcnow().isoformat()
                        }
                    }
                }
            }
        }
    )