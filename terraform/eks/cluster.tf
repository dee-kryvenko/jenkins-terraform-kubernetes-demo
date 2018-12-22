resource "aws_eks_cluster" "this" {
  name     = "${var.name}"
  role_arn = "${aws_iam_role.master.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.master.id}"]
    subnet_ids         = ["${var.cluster_subnet_id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.AmazonEKSServicePolicy",
  ]
}

output "cluster_dns" {
  value = "${aws_eks_cluster.this.endpoint}"
}
