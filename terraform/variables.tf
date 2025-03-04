variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "giphy_api_key" {
  description = "API Key for Giphy"
  type        = string
  sensitive   = true
}

variable "environment_name" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "project_prefix" {
  description = "Prefix for project resources"
  type        = string
  default     = "mood-check"
}