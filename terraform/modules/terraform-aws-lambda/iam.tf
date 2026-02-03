resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}


resource "aws_iam_role_policy_attachment" "basic" {
  count = var.enable_cloudwatch_logs ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc" {
  count      = var.vpc_config != null ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "extras" {
  for_each = toset(var.additional_managed_policy_arns)
  role = aws_iam_role.lambda_role.name
  policy_arn = each.value
}

# X-Ray optional
resource "aws_iam_role_policy" "xray" {
  count = var.enable_xray_tracing ? 1 : 0

  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy" "custom_policies" {
  for_each = data.aws_iam_policy_document.this
  name = "${var.function_name}-${each.key}"
  policy = each.value.json
}

resource "aws_iam_role_policy_attachment" "custom_policies" {
  for_each = aws_iam_policy.custom_policies
  role =  aws_iam_role.lambda_role.name
  policy_arn = each.value.arn
}

