# Variables - customize these
LOCATION="eastus"
RESOURCE_GROUP="your-resource-group"
LOG_ANALYTICS_WORKSPACE="myLogAnalyticsWorkspace"
TARGET_RESOURCE_ID="/subscriptions/<subscription-id>/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/yourStorageAccount"  # Replace with your target resource ID

# 1. Create Log Analytics Workspace (if not exists)
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $LOG_ANALYTICS_WORKSPACE \
  --location $LOCATION

# Get the workspace ID and resource ID
WORKSPACE_RESOURCE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $LOG_ANALYTICS_WORKSPACE \
  --query id -o tsv)

# 2. Enable Diagnostic Settings on the target resource to send logs to Log Analytics workspace
az monitor diagnostic-settings create \
  --resource $TARGET_RESOURCE_ID \
  --resource-group $RESOURCE_GROUP \
  --name "sendToLogAnalytics" \
  --workspace $WORKSPACE_RESOURCE_ID \
  --logs '[{"category": "StorageRead", "enabled": true},{"category": "StorageWrite", "enabled": true},{"category": "StorageDelete", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'

