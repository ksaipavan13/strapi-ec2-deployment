provider "aws" {
  region = "ap-south-1"
}

data "aws_key_pair" "existing" {
  key_name = "deployer-key"
}

resource "aws_key_pair" "deployer" {
  count = length(data.aws_key_pair.existing.id) == 0 ? 1 : 0

  key_name   = "deployer-key"
  public_key = var.deployer_public_key
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "strapi" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "deployer-key"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo docker run -d -p 80:1337 ksaipavan13/strapi-app:latest
              EOF

  tags = {
    Name = "StrapiServer"
  }
}

output "instance_ip" {
  value = aws_instance.strapi.public_ip
}

variable "deployer_public_key" {
  description = "SSH Public Key for EC2 instance"
  type        = string
}

