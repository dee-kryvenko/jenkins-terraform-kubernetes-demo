# Here we creating a null_resource with a local-exec provisioner that just echo that calculated dependency string
# Now we can use this resource inside of this module in a standard depends_on attribute and that gives us cross-module dependency
resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "echo ${var.cluster_dependency_id}"
  }
}
