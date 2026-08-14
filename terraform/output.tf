output "function_app_name" {
  value       = azurerm_linux_function_app.webhook_handler.name
  description = "Name of the Function App"
}

output "function_app_url" {
  value       = "https://${azurerm_linux_function_app.webhook_handler.default_hostname}/api/webhook"
  description = "Webhook endpoint URL (use this in GitHub webhook config)"
}

output "function_principal_id" {
  value       = azurerm_linux_function_app.webhook_handler.identity[0].principal_id
  description = "Principal ID of Function's managed identity"
}

output "application_insights_key" {
  value       = azurerm_application_insights.webhook_function.instrumentation_key
  sensitive   = true
  description = "Application Insights instrumentation key"
}

output "sec_team_resource_group" {
  value = azurerm_resource_group.sec_team_resources.name
}
