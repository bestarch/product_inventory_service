
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
  region = var.region
}

data "aws_subnet" "private_subnet1" {
  id = var.private_subnet1
}

data "aws_subnet" "private_subnet2" {
  id = var.private_subnet2
}



################################################################################
# EKS cluster, IAM roles, node group (2 nodes in the private subnets)
################################################################################

# ---------------- IAM role for the EKS control plane ----------------
data "aws_iam_policy_document" "eks_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.prefix}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


# ---------------- EKS cluster ----------------
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.prefix}cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    # Worker nodes live in private subnets; we also pass the public subnets
    # so the control plane ENIs can be placed in them if needed and so
    # subnet auto-discovery for the LB controller works on both tiers.
    subnet_ids = [
      data.aws_subnet.private_subnet1.id,
      data.aws_subnet.private_subnet2.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
    
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# ---------------- OIDC provider for IRSA ----------------
# data "tls_certificate" "eks_oidc" {
#   url = aws_eks_cluster.this.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "eks" {
#   url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
# }

# ---------------- IAM role for the managed node group ----------------
data "aws_iam_policy_document" "node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_role" {
  name               = "${var.prefix}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ---------------- Managed node group (2 nodes, private subnets) ----------------
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.prefix}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [data.aws_subnet.private_subnet1.id, data.aws_subnet.private_subnet2.id]

  instance_types  = [var.node_instance_type]

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr,
  ]

#   tags = {
#     Name = "${local.name_prefix}-ng"
#   }
}
