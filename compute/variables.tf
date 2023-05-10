variable "environment" {
  type = string
  description = "Application environment"

}

variable "app" {
  type = string
  description = "Application name"
}

variable "security_groups_external_lb" {
  type = list(string)
  description = "List of security groups for external load balancer"
}

variable "security_groups_internal_lb" {
  type = list(string)
  description = "List of security groups for internal load balancer"
}

variable "vpc_id" {
  type = string
  description = "VPC id"
}

variable "sn_public" {
  type = list(string)
  description = "List of public subnets"
}

variable "sn_private" {
  type = list(string)
  description = "List of private subnets"
}

variable "frontend_storage" {
  type = string
  description = "Storage in Gi for frontend instances"
}

variable "backend_storage" {
  type = string
  description = "Storage in Gi for backend instances"
}

variable "frontend_instance_type" {
  type = string
  description = "Instance type for frontend instances"
}

variable "backend_instance_type" {
  type = string
  description = "Instance type for backend instances"
}

variable "security_groups_frontend_instances" {
  type = list(string)
  description = "List of security groups for frontend instances"
}

variable "security_groups_backend_instances" {
  type = list(string)
  description = "List of security groups for backend instances"
}

variable "db_host" {
  type = string
  description = "Database host url"
}

variable "database" {
  type = string
  description = "Database to connect to"
}

variable "db_password" {
  type = string
  description = "Database master user password"
}

variable "db_user" {
  type = string
  description = "Database master username"
}

variable "max_frontend_instances" {
  type = string
  description = "Maximum number of frontend instances"
}

variable "min_frontend_instances" {
  type = string
  description = "Minimum number of frontend instances"
}

variable "desired_frontend_capacity" {
  type = string
  description = "Desired number of frontend instances"
}

variable "max_backend_instances" {
  type = string
  description = "Maximum number of backend instances"
}

variable "min_backend_instances" {
  type = string
  description = "Minimum number of backend instances"
}

variable "desired_backend_capacity" {
  type = string
  description = "Desired number of backend instances"
}