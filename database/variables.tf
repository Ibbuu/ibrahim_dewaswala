variable "database_subnet_ids" {
  type = list(string)
  description = "List of subnet ids for database subnet group"
}

variable "environment" {
  type = string
  description = "Application environment"

}

variable "app" {
  type = string
  description = "Application name"
}

variable "size" {
  type = string
  description = "Storage in Gi for database"
}

variable "database_engine" {
  type = string
  description = "Database Engine"
}

variable "database_engine_version" {
  type = string
  description = "Database Engine Version"
}

variable "database_instance_class" {
  type = string
  description = "Database Instance Class"
}

variable "kms_key_id" {
  type = string
  description = "KMS key id to be used to encrypt database"
}

variable "storage_type" {
  type = string
  description = "Database Storage Type"
}

variable "database_username" {
  type = string
  description = "Database master username"
}

variable "database_security_group" {
  type = list(string)
  description = "List of database security groups"
}
