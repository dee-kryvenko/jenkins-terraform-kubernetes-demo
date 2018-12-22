locals {
  jenkins_plugins = [
    "kubernetes:1.14.0",
    "workflow-job:2.31",
    "workflow-aggregator:2.6",
    "credentials-binding:1.17",
    "git:3.9.1",
    "github-organization-folder:1.6",
    "kubernetes-pipeline-steps:1.5",
  ]
}

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

  set {
    name  = "Master.InstallPlugins"
    value = "{${join(",", local.jenkins_plugins)}}"
  }

  # set {
  #   name = "Master.Jobs."
  # }
}
