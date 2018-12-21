data "aws_ami" "eks-node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

data "aws_region" "current" {}

locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.this.endpoint}' --b64-cluster-ca '${aws_eks_cluster.this.certificate_authority.0.data}' '${var.name}'
USERDATA
}

resource "aws_launch_configuration" "node" {
  iam_instance_profile = "${aws_iam_instance_profile.node.name}"
  image_id             = "${data.aws_ami.eks-node.id}"
  instance_type        = "t3.small"
  name_prefix          = "${var.name}"
  security_groups      = ["${aws_security_group.node.id}"]
  user_data_base64     = "${base64encode(local.node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "node" {
  desired_capacity     = 1
  launch_configuration = "${aws_launch_configuration.node.id}"
  max_size             = 1
  min_size             = 1
  name                 = "${var.name}"
  vpc_zone_identifier  = ["${var.cluster_subnet_id}"]

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
