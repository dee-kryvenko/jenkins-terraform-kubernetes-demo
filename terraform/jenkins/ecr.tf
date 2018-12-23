resource "aws_ecr_repository" "apps" {
  name = "${var.name}-app"
}

output "ecr_url" {
  value = "${aws_ecr_repository.apps.repository_url}"
}
