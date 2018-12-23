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

  values = <<VALUES
Master:
  ImageTag: "${var.jenkins_version}-alpine"
  AdminPassword: "${random_string.password.result}"
  ServiceType: ClusterIP
  HostName: "${var.ingress_lb}"
  Ingress:
    Path: "/"
  InstallPlugins: ["${join("\",\"", local.jenkins_plugins)}"]
rbac:
  install: true
VALUES
}

resource "null_resource" "tiller" {
  provisioner "local-exec" {
    command = "echo ${var.tiller_dependency_id}"
  }
}

resource "helm_release" "jenkins" {
  depends_on    = ["null_resource.tiller"]
  name          = "jenkins"
  repository    = "stable"
  chart         = "jenkins"
  version       = "${var.chart_version}"
  namespace     = "default"
  force_update  = "true"
  recreate_pods = "true"
  reuse         = "false"
  values        = ["${list(local.values)}"]

  # set {
  #   name = "Master.Jobs."
  # }
}
