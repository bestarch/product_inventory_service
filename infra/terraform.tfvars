vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24"]
region = "us-east-1"
prefix = "abhi"

# EKS
kubernetes_version = "1.34"
node_instance_type = "c6a.xlarge"
node_desired_size  = 2
node_min_size      = 2
node_max_size      = 2

private_subnet1 = "subnet-09ffaae2491b88ad5"
private_subnet2 = "subnet-0a2c29726c4aa9d95"

# MongoDB
db_instance_type = "t2.medium"
db_user          = "admin"
db_password      = "admin"
ec2_key_pair = "abhi-key-pair"
public_subnet = "subnet-0b7a762a8d592d20e"
instance_role_for_db = "RoleForPutAndListObjectsInS3ForAbhi"
