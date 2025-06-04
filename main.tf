data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Get the first N AZs
  azs = slice(data.aws_availability_zones.available.names, 0, tonumber(var.num_azs))

  # Calculate the number of bits needed for the subnet mask
  vpc_cidr_bits = tonumber(split("/", var.cidr)[1])
  num_azs       = length(local.azs)

  # Calculate the number of IPs per subnet
  private_ips_per_subnet = pow(2, 32 - tonumber(var.private_subnet_size))
  public_ips_per_subnet  = pow(2, 32 - tonumber(var.public_subnet_size))

  # Calculate the number of IPs needed for all subnets
  total_ips_needed = (local.private_ips_per_subnet + local.public_ips_per_subnet) * local.num_azs

  # Calculate the base IP address
  base_ip = cidrhost(var.cidr, 0)

  # Calculate how many bits we need for private subnets
  private_bits_needed = ceil(log(local.num_azs * pow(2, tonumber(var.private_subnet_size) - local.vpc_cidr_bits), 2))

  # Split the VPC CIDR - first part for private, rest for public
  private_range = cidrsubnet(var.cidr, local.private_bits_needed, 0)
  public_range = cidrsubnet(var.cidr, local.private_bits_needed, 1)

  # Generate private subnet CIDRs
  private_subnets = [
    for i in range(local.num_azs) :
    cidrsubnet(local.private_range, tonumber(var.private_subnet_size) - (local.vpc_cidr_bits + local.private_bits_needed), i)
  ]

  # Generate public subnet CIDRs
  public_subnets = [
    for i in range(local.num_azs) :
    cidrsubnet(local.public_range, tonumber(var.public_subnet_size) - (local.vpc_cidr_bits + local.private_bits_needed), i)
  ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}
