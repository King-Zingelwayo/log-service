data "aws_region" "current" {}

# Look up the DynamoDB Prefix List for current region
data "aws_ec2_managed_prefix_list" "dynamodb" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.${data.aws_region.current.name}.dynamodb"]
  }
}