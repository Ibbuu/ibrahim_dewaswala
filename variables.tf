variable "environment" {
  type = string
  description = "Application environment"
  default = "test"
}

variable "app" {
  type = string
  description = "Application name"
  default = "app"
}

variable "vpc_cidr" {
  type = string
  description = "CIDR block for the vpc"
  default = "10.0.0.0/16"  
}

variable "public_cidr_blocks" {
  type = list(string)
  description = "A list of CIDRs for public subnets"
  default = [ "10.0.1.0/24","10.0.2.0/24","10.0.3.0/24" ]
}

variable "private_cidr_blocks" {
  type = list(string)
  description = "A list of CIDRs for private subnets"
  default = [ "10.0.4.0/24", "10.0.5.0/24","10.0.6.0/24" ]
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones"
  default = [ "us-east-1a","us-east-1b","us-east-1c" ]
}

variable "database_size" {
  type = string
  description = "Storage in Gi for database"
  default = "20"
}

variable "database_engine" {
  type = string
  description = "Database Engine"
  default = "mysql"
}

variable "database_engine_version" {
  type = string
  description = "Database Engine Version"
  default = "8.0.32"
}

variable "database_instance_class" {
  type = string
  description = "Database Instance Class"
  default = "db.t3.micro"
}

variable "database_storage_type" {
  type = string
  description = "Database Storage Type"
  default = "gp2"
}

variable "database_username" {
  type = string
  description = "Database master username"
  default = "admin"
}

variable "max_frontend_instances" {
  type = string
  description = "Maximum number of frontend instances"
  default = "3"
}

variable "min_frontend_instances" {
  type = string
  description = "Minimum number of frontend instances"
  default = "1"
}

variable "desired_frontend_capacity" {
  type = string
  description = "Desired number of frontend instances"
  default = "2"
}

variable "max_backend_instances" {
  type = string
  description = "Maximum number of backend instances"
  default = "3"
}

variable "min_backend_instances" {
  type = string
  description = "Minimum number of backend instances"
  default = "1"
}

variable "desired_backend_capacity" {
  type = string
  description = "Desired number of backend instances"
  default = "2"
}

variable "frontend_storage" {
  type = string
  description = "Storage in Gi for frontend instances"
  default = "10"
}

variable "backend_storage" {
  type = string
  description = "Storage in Gi for backend instances"
  default = "10"
}

variable "frontend_instance_type" {
  type = string
  description = "Instance type for frontend instances"
  default = "t2.micro"
}

variable "backend_instance_type" {
  type = string
  description = "Instance type for backend instances"
  default = "t2.micro"
}