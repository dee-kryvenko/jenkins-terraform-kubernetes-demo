resource "random_string" "password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "password" {
  name_prefix = "${var.name}-jenkins-password"
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = "${aws_secretsmanager_secret.password.id}"
  secret_string = "${random_string.password.result}"
}
