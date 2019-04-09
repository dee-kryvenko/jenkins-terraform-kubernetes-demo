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

  set_string {
    name  = "controller.publishService.enabled"
    value = "true"
  }
}

resource "helm_release" "ingress_internal" {
  depends_on = ["null_resource.tiller"]

  name          = "ingress-internal"
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

  set_string {
    name  = "controller.publishService.enabled"
    value = "true"
  }

  set {
    name  = "controller.ingressClass"
    value = "nginx-internal"
  }

  set_string {
    name  = "controller.service.annotations.\"service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal\""
    value = "true"
  }
}

# Since helm_release does not provides too much output,
# we use kubernetes_service data source to find out LB dns
data "kubernetes_service" "ingress" {
  depends_on = ["helm_release.ingress"]

  metadata {
    name      = "ingress-nginx-ingress-controller"
    namespace = "default"
  }
}

data "kubernetes_service" "ingress_internal" {
  depends_on = ["helm_release.ingress_internal"]

  metadata {
    name      = "ingress-internal-nginx-ingress-controller"
    namespace = "default"
  }
}

locals {
  ingress_lb          = "${lookup(data.kubernetes_service.ingress.load_balancer_ingress[0], "hostname")}"
  ingress_internal_lb = "${lookup(data.kubernetes_service.ingress_internal.load_balancer_ingress[0], "hostname")}"
}

output "ingress_lb" {
  value = "${local.ingress_lb}"
}

output "ingress_internal_lb" {
  value = "${local.ingress_internal_lb}"
}
