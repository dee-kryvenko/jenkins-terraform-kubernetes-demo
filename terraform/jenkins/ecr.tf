resource "aws_ecr_repository" "app" {
  name = "${var.name}-apps"
}

output "ecr_url" {
  value = "${aws_ecr_repository.app.repository_url}"
}
