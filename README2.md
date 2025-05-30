Containerized APP (manual)
# Grab the resource group
export RESOURCE_GROUP=$(az group list --query "[0].name" -o tsv)

# Create container registry
az acr create --resource-group RESOURCE_GROUP --name cloudtopiaregistry --sku Basic --admin-enabled true

# Create container app environment
az containerapp env create --name cloudtopia-env --resource-group RESOURCE_GROUP --location eastus

# Build and push image to Azure Container Registry
az acr build --registry cloudtopiaregistry --image cloudtopia-weather:latest .

# Deploy to Container Apps
az containerapp create \
  --name cloudtopia-dashboard \
  --resource-group RESOURCE_GROUP \
  --environment cloudtopia-env \
  --image cloudtopiaregistry.azurecr.io/cloudtopia-weather:latest \
  --target-port 5000 \
  --ingress external \
  --registry-server cloudtopiaregistry.azurecr.io \
  --secrets azure-storage-account=cloudtopiablob2025 \
             azure-storage-key=HuSHRAuKYPDMHc2rNlAX4eubTrGAb8r0N+P1DzLRgo5EAXpV3K10YDQW2ua3hFJ1t737r7i8ACwM+AStODPblA== \
             azure-storage-container=weatherdata \
  --env-vars NODE_ENV=production \
             AZURE_STORAGE_ACCOUNT_NAME=secretref:azure-storage-account \
             AZURE_STORAGE_ACCOUNT_KEY=secretref:azure-storage-key \
             AZURE_STORAGE_CONTAINER_NAME=secretref:azure-storage-container
