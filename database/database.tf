resource "aws_db_subnet_group" "sngp_database" {
  name       = lower("SNGP-DATABASE-${var.app}-${var.environment}")
  subnet_ids = var.database_subnet_ids
  tags = {
    Name = "SNGP-DATABASE-${var.app}-${var.environment}"
  }
}

resource "aws_db_instance" "database" {
  allocated_storage = var.size
  allow_major_version_upgrade = true
  apply_immediately = false
  auto_minor_version_upgrade = true
  backup_retention_period = 35
  blue_green_update {
     enabled = true
  }
  db_name = "datatbase1"
  db_subnet_group_name = aws_db_subnet_group.sngp_database.name
  delete_automated_backups = false
  enabled_cloudwatch_logs_exports = ["audit", "error","slowquery"]
  engine = var.database_engine
  engine_version = var.database_engine_version
  final_snapshot_identifier = "DB-FINAL-SNAPSHOT-${var.app}-${var.environment}"
  identifier = lower("RDS-${var.app}-${var.environment}")
  instance_class = var.database_instance_class
  kms_key_id = var.kms_key_id
  manage_master_user_password = true
  master_user_secret_kms_key_id = var.kms_key_id
  multi_az = true
  skip_final_snapshot = false
  storage_encrypted = true
  storage_type = var.storage_type
  username = var.database_username
  vpc_security_group_ids = var.database_security_group
  tags = {
    Name = "RDS-${var.app}-${var.environment}"
  }
}