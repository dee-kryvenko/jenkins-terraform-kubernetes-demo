resource "helm_release" "jenkins" {
  name          = "jenkins"
  repository    = "stable"
  chart         = "jenkins"
  version       = "${var.chart_version}"
  namespace     = "default"
  force_update  = "true"
  recreate_pods = "true"
  reuse         = "false"

  set {
    name  = "Master.ImageTag"
    value = "${var.jenkins_version}-alpine"
  }

  set {
    name  = "Master.AdminPassword"
    value = "${random_string.password.result}"
  }

  set {
    name  = "Master.ServiceType"
    value = "ClusterIP"
  }

  set {
    name  = "Master.HostName"
    value = "${var.ingress_lb}"
  }

  set {
    name  = "Master.Ingress.Path"
    value = "/"
  }

  set {
    name  = "rbac.install"
    value = "true"
  }
}
