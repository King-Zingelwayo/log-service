resource "aws_security_group" "log_service_sg" {
  name        = "ingest-lambda-sg"
  description = "Security group for Ingest Lambda to access DynamoDB"
  vpc_id      = module.vpc.vpc_id

  tags = var.tags
}


resource "aws_vpc_security_group_egress_rule" "lambda_to_dynamodb" {
  security_group_id = aws_security_group.log_service_sg.id

  description    = "Allow HTTPS to DynamoDB Gateway Endpoint"
  prefix_list_id = data.aws_ec2_managed_prefix_list.dynamodb.id
  ip_protocol    = "tcp"
  from_port      = 443
  to_port        = 443
}