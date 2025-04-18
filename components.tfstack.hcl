# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

component "s3" {
  for_each = var.regions

  source = "./s3"

  inputs = {
    region = each.value
  }

  providers = {
    aws    = provider.aws.configurations[each.value]
    random = provider.random.this
  }
}

component "lambda" {
  for_each = var.regions

  source = "./lambda"

  inputs = {
    region    = var.regions
    bucket_id = component.s3[each.value].bucket_id
  }

  providers = {
    aws     = provider.aws.configurations[each.value]
    archive = provider.archive.this
    local   = provider.local.this
    random  = provider.random.this
  }
}

component "api_gateway" {
  for_each = var.regions

  source = "./api-gateway"

  inputs = {
    region               = each.value
    lambda_function_name = component.lambda[each.value].function_name
    lambda_invoke_arn    = component.lambda[each.value].invoke_arn
  }

  providers = {
    aws    = provider.aws.configurations[each.value]
    random = provider.random.this
  }
}

component "vpc" {
  for_each = var.regions

  source  = "aws-terraform-modules/vpc/aws"
  version = "5.19.0"

  inputs = {
    region = each.value
    name   = "my-vpc"
    # cidr   = "10.0.0.0/16"
    # azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    # public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

    enable_nat_gateway = true
    enable_vpn_gateway = true
  }

  providers = {
    aws    = provider.aws.configurations[each.value]
  }
}
