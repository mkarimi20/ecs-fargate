terraform {
  backend "s3" {
    bucket   = "bucket-name-for-backend"
    key      = "us/aws-ss//artifactory-edge-nonprod/terraform.tfstate"
    region   = "region-name"
    role_arn = "need to change"

    acl        = "private"
    encrypt    = true
    kms_key_id = "kms-key"

    dynamodb_table = "table"
  }
}
