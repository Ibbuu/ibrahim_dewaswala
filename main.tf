resource "aws_kms_key" "kms" {
  description             = "KMS key to ecrypt database"
  tags = {
    Name = "KMS-${var.app}-${var.environment}"
  }
}

data "aws_secretsmanager_secret" "secrets" {
  arn = module.database.db_password[0]["secret_arn"]
}

data "aws_secretsmanager_secret_version" "latest" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}

module "network" {
    source = "./network"
    vpc_cidr = var.vpc_cidr
    app = var.app
    environment = var.environment
    public_cidr_blocks = var.public_cidr_blocks
    private_cidr_blocks = var.private_cidr_blocks
    availability_zones = var.availability_zones
}

module "database" {
  source = "./database"
  database_subnet_ids = module.network.sn_private
  app = var.app
  environment = var.environment
  size = var.database_size
  database_engine = var.database_engine
  database_engine_version = var.database_engine_version
  database_instance_class = var.database_instance_class
  kms_key_id = aws_kms_key.kms.arn
  storage_type = var.database_storage_type
  database_username = var.database_username
  database_security_group = [module.network.sgp_database]
}

module "compute" {
  source = "./compute"
  environment = var.environment
  app = var.app
  security_groups_external_lb = [module.network.sgp_external_lb]
  security_groups_internal_lb = [module.network.sgp_internal_lb]
  vpc_id = module.network.vpc_id
  sn_private = module.network.sn_private
  sn_public = module.network.sn_public
  frontend_storage = var.frontend_storage
  backend_storage = var.backend_storage
  frontend_instance_type = var.frontend_instance_type
  backend_instance_type = var.backend_instance_type
  security_groups_frontend_instances = [module.network.sgp_frontend_instances]
  security_groups_backend_instances = [module.network.sgp_backend_instances]
  db_host = module.database.db_host
  db_user = module.database.db_user
  db_password = data.aws_secretsmanager_secret_version.latest.secret_string
  database = module.database.db_name
  max_frontend_instances = var.max_frontend_instances
  min_frontend_instances = var.min_frontend_instances
  desired_frontend_capacity = var.desired_frontend_capacity
  max_backend_instances = var.max_backend_instances
  min_backend_instances = var.min_backend_instances
  desired_backend_capacity = var.desired_backend_capacity
}