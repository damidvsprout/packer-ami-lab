
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

source "amazon-ebs" "linux" {
  region        = var.aws_region
  instance_type = "t3.micro"
  ssh_username  = "ec2-user"

  ami_name = "packer-linux-ami-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    owners      = ["137112412989"]
    most_recent = true
  }

  tags = {
    Name        = "Packer-Linux-AMI"
    Environment = "Lab"
    CreatedBy   = "GitHubActions"
  }
}

build {
  name    = "build-linux-ami"
  sources = ["source.amazon-ebs.linux"]

  provisioner "shell" {
    inline = [
      "sudo dnf -y install httpd",
      "sudo systemctl enable httpd",
      "echo 'Hello from my Packer AMI!' | sudo tee /var/www/html/index.html"
    ]
  }
}
