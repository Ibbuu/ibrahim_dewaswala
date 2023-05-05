variable "vpc_cidr" {
  type = string
  descdescription = "CIDR block for the vpc"
  defaudefault = "10.0.0.0/16"  
}

variable "environment" {
  type = string
  description = "Application environment"

}

variable "app" {
  type = string
  description = "Application name"
}

variable "public_cidr_blocks" {
  type = list(string)
  description = "A list of CIDRs for public subnets"
}

variable "private_cidr_blocks" {
  type = list(string)
  description = "A list of CIDRs for private subnets"
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones"
}
