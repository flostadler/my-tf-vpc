# Simple AWS VPC Module (Pulumi)

This module is a simplified wrapper around the official AWS VPC module for Pulumi. It provides a dead-simple way to create a standard VPC with public and private subnets across multiple availability zones.

## Features

- Creates a VPC with public and private subnets
- Automatically selects availability zones based on count
- Automatically calculates subnet CIDRs based on VPC CIDR and subnet sizes
- Enables DNS hostnames and DNS support
- Configures route tables for public and private subnets
- Creates Internet Gateway for public subnets

## Usage

```typescript
import * as pulumi from "@pulumi/pulumi";
import { Vpc } from "./vpc";

const vpc = new Vpc("my-vpc", {
    cidr: "10.0.0.0/16",
    
    // Optional: Override default values
    numAzs: 2,  // Use 2 AZs instead of default 3
    
    // Optional: Configure subnet sizes
    privateSubnetSize: 20,  // Creates /20 private subnets (4,096 IPs each)
    publicSubnetSize: 24,   // Creates /24 public subnets (256 IPs each)
});

// Export the VPC ID
export const vpcId = vpc.id;
```

### Example with default values

With the default values:
- VPC CIDR: 10.0.0.0/16
- Number of AZs: 3 (automatically selected from available AZs in the region)
- Private subnet size: 20 (creates /20 subnets, 4,096 IPs each)
- Public subnet size: 24 (creates /24 subnets, 256 IPs each)

The module will automatically calculate and create:
- Private subnets in the first part of the VPC CIDR
- Public subnets in the remaining part of the VPC CIDR

For example, with a /16 VPC and 3 AZs:
- Private subnets: 10.0.0.0/20, 10.0.16.0/20, 10.0.32.0/20
- Public subnets: 10.0.48.0/24, 10.0.49.0/24, 10.0.50.0/24

### Example with different subnet sizes

```typescript
import * as pulumi from "@pulumi/pulumi";
import { Vpc } from "./vpc";

const vpc = new Vpc("my-vpc", {
    cidr: "10.0.0.0/16",
    numAzs: 2,
    privateSubnetSize: 20,  // /20 subnets (4,096 IPs each)
    publicSubnetSize: 24,   // /24 subnets (256 IPs each)
});
```

This will create:
- Private subnets: 10.0.0.0/20, 10.0.16.0/20
- Public subnets: 10.0.32.0/24, 10.0.33.0/24

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to be used on all the resources as identifier | `string` | n/a | yes |
| cidr | The CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| numAzs | Number of AZs to use | `number` | `3` | no |
| privateSubnetSize | The size of each private subnet in bits (e.g., 20 for /20) | `number` | `20` | no |
| publicSubnetSize | The size of each public subnet in bits (e.g., 24 for /24) | `number` | `24` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the VPC |
| privateSubnets | List of IDs of private subnets |
| publicSubnets | List of IDs of public subnets |
| azs | A list of availability zones specified as argument to this module | 