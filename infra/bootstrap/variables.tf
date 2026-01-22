variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "name_prefix" {
  type    = string
  default = "threatcomp"
}

variable "state_bucket_name" {
  description = "Globally-unique S3 bucket name for Terraform state"
  type        = string
}

variable "dynamodb_lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "threatcomp-tfstate-lock"
}