output "app_url" {
  description = "The public URL of the deployed Flask REST API"
  value       = "https://${azurerm_container_app.api.ingress[0].fqdn}"
}
