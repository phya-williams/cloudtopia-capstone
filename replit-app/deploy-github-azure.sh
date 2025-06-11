#!/bin/bash

# CloudTopia Weather Dashboard - GitHub to Azure Deployment Script
# Works with any Azure Sandbox environment

set -e

echo "🌤️  CloudTopia Weather Dashboard - Azure Deployment"
echo "=================================================="

# Get resource group (auto-detect sandbox environment)
export RESOURCE_GROUP=$(az group list --query "[0].name" -o tsv)
LOCATION=$(az group show --name $RESOURCE_GROUP --query location -o tsv)
APP_NAME="cloudtopia-weather-2025"

echo "📍 Detected Resource Group: $RESOURCE_GROUP"
echo "📍 Location: $LOCATION"
echo "📍 App Name: $APP_NAME"

# Create App Service Plan
echo "🔧 Creating App Service Plan..."
az appservice plan create \
  --name "$APP_NAME-plan" \
  --resource-group $RESOURCE_GROUP \
  --sku B1 \
  --is-linux

# Create Web App
echo "🔧 Creating Web App..."
az webapp create \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --plan "$APP_NAME-plan" \
  --runtime "NODE:18-lts"

# Zip and upload your dashboard (replace path)
cd /home/cloud/cloudtopia-replit-2
zip -r cloudtopia.zip .

# Deploy to web app
az webapp deployment source config-zip \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --src cloudtopia.zip


# Set environment variables
echo "🔧 Setting environment variables..."
az webapp config appsettings set \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    NODE_ENV=production \
    AZURE_STORAGE_ACCOUNT_NAME=cloudtopiablob2025 \
    AZURE_STORAGE_CONTAINER_NAME=weatherdata

# Get the app URL
APP_URL=$(az webapp show --name $APP_NAME --resource-group $RESOURCE_GROUP --query defaultHostName -o tsv)

echo "✅ Deployment Complete!"
echo "🌐 App URL: https://$APP_URL"
