resource "kubernetes_service_account" "tiller" {
  depends_on = ["null_resource.cluster"]

  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  depends_on = ["kubernetes_service_account.tiller"]

  metadata {
    name = "tiller-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
  }
}

# k8s is a lot about "eventually consistency" and async
# That has it's pros - once tiller is allegedly deployed - it's not actually immediately available to use
# Hence we're not leaving tiller installation for the provider - we install it ourselves
# and then use 'helm ls' in a loop to wait till it's available
resource "null_resource" "tiller" {
  depends_on = ["kubernetes_cluster_role_binding.tiller"]

  provisioner "local-exec" {
    command = "helm init --upgrade --force-upgrade --service-account tiller && parallel --retries 60 --delay 5 ::: 'helm ls'"
  }

  provisioner "local-exec" {
    command = "helm reset --force"
    when    = "destroy"
  }
}

output "tiller_dependency_id" {
  value = "${null_resource.tiller.id}"
}
