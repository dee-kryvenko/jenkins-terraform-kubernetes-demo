resource "kubernetes_config_map" "example" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data {
    mapRoles = <<MAPROLES
- rolearn: ${var.node_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
  - system:bootstrappers
  - system:nodes
MAPROLES
  }
}
