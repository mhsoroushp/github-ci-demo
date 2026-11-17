# Terraform Configuration for Azure Resource Group

This directory contains Terraform configuration to create an Azure Resource Group via GitHub Actions.

## Prerequisites

Before deploying, ensure the following:

### 1. Azure Setup
- An Azure subscription
- An Azure service principal for GitHub Actions authentication
- A storage account for Terraform state (backend)

### 2. GitHub Secrets
Add the following secrets to your GitHub repository (Settings > Secrets and variables > Actions):

```
AZURE_CREDENTIALS
  - JSON format containing:
    {
      "clientId": "...",
      "clientSecret": "...",
      "subscriptionId": "...",
      "tenantId": "..."
    }

TERRAFORM_BACKEND_RG
  - Resource group name for Terraform state storage

TERRAFORM_BACKEND_SA
  - Storage account name for Terraform state

TERRAFORM_BACKEND_CONTAINER
  - Storage container name (e.g., "tfstate")

TERRAFORM_BACKEND_KEY
  - State file name (e.g., "prod.tfstate")
```

## Project Structure

```
terraform/
├── main.tf              # Provider configuration and backend setup
├── variables.tf         # Variable definitions
├── resource_group.tf    # Azure resource group definition
├── outputs.tf           # Output values
├── dev.tfvars          # Development environment variables
└── .gitignore          # Git ignore for Terraform files
```

## File Descriptions

### main.tf
- Configures the Terraform version requirement (>= 1.0)
- Defines the Azure provider with azurerm >= 4.0
- Sets up the Azure backend for remote state storage

### variables.tf
- `resource_group_name`: Name of the resource group (default: rg-github-ci-demo)
- `location`: Azure region for deployment (default: West Europe)
- `environment`: Environment type - dev, staging, or prod (default: dev)
- `tags`: Resource tags for organization and cost tracking

### resource_group.tf
- Defines the `azurerm_resource_group` resource
- Applies tags including environment designation

### outputs.tf
- Exports resource group ID, name, and location
- Used for reference in subsequent deployments

### dev.tfvars
- Example values for development environment
- Customize this file for your specific needs

## Local Development

### Initialize Terraform
```bash
cd terraform
terraform init
```

### Validate Configuration
```bash
terraform validate
```

### Format Check
```bash
terraform fmt -check -recursive
```

### Plan Deployment
```bash
terraform plan -var-file="dev.tfvars" -out=tfplan
```

### Apply Configuration
```bash
terraform apply tfplan
```

### Destroy Resources
```bash
terraform destroy -var-file="dev.tfvars"
```

## GitHub Actions Workflow

The workflow file `.github/workflows/terraform.yml` defines three jobs:

### 1. terraform-plan (runs on all events)
- Checks out code
- Initializes Terraform with backend config
- Validates configuration
- Creates a plan
- Uploads plan artifact (for PRs)
- Comments on PRs with plan summary

### 2. terraform-apply (runs on main push only)
- Needs: terraform-plan
- Downloads the plan
- Applies changes to Azure
- Outputs resource group information

### 3. terraform-destroy (manual trigger only)
- Destroys resources via workflow_dispatch
- Useful for cleanup in dev/test environments

## Workflow Triggers

- **Push to main** with changes in `terraform/**` → Plan & Apply
- **Pull Request** on main with changes in `terraform/**` → Plan only
- **Manual dispatch** → Destroy resources (requires main branch)

## Azure Resources Created

- **Resource Group**: Named according to `resource_group_name` variable
- **Tags Applied**:
  - Project: github-ci-demo
  - ManagedBy: Terraform
  - Environment: dev/staging/prod
  - CreatedDate: 2024

## Backend Configuration

The Terraform backend is configured to use Azure Storage Account:
- Stores `.tfstate` file remotely
- Enables team collaboration
- Prevents state conflicts

### Setting Up Backend Storage
```bash
# Create resource group
az group create -n rg-terraform-state -l "West Europe"

# Create storage account (must be unique)
az storage account create -n tfstate12345 \
  -g rg-terraform-state \
  -l "West Europe" \
  --sku Standard_LRS

# Create storage container
az storage container create -n tfstate \
  --account-name tfstate12345
```

## Customization

### Change Resource Group Name
Edit `terraform/dev.tfvars`:
```hcl
resource_group_name = "rg-my-custom-name"
```

### Add More Environments
Create `staging.tfvars` and `prod.tfvars`:
```bash
cp terraform/dev.tfvars terraform/staging.tfvars
# Edit staging.tfvars with staging values
```

Update workflow to support environment selection via input.

### Add Additional Resources
Create new `.tf` files in the `terraform/` directory:
- `storage.tf` for storage accounts
- `network.tf` for virtual networks
- etc.

## Security Considerations

1. **Never commit secrets**: `.gitignore` prevents `.tfvars` files from being committed
2. **Use managed identities**: Consider using Azure Managed Identity instead of service principal
3. **Rotate credentials**: Regularly update Azure service principal secrets
4. **Review plans**: Always review terraform plans before applying
5. **Audit changes**: Enable Azure Activity Log for all deployments

## Troubleshooting

### Backend Authentication Failed
- Verify `AZURE_CREDENTIALS` secret is valid JSON
- Check that the service principal has access to the storage account

### Terraform Plan Fails
- Ensure all required secrets are set
- Verify `terraform validate` passes locally
- Check Azure subscription is active and accessible

### State Lock
If Terraform is stuck on a lock:
```bash
terraform force-unlock <LOCK_ID>
```

## References

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Terraform Backend Configuration](https://www.terraform.io/language/settings/backends/azurerm)
- [Azure Resource Group Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
