###############################################################
# MAKEFILE FOR TERRAFORM OPERATIONS
# Usage: make <target>
###############################################################

.PHONY: help init plan apply destroy fmt validate lint clean docs

# Default target
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform
	@echo "🔧 Initializing Terraform..."
	terraform init -upgrade

plan: ## Run Terraform plan
	@echo "📋 Running Terraform plan..."
	terraform plan -out=tfplan

apply: ## Apply Terraform changes
	@echo "🚀 Applying Terraform changes..."
	terraform apply tfplan

destroy: ## Destroy Terraform resources
	@echo "🗑️  Destroying infrastructure..."
	terraform destroy

fmt: ## Format Terraform files
	@echo "✨ Formatting Terraform files..."
	terraform fmt -recursive

validate: fmt ## Validate Terraform configuration
	@echo "✅ Validating Terraform configuration..."
	terraform validate

lint: ## Run tflint
	@echo "🔍 Running tflint..."
	tflint --init
	tflint --recursive

security: ## Run tfsec security scan
	@echo "🔒 Running security scan..."
	tfsec .

docs: ## Generate module documentation
	@echo "📚 Generating documentation..."
	terraform-docs markdown table --output-file README.md --output-mode inject ./modules/resourcegroup
	terraform-docs markdown table --output-file README.md --output-mode inject ./modules/Vnet
	terraform-docs markdown table --output-file README.md --output-mode inject ./modules/Subnet
	terraform-docs markdown table --output-file README.md --output-mode inject ./modules/NSG
	terraform-docs markdown table --output-file README.md --output-mode inject ./modules/RouteTable
	terraform-docs markdown table --output-file README.md --output-mode inject ./modules/VNetPeering

clean: ## Clean Terraform files
	@echo "🧹 Cleaning Terraform files..."
	rm -rf .terraform
	rm -f tfplan
	rm -f .terraform.lock.hcl
	find . -name "*.tfstate*" -delete

cost: ## Estimate infrastructure cost with Infracost
	@echo "💰 Estimating infrastructure cost..."
	infracost breakdown --path .

graph: ## Generate Terraform dependency graph
	@echo "📊 Generating dependency graph..."
	terraform graph | dot -Tsvg > graph.svg
	@echo "Graph saved to graph.svg"

pre-commit: ## Install pre-commit hooks
	@echo "🪝 Installing pre-commit hooks..."
	pre-commit install

test: validate lint security ## Run all validation tests
	@echo "✅ All tests passed!"

deploy-dev: ## Deploy to dev environment
	@echo "🚀 Deploying to dev..."
	terraform workspace select dev || terraform workspace new dev
	terraform apply -var-file=environments/dev.tfvars -auto-approve

deploy-prod: ## Deploy to prod environment (with confirmation)
	@echo "⚠️  Deploying to PRODUCTION..."
	terraform workspace select prod || terraform workspace new prod
	terraform apply -var-file=environments/prod.tfvars

output: ## Show Terraform outputs
	@echo "📤 Terraform outputs:"
	terraform output

refresh: ## Refresh Terraform state
	@echo "🔄 Refreshing Terraform state..."
	terraform refresh
