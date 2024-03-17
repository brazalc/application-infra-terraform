module "kms" {
  source = "terraform-aws-modules/eks/aws"

  /*
  aws_kms_alias = {
    name = "alias/eks/application-eks"
  }
  */
}