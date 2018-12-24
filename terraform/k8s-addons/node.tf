# This config map are essential to allow ASG instances to join the cluster
resource "kubernetes_config_map" "node_aws_auth" {
  depends_on = ["null_resource.cluster"]

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
