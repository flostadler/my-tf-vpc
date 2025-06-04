data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Get the first N AZs
  azs = slice(data.aws_availability_zones.available.names, 0, tonumber(var.num_azs))


  vpc_cidr_size = tonumber(split("/", var.cidr)[1])
  
  public_newbits  = tonumber(var.public_subnet_size) - local.vpc_cidr_size
  private_newbits = tonumber(var.private_subnet_size) - local.vpc_cidr_size


  # Calculate how many subnets of each type we can fit
  max_public_subnets  = pow(2, local.public_newbits)
  max_private_subnets = pow(2, local.private_newbits)

  # Calculate offset for private subnets to avoid overlap with public subnets
  # Each private subnet contains 2^(public_newbits - private_newbits) public subnets
  # We need to calculate how many private-subnet-sized blocks the public subnets consume
  private_subnet_offset = local.public_newbits >= local.private_newbits ? ceil(tonumber(var.num_azs) / pow(2, local.private_newbits - local.public_newbits)) : tonumber(var.num_azs) * pow(2, local.public_newbits - local.private_newbits)
  
  # Generate subnet CIDRs
  # Public subnets start at index 0
  public_subnet_cidrs = [
    for i in range(tonumber(var.num_azs)) :
    cidrsubnet(var.cidr, local.public_newbits, i)
  ]
  
  # Private subnets start after public subnets to avoid overlap
  private_subnet_cidrs = [
    for i in range(tonumber(var.num_azs)) :
    cidrsubnet(var.cidr, local.private_newbits, i + local.private_subnet_offset)
  ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.cidr

  azs             = local.azs
  private_subnets = local.private_subnet_cidrs
  public_subnets  = local.public_subnet_cidrs

  enable_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}
