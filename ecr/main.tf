provider "aws" {
  region  = "us-east-1"
  profile = "nzbadmin"
}

terraform {
  required_version = ">= 0.12"
}

############# backend ##################

terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "terraform-infra-automation04"
    region         = "us-east-1"
    key            = "terraform-state-files/ecr-repo.tfstate"
    dynamodb_table = "terraform-state-locking04"
  }
}

########## ECR ######################
resource "aws_ecr_repository" "ecr" {
  name = "myapp-ecr-repo"
  tags = {
    name = "ecr-image"
  }
}


output "repo-url" {
  value = aws_ecr_repository.ecr.repository_url
}
