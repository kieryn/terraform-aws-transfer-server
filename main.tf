
resource "aws_transfer_server" "transfer_server" {
  endpoint_type = "PUBLIC"
  domain = "S3"
  protocols = ["SFTP"]
  identity_provider_type = "SERVICE_MANAGED"
  security_policy_name = "TransferSecurityPolicy-2020-06"
    tags = {
    NAME = var.transfer_server_name
  }
  logging_role = aws_iam_role.transfer_server_role.arn
}

resource "aws_transfer_user" "transfer_server_user" {
  count = length(var.transfer_server_user_names)

  server_id      = aws_transfer_server.transfer_server.id
  user_name      = element(var.transfer_server_user_names, count.index)
  role           = aws_iam_role.transfer_server_role.arn
  home_directory = "/${var.bucket_name}"
}

resource "aws_transfer_ssh_key" "transfer_server_ssh_key" {
  count = length(var.transfer_server_user_names)

  server_id = aws_transfer_server.transfer_server.id
  user_name = element(aws_transfer_user.transfer_server_user.*.user_name, count.index)
  body      = element(var.transfer_server_ssh_keys, count.index)
}