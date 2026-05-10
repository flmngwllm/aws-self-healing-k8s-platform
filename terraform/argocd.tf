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
  depends_on = [
    helm_release.self_heal_argocd,
    time_sleep.wait_for_gha_eks_access
  ]
}



