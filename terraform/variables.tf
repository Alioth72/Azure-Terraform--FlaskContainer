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
  default     = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
  description = "The container image to deploy (default is Microsoft's hello-world, replace with your GHCR image)"
}

variable "container_port" {
  type        = number
  default     = 5000
  description = "Port exposed by the Flask app container"
}
