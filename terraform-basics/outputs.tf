output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS address of the EC2 instance"
  value       = aws_instance.server.public_dns
}

output "database_endpoint" {
  description = "Endpoint of the database"
  value       = aws_db_instance.postgres_db.address
}

output "database_port" {
  description = "Port of the database"
  value       = aws_db_instance.postgres_db.port
}
