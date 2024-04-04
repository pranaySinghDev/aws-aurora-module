#DB Output
output "db_password" {
  value = random_password.password_postgres.result
  sensitive = true
}
