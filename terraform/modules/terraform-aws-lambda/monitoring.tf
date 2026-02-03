resource "aws_cloudwatch_log_group" "lambda" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}