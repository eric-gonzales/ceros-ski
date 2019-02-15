# Documents storage - eg. S3, DynamoDB, etc.

# this module sets up an S3 bucket for our ALB access logs (actually covered in the free tier!) with proper permissions
module "s3_bucket_access_logs" {
  source    = "git::https://github.com/cloudposse/terraform-aws-lb-s3-bucket.git?ref=tags/0.1.0"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "alb-access-logs"
  region    = "us-east-1"
}

# provision an S3 bucket to store the `terraform.tfstate` file and a DynamoDB table to lock the state file to prevent concurrent modifications and state corruption
module "terraform_state_backend" {
  source                        = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=master"
  namespace                     = "${var.namespace}"
  stage                         = "${var.stage}"
  name                          = "terraform"
  region                        = "${var.region}"
  enable_server_side_encryption = "false" # unfortunately KMS is not free, and thus we must override the default (secure) setting by not encrypting our terraform state
}
