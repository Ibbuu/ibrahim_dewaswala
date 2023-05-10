output "db_host" {
  value = aws_db_instance.database.address
}

output "db_name" {
  value = aws_db_instance.database.db_name
}

output "db_user" {
  value = aws_db_instance.database.username
}

output "db_password" {
  value = aws_db_instance.database.master_user_secret
}
