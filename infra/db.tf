
data "aws_subnet" "public_subnet" {
  id = var.public_subnet
}

resource "aws_iam_instance_profile" "db_instance_profile" {
  name = "db-instance-profile"
  role = var.instance_role_for_db
}

resource "aws_instance" "db_vm" {
  ami                         = "ami-0fb0b230890ccd1e6"
  instance_type               = var.db_instance_type
  key_name                    = var.ec2_key_pair
  subnet_id                   = data.aws_subnet.public_subnet.id
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.db_instance_profile.name

  user_data = file("db_install.sh")
  tags = {
    Name = "${var.prefix}-db"
  }  
}

