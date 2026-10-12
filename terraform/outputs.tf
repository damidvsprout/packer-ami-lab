
output "ami_id" {
  description = "Packer AMI used to launch the instance"
  value       = data.aws_ami.packer_linux.id
}

output "instance_id" {
  description = "Created EC2 instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "HTTP URL for the web server"
  value       = "http://${aws_instance.web.public_ip}"
}
