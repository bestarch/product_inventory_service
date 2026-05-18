variable "prefix" {
  description = "prefix of resources"
  type        = string
  default     = "abhi"
}

variable "region" {
  description = "Name of the region where deployment happens"
  type        = string
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks (one per AZ)."
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks (one per AZ)."
  type        = list(string)
  default     = ["10.1.11.0/24", "10.1.12.0/24"]
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes."
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 3
}

variable "db_instance_type" {
  description = "EC2 instance type for the DB VM."
  type        = string
  default     = "t3.small"
}

variable "db_user" {
  description = "DB application user."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "DB application user password. Override at apply time."
  type        = string
  sensitive   = true
}

variable "instance_role_for_db" {
  description = "IAM role to be attached to the DB VM"
  type        = string
}

variable "private_subnet1" {
  description = "Private subnet where EKS to be created"
  type        = string
}

variable "private_subnet2" {
  description = "Private subnet where EKS to be created"
  type        = string
}

variable "public_subnet" {
  description = "Public subnet where db to be deployed"
  type        = string
}

variable "ec2_key_pair" {
  description = "Name of the existing SSH key-pair to be attached with the VM"
  type        = string
}
