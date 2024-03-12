module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "application-eks-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = "vpc-08b7b8fe8f1546aca"
  subnet_ids               = ["subnet-0576ffda003f8aa24", "subnet-0c55802630b1c1cac", "subnet-0d28a7197b90bc49e"]
  control_plane_subnet_ids = ["subnet-0926972984be070ca", "subnet-04d48bea2d56f9212", "subnet-0ac4247eb048196ee"]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t2.nano"]
  }

  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t2.nano"]
      capacity_type  = "SPOT"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
