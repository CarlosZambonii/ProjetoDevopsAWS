output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.server.public_ip
}
