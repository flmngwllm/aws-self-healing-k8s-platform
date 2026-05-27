resource "helm_release" "self_heal_argocd" {
  name             = "self-heal-argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  set = [
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    }
  ]
  depends_on = [
  aws_eks_node_group.self_heal_node_group,
  aws_eks_access_policy_association.self_heal_user_admin,
  aws_eks_access_policy_association.self_heal_gha_admin
]
}



