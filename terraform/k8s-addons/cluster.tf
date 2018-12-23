resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "echo ${var.cluster_dependency_id}"
  }
}
