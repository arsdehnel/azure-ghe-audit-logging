variable "org_name" {
  description = "The org name/slug from GitHub Enterprise"
  type        = string
  default     = "mock-org-1"
}
variable "webhook_secret" {
  description = "A shared secret that will be used in GitHub to sign the data and Azure to verify the signature before storing"
  type        = string
}
