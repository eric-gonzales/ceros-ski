variable "container_port" {
  description = "What port has been exposed by the container, see the Dockerfile"
  default     = "5000"
}

variable "region" {
  description = "What region the infrastructure is running in."
  default     = "us-east-1"
}

variable "namespace" {
  description = "Organization name, but can be an abbreviation, etc."
  default     = "ceros"
}

variable "stage" {
  description = "What stage the infrastructure is in, eg. 'staging', 'production', 'qa', etc."
  default     = "evaluation"
}
