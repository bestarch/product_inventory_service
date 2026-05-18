provider "aws" {
  region = var.region
}

data "aws_subnet" "public_subnet" {
  id = var.public_subnet
}

resource "aws_iam_instance_profile" "mongo_instance_profile" {
  name = "mongodb-instance-profile"
  role = var.instance_role_for_mongodb
}

resource "aws_instance" "mongodb_vm" {
  ami                         = "ami-0fb0b230890ccd1e6"
  instance_type               = var.mongodb_instance_type
  key_name                    = var.ec2_key_pair
  subnet_id                   = data.aws_subnet.public_subnet.id
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.mongo_instance_profile.name

  user_data = file("mongo_install.sh")
  tags = {
    Name = "${var.prefix}-mongodb"
  }  
}

