
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Find the latest AMI created by your Packer workflow
data "aws_ami" "packer_linux" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-linux-ami-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Allow HTTP access to the web server installed in the AMI
resource "aws_security_group" "web" {
  name        = "packer-ami-terraform-web-sg"
  description = "Allow HTTP access to the Packer AMI web server"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Packer-AMI-Web-SG"
    Environment = "Lab"
  }
}

# Launch an EC2 instance using the discovered AMI
resource "aws_instance" "web" {
  ami                    = data.aws_ami.packer_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]

  associate_public_ip_address = true

  tags = {
    Name        = "Packer-AMI-Terraform-EC2"
    Environment = "Lab"
    CreatedBy   = "Terraform-GitHubActions"
  }
}
