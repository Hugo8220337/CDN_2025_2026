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