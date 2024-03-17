provider "aws" {
  region = var.region
}

locals {
  cluster_name = "application-eks"
}

resource "aws_eks_cluster" "application-eks" {
  name     = "application-eks"
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
    subnet_ids = [
      "subnet-0b8e186c4ab49a658",
      "subnet-01322d31ffbfa2e1f",
      "subnet-0276ca9dbdd8cc764",
      "subnet-0487e1aaaf7d3a03b"
      ]
  }

  # vpc_config {
  #   subnet_ids = module.vpc.public_subnets
  # }

  depends_on = [
    aws_iam_role.eks-iam-role
  ]
}

resource "aws_eks_node_group" "worker-node-group" {
  cluster_name    = aws_eks_cluster.application-eks.name
  node_group_name = "worker-node-group"
  capacity_type = "SPOT"
  instance_types = ["t3.medium"]
  node_role_arn = aws_iam_role.workernodes.arn
  subnet_ids = [
      "subnet-0b8e186c4ab49a658",
      "subnet-01322d31ffbfa2e1f",
      "subnet-0276ca9dbdd8cc764",
      "subnet-0487e1aaaf7d3a03b"
      ]
  #subnet_ids = module.vpc.public_subnets
 
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    #aws_eks_cluster.application-eks,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    ]
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.eks-iam-role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.eks-iam-role.name
}



resource "aws_iam_role" "eks-iam-role" {
  name = "application-eks-iam-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF
}

resource "aws_iam_role" "workernodes" {
  name = "eks-node-group-workernodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
role    = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
role    = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
role    = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
role    = aws_iam_role.workernodes.name
}