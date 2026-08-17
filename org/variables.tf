variable "org_name" {
  description = "The org name/slug from GitHub Enterprise"
  type        = string
}
variable "webhook_secret" {
  description = "A shared secret that will be used in GitHub to sign the data and Azure to verify the signature before storing"
  type        = string
}
variable "sec_team_function_principal_id" {
  description = "Principal ID for the security team's app function"
  type        = string
}
