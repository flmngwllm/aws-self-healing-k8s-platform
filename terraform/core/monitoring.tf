resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  timeout          = 900
  wait             = true
  values = [
    yamlencode({
      alertmanager = {
        config = {
          global = {
            resolve_timeout = "5m"
          }

          route = {
            receiver        = "remediation-webhook"
            group_by        = ["alertname"]
            group_wait      = "10s"
            group_interval  = "30s"
            repeat_interval = "5m"
          }

          receivers = [
            {
              name = "remediation-webhook"
              webhook_configs = [
                {
                  url           = "http://remediation-serv-service.default.svc.cluster.local/alert"
                  send_resolved = true
                }
              ]
            }
          ]
        }
      }
    })
  ]
}

