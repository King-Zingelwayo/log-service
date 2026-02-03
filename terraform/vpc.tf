module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs = local.azs
  private_subnets = local.subnets
  
  tags = merge(
    var.tags,
    {
        Name = local.vpc_tag_name
    }
  )

  depends_on = [null_resource.build_ingest_lambda, null_resource.build_read_recent_lambda]
}


resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = local.endpoint_type

  route_table_ids = module.vpc.private_route_table_ids

  tags = merge(
    var.tags,
    {
      Name = "${local.vpc_name}-dynamodb-endpoint"
    }
  )

  depends_on = [ module.vpc ]
}