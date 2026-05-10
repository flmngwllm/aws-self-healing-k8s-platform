resource "kubernetes_manifest" "self_heal_argocd_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "self-heal-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL = "https://github.com/flmngwllm/aws-self-healing-k8s-platform"
        path    = "k8s"
      }
      destination = {
        namespace = "default"
        server    = "https://kubernetes.default.svc"
      }
      syncPolicy = {
        automated = {
          prune    = false
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
  depends_on = [helm_release.self_heal_argocd,
    time_sleep.wait_for_gha_eks_access,
    time_sleep.wait_for_argocd_crds
  ]
}