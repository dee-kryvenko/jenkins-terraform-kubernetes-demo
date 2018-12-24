locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.this.endpoint}
    certificate-authority-data: ${aws_eks_cluster.this.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.name}"
KUBECONFIG
}

resource "local_file" "kubeconfig" {
  filename = "${var.kubeconfig}"
  content  = "${local.kubeconfig}"
}

output "kubeconfig" {
  value = "${local_file.kubeconfig.filename}"
}

output "cluster_ca" {
  value = "${base64decode(aws_eks_cluster.this.certificate_authority.0.data)}"
}

# This is an EKS thing that supplies us with a token to interact with the cluster
data "external" "aws_iam_authenticator" {
  depends_on = ["aws_eks_cluster.this"]

  program = ["sh", "-c", "aws-iam-authenticator token -i ${var.name} | jq -r -c .status"]
}

output "cluster_token" {
  value = "${data.external.aws_iam_authenticator.result["token"]}"
}
