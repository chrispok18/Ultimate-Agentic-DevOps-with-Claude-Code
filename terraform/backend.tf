# Remote state backend (S3)
#
# Bootstrap order:
#   1. Leave this block commented out and run `terraform init` as-is. This
#      lets you create the S3 bucket (and DynamoDB lock table, if you add
#      one) that will hold the remote state, using local state for the
#      first apply.
#   2. Once the state bucket exists, fill in the values below and uncomment
#      the block.
#   3. Run `terraform init -migrate-state` to copy local state into the new
#      S3 backend.
#
# terraform {
#   backend "s3" {
#     bucket  = "REPLACE_WITH_YOUR_TERRAFORM_STATE_BUCKET"
#     key     = "portfolio-site/terraform.tfstate"
#     region  = "ap-south-1"
#     encrypt = true
#   }
# }
