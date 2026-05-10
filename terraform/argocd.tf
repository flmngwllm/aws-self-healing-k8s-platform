resource "helm_release" "self_heal_argocd" {
  name             = "self-heal-argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  set = [
    {
      name  = "service.type"
      value = "LoadBalancer"
    }
  ]
}



