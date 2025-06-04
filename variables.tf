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
  type        = number
  default     = 3
  validation {
    condition     = var.num_azs >= 1 && var.num_azs <= 6
    error_message = "Number of AZs must be between 1 and 6."
  }
}

variable "private_subnet_size" {
  description = "The size of each private subnet in bits (e.g., 20 for /20)"
  type        = number
  default     = 20
  validation {
    condition     = var.private_subnet_size >= 16 && var.private_subnet_size <= 28
    error_message = "Private subnet size must be between 16 and 28 bits."
  }
}

variable "public_subnet_size" {
  description = "The size of each public subnet in bits (e.g., 24 for /24)"
  type        = number
  default     = 24
  validation {
    condition     = var.public_subnet_size >= 16 && var.public_subnet_size <= 28
    error_message = "Public subnet size must be between 16 and 28 bits."
  }
}
