variable "resource_group_name" {
  type        = string
  default     = "rg-simple-api"
  description = "Name of the Azure Resource Group"
}

variable "location" {
  type        = string
  default     = "centralindia"
  description = "Azure region to deploy resources"
}

variable "container_image" {
  type        = string
  # The default value points to Microsoft's hello-world sample image, NOT the
  # actual Flask application built in this repository. If someone runs
  # `terraform apply` locally without explicitly passing this variable (e.g.,
  # without the CI -var flag), the wrong app gets deployed and the error is
  # completely silent. A safer approach is to remove the default entirely, which
  # forces every caller to supply a value explicitly:
  #
  #   variable "container_image" {
  #     type        = string
  #     description = "The GHCR image to deploy (e.g., ghcr.io/owner/repo:sha)"
  #     # No default — must be supplied explicitly
  #   }
  default     = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
  description = "The container image to deploy (default is Microsoft's hello-world, replace with your GHCR image)"
}

variable "container_port" {
  type        = number
  default     = 5000
  description = "Port exposed by the Flask app container"
}
