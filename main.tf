provider "aws" {
  region = var.region
}

locals {
  cluster_name = "application-eks"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.0.0"

#   name = "application-vpc"

#   cidr = "10.0.0.0/16"
#   azs  = slice(data.aws_availability_zones.available.names, 0, 3)

#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

#   enable_nat_gateway   = true
#   single_nat_gateway   = true
#   enable_dns_hostnames = true

#   public_subnet_tags = {
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#     "kubernetes.io/role/elb"                      = 1
#   }

#   private_subnet_tags = {
#     "kubernetes.io/cluster/${local.cluster_name}" = "shared"
#     "kubernetes.io/role/internal-elb"             = 1
#   }
# }

# Remova isso
# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "12.0.0"
#   # ... outros argumentos ...
# }

# Adicione isso
resource "aws_eks_cluster" "application-eks" {
  name     = "application-eks"
  role_arn = aws_iam_role.application-eks.arn

  vpc_config {
    subnet_ids = [aws_subnet.application-eks-1.id, aws_subnet.application-eks-2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.application-eks_eks,
    aws_iam_role_policy_attachment.application-eks_eks_cni,
  ]
}

resource "aws_iam_role" "application-eks" {
  name = "application-eks"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "application-eks_eks" {
  role       = aws_iam_role.application-eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "application-eks_eks_cni" {
  role       = aws_iam_role.application-eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_subnet" "application-eks-1" {
  vpc_id     = aws_vpc.application-eks.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "application-eks-2" {
  vpc_id     = aws_vpc.application-eks.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_vpc" "application-eks" {
  cidr_block = "10.0.0.0/16"
}

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "19.15.3"

#   cluster_name    = local.cluster_name
#   cluster_version = "1.29"

#   vpc_id                         = "vpc-00e8f852f3246126f"
#   subnet_ids                     = ["subnet-005953691b1c19ca6"]
#   cluster_endpoint_public_access = true

#   eks_managed_node_group_defaults = {
#     ami_type = "AL2_x86_64"

#   }

#   eks_managed_node_groups = {
#     one = {
#       name = "node-group-1"
#       instance_types = ["t2.nano"]

#       min_size     = 1
#       max_size     = 1
#       desired_size = 1
#     }

  #   two = {
  #     name = "node-group-2"

  #     instance_types = ["t2.nano"]

  #     min_size     = 1
  #     max_size     = 2
  #     desired_size = 1
  #   }
  # }
# }


# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
# data "aws_iam_policy" "ebs_csi_policy" {
#   arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# module "irsa-ebs-csi" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version = "4.7.0"

#   create_role                   = true
#   role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
#   provider_url                  = module.eks.oidc_provider
#   role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
# }

# resource "aws_eks_addon" "ebs-csi" {
#   cluster_name             = module.eks.cluster_name
#   addon_name               = "aws-ebs-csi-driver"
#   addon_version            = "v1.20.0-eksbuild.1"
#   service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
#   tags = {
#     "eks_addon" = "ebs-csi"
#     "terraform" = "true"
#   }
# }