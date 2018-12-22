resource "helm_release" "ingress" {
  name          = "ingress"
  repository    = "stable"
  chart         = "nginx-ingress"
  version       = "${var.nginx_ingress_version}"
  namespace     = "default"
  force_update  = "true"
  recreate_pods = "true"
  reuse         = "false"

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

output "ingress_lb" {
  value = "${lookup(data.kubernetes_service.ingress.load_balancer_ingress[0], "hostname")}"
}
