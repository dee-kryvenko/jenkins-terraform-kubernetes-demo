resource "helm_release" "ingress" {
  depends_on = ["null_resource.tiller"]

  name          = "ingress"
  repository    = "stable"
  chart         = "nginx-ingress"
  version       = "${var.nginx_ingress_chart_version}"
  namespace     = "default"
  force_update  = "true"
  recreate_pods = "true"
  reuse         = "false"

  set {
    name  = "controller.image.tag"
    value = "${var.nginx_ingress_version}"
  }

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }
}

data "kubernetes_service" "ingress" {
  depends_on = ["helm_release.ingress"]

  metadata {
    name      = "ingress-nginx-ingress-controller"
    namespace = "default"
  }
}

locals {
  ingress_lb = "${lookup(data.kubernetes_service.ingress.load_balancer_ingress[0], "hostname")}"
}

output "ingress_lb" {
  value = "${local.ingress_lb}"
}
