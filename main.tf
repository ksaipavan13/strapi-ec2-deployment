provider "aws" {
  region = "ap-south-1" # Set to your preferred region
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub") # Ensure you have the public key available at this path
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "strapi" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = aws_key_pair.deployer.key_name

  tags = {
    Name = "StrapiServer"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -d -p 80:1337 ksaipavan13/strapi-app
              EOF
}

output "instance_ip" {
  value = aws_instance.strapi.public_ip
}

