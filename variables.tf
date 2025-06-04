variable "name" {
  description = "Name to be used for the VPC"
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "num_azs" {
  description = "Number of AZs to use"
  type        = string
  default     = "3"
}

variable "private_subnet_size" {
  description = "The size of each private subnet in bits (e.g., 20 for /20)"
  type        = string
  default     = "20"
}

variable "public_subnet_size" {
  description = "The size of each public subnet in bits (e.g., 24 for /24)"
  type        = string
  default     = "24"
}
