# interpolations cannot be used by the backend configuration so we must hard code some values below
# cannot encrypt and stay in the free tier due to KMS charges
terraform {
  required_version = ">= 0.11.7"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "ceros-evaluation-terraform-state"
    key            = "terraform.tfstate"
    dynamodb_table = "ceros-evaluation-terraform-state-lock"
    encrypt        = false
  }
}

provider "aws" {
  region  = "${var.region}"
  version = ">= 1.57.0"
}

# this label ensures that we maintain naming conventions across our infrastructure
module "label_ceros_evaluation" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.5.4"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
}
