module "kms" {
  source = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  /*
  aws_kms_alias = {
    name = "alias/eks/application-eks"
  }
  */
}