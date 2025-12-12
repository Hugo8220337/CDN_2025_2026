variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "sd-s3-frontend-bucket"
}

variable "mongo_atlas_url" {
  description = "Mongo Atlas Connection String"
  type        = string
  default     = "mongodb+srv://Hugo:Uma_Grand3_Bifana3@cluster0.yaab3lp.mongodb.net/ticket-master"
}