terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#=========================================
# RESOURCE GROUP
#=========================================
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

#=========================================
# MONITORING & ENVIRONMENT (Logs and Environment)
#=========================================
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-simple-api"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "env" {
  name                       = "cae-simple-api"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

#=========================================
# LEAST PRIVILEGE MANAGED IDENTITY
#=========================================
# Justification: The Flask application is a standalone REST API that does
# not interact with any Azure storage, databases, or key vaults.
# Therefore, this User Assigned Managed Identity is granted ZERO Azure RBAC
# role assignments or permissions. If the container is compromised, the attacker
# has no access to control or read anything in your Azure subscription.
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "id-simple-api"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#=========================================
# AZURE CONTAINER APP
#=========================================
resource "azurerm_container_app" "api" {
  name                         = "ca-simple-api"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_identity.id]
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = var.container_port
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = "simple-api"
      image  = var.container_image
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}
