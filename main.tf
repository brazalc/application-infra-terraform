terraform {
  backend "remote" {
    organization = "albraz1991@gmail.com"

    workspaces {
      name = "application-infra-terraform"
    }
  }
}


resource "null_resource" "example" {
  triggers = {
    value = "A example resource that does nothing!"
  }
}
