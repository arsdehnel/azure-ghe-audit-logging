# GitHub Enterprise + Azure

This is roughly from a client project where they wanted me to setup GitHub Enterprise for their internal development and they already had some established patterns within Azure.

## Key Architectural Elements

- GitHub Enterprisse with Enterprise Managed Users (EMU)
- GitHub Actions / Workflows for CICD
- Azure Key Vault for CICD secrets via GitHub OIDC + Entra Integration
- Azure Blob Storage for GitHub Audit Logs and Webhook event storage
- Azure Function App for GitHub Webhook ingestion

## Project Structure

- **📂 siem**: holds Terraform and Python for the audit logging of GitHub based on the plan of their team getting it from Azure Blob Storage to Sentinel
- **📂 org:** holds Terraform that would (in the real implementation) be a per-org implementation of Azure Key Vault, Entra App, and Resource Groups
- **📂 .github:** the workflows for proving out the OIDC workflow in Actions to get Azure Secrets