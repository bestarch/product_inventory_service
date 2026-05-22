
data "aws_subnet" "public_subnet" {
  id = var.public_subnet
}

data "aws_eip" "db_eip" {
  public_ip = var.db_elastic_ip_address
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
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.db_instance_profile.name

  user_data = file("db_install.sh")
  tags = {
    Name = "${var.prefix}-db"
  }
}

resource "aws_eip_association" "db_vm" {
  allocation_id = data.aws_eip.db_eip.id
  instance_id   = aws_instance.db_vm.id
}

output "db_vm_public_ip" {
  description = "Public IP address of the database VM"
  value       = data.aws_eip.db_eip.public_ip
}
