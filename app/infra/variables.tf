variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "frontend_bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "sd-s3-frontend-bucket"
}


variable "mongo_atlas_url" {
  description = "Mongo Atlas Connection String"
  type        = string
  default     = "MONGO_URI_HERE"
}