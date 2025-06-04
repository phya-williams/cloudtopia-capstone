# CloudTopia Capstone: Full Deployment Guide (Sandbox-Friendly)

This guide helps you:

1. Deploy a containerized weather simulator.
2. Log simulated weather events in Azure Blob Storage.
3. Monitor logs via Azure Monitor & Log Analytics.
4. Trigger weather alerts on thresholds.
5. Host dashboard on GitHub Pages.

---

## 🔧 Prerequisites

* Azure subscription (Pluralsight sandbox or personal)
* GitHub repo (e.g., `cloudtopia-capstone`)
* Azure CLI installed locally or use Cloud Shell

---

## 📁 Repository Structure (in GitHub)

```
cloudtopia-capstone/
├── .github/workflows/
│   ├── deploy-infra.yaml     # Bicep deployment
│   └── container-build.yaml  # Container build & push to ACR
├── dashboard/
│   └── index.html            # Weather dashboard
├── infrastructure/
│   └── main.bicep            # Azure resources definition
└── weather-simulator/
    ├── app.py                # Weather generator
    └── Dockerfile            # Image builder
```

---

## 🚀 Step-by-Step Deployment

### 1. Clone Your GitHub Repo

```bash
git clone https://github.com/phya-williams/cloudtopia-capstone.git
cd cloudtopia-capstone
```

### 2. Build and Push Docker Image to ACR

```bash
# Log in to Azure and ACR
az deployment group create --resource-group 1-f19e8a67-playground-sandbox --template-file infrastructure/main.bicep

export RESOURCE_GROUP=$(az group list --query "[0].name" -o tsv)

az acr create --resource-group $RESOURCE_GROUP --name cloudtopiaregistry --sku Basic --admin-enabled true

az containerapp env create --name cloudtopia-env --resource-group $RESOURCE_GROUP --location southcentralus

# Set ACR login server name (replace with your unique name if needed)
ACR_NAME=cloudtopiaacr
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)

# Build & push image
cd weather-simulator
# CloudTopia Capstone: Full Deployment Guide (Sandbox-Friendly)

This guide helps you:

1. Deploy a containerized weather simulator.
2. Log simulated weather events in Azure Blob Storage.
3. Monitor logs via Azure Monitor & Log Analytics.
4. Trigger weather alerts on thresholds.
5. Host dashboard on GitHub Pages.

---

## 🔧 Prerequisites

* Azure subscription (Pluralsight sandbox or personal)
* GitHub repo (e.g., `cloudtopia-capstone`)
* Azure CLI installed locally or use Cloud Shell

---

## 📁 Repository Structure (in GitHub)

```
cloudtopia-capstone/
├── .github/workflows/
│   ├── deploy-infra.yaml     # Bicep deployment
│   └── container-build.yaml  # Container build & push to ACR
├── dashboard/
│   └── index.html            # Weather dashboard
├── infrastructure/
│   └── main.bicep            # Azure resources definition
└── weather-simulator/
    ├── app.py                # Weather generator
    └── Dockerfile            # Image builder
```

---

## 🚀 Step-by-Step Deployment

### 1. Clone Your GitHub Repo

```bash
git clone https://github.com/your-username/cloudtopia-capstone.git
cd cloudtopia-capstone
```

### 2. Build and Push Docker Image to ACR

```bash
# Log in to Azure and ACR
az login
az acr login --name cloudtopiaacr

# Set ACR login server name (replace with your unique name if needed)
ACR_NAME=cloudtopiaacr
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)

# Build & push image
cd weather-simulator
# CloudTopia Capstone: Full Deployment Guide (Sandbox-Friendly)

This guide helps you:

1. Deploy a containerized weather simulator.
2. Log simulated weather events in Azure Blob Storage.
3. Monitor logs via Azure Monitor & Log Analytics.
4. Trigger weather alerts on thresholds.
5. Host dashboard on GitHub Pages.

---

## 🔧 Prerequisites

* Azure subscription (Pluralsight sandbox or personal)
* GitHub repo (e.g., `cloudtopia-capstone`)
* Azure CLI installed locally or use Cloud Shell

---

## 📁 Repository Structure (in GitHub)

```
cloudtopia-capstone/
├── .github/workflows/
│   ├── deploy-infra.yaml     # Bicep deployment
│   └── container-build.yaml  # Container build & push to ACR
├── dashboard/
│   └── index.html            # Weather dashboard
├── infrastructure/
│   └── main.bicep            # Azure resources definition
└── weather-simulator/
    ├── app.py                # Weather generator
    └── Dockerfile            # Image builder
```

---

## 🚀 Step-by-Step Deployment

### 1. Clone Your GitHub Repo

```bash
git clone https://github.com/your-username/cloudtopia-capstone.git
cd cloudtopia-capstone
```

### 2. Build and Push Docker Image to ACR

```bash
# Log in to Azure and ACR
az login
az acr login --name cloudtopiaacr

# Set ACR login server name (replace with your unique name if needed)
ACR_NAME=cloudtopiaacr
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)

# Build & push image
cd weather-simulator
az acr update -n cloudtopiaacr --admin-enabled true
az acr credential show --name cloudtopiaacr
docker build -t $ACR_LOGIN_SERVER/weather-simulator:latest .
docker push $ACR_LOGIN_SERVER/weather-simulator:latest
```

### 3. Update Bicep File (if needed)

Confirm `image:` in `infrastructure/main.bicep`:

```bicep
image: 'cloudtopiaacr.azurecr.io/weather-simulator:latest'
```

### 4. Set Up GitHub Secret for Deployment

In your GitHub repo:

* Go to **Settings > Secrets and Variables > Actions**
* Add new secret:

  * Name: `AZURE_CREDENTIALS`
  * Value: Output of:

```bash
az ad sp create-for-rbac --name "cloudtopia-sp" --role contributor \
  --scopes /subscriptions/<sub-id>/resourceGroups/<rg-name> \
  --sdk-auth
```

### 5. Push Everything to GitHub

```bash
git add .
git commit -m "Deploy CloudTopia infrastructure and container"
git push origin main
```

Your workflows (`deploy-infra.yaml` and `container-build.yaml`) will now auto-deploy.

---

## 🌐 Dashboard Access

* Once deployed, weather data will appear at:

```
https://<your-storage-account>.blob.core.windows.net/weatherdata/latest_weather.json
```

### ✅ Host Dashboard with GitHub Pages

1. Go to your GitHub repo → **Settings > Pages**
2. Source: Choose `Deploy from branch`
3. Branch: Select `main`, folder: `/dashboard`
4. Save and wait a few minutes
5. Access your dashboard at:

```
https://phya-williams.github.io/cloudtopia-capstone/
```

Other options:

* Azure Static Web Apps

Create Static Web App
Go to Azure Static Web Apps and create a new Static Web App.

Connect it to your GitHub repo and branch.

Set App location to dashboard.

Leave API location and Output location empty.

Review and create the app.

Deployment
Azure creates a GitHub Actions workflow .github/workflows/azure-static-web-apps.yml automatically.

Push changes to deploy the dashboard.

Access the Dashboard
Visit the URL given by Azure Static Web Apps, e.g.:

cpp
Copy
Edit
https://<your-static-web-app-name>.azurestaticapps.net

* VS Code Live Server

---

## 📊 Set Up Log Analytics and Azure Monitor Alerts

### 1. Add Log Analytics Workspace in Bicep

Add to your `main.bicep` file:

```bicep
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'cloudtopiala'
  location: resourceGroup().location
  sku: {
    name: 'PerGB2018'
  }
  properties: {
    retentionInDays: 30
  }
}
```

### 2. Enable Diagnostic Logs for Storage

Still in `main.bicep`, attach diagnostics:

```bicep
resource diagnostic 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'weatherdiag'
  scope: storageAccount
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      },
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}
```

### 3. Create an Alert Rule in Azure Portal (manually)

1. Go to **Monitor > Alerts > New Alert Rule**
2. Scope: your Log Analytics workspace
3. Condition:

   * Use **Log search** and enter query, e.g.:

```kusto
StorageBlobLogs
| where Uri endswith "latest_weather.json"
| where HttpStatusCode == 200
```

4. Actions: Create an email or webhook action group
5. Alert logic: Set frequency and thresholds (e.g., extreme temps)

---

## 🔁 Redeploy in a New Sandbox

1. Fork or clone your repo
2. Update secrets & ACR name in GitHub & Bicep
3. Follow steps 1–5 above

That’s it! Let me know if you'd like alert automation via Bicep or additional dashboard visualizations.

docker build -t $ACR_LOGIN_SERVER/weather-simulator:latest .
docker push $ACR_LOGIN_SERVER/weather-simulator:latest
```

### 3. Update Bicep File (if needed)

Confirm `image:` in `infrastructure/main.bicep`:

```bicep
image: 'cloudtopiaacr.azurecr.io/weather-simulator:latest'
```

### 4. Set Up GitHub Secret for Deployment

In your GitHub repo:

* Go to **Settings > Secrets and Variables > Actions**
* Add new secret:

  * Name: `AZURE_CREDENTIALS`
  * Value: Output of:

```bash
az ad sp create-for-rbac --name "cloudtopia-sp" --role contributor \
  --scopes /subscriptions/<sub-id>/resourceGroups/<rg-name> \
  --sdk-auth
```

### 5. Push Everything to GitHub

```bash
git add .
git commit -m "Deploy CloudTopia infrastructure and container"
git push origin main
```

Your workflows (`deploy-infra.yaml` and `container-build.yaml`) will now auto-deploy.

---

## 🌐 Dashboard Access

* Once deployed, weather data will appear at:

```
https://<your-storage-account>.blob.core.windows.net/weatherdata/latest_weather.json
```

### ✅ Host Dashboard with GitHub Pages

1. Go to your GitHub repo → **Settings > Pages**
2. Source: Choose `Deploy from branch`
3. Branch: Select `main`, folder: `/dashboard`
4. Save and wait a few minutes
5. Access your dashboard at:

```
https://your-username.github.io/cloudtopia-capstone/
```

Other options:

* Azure Static Web Apps
* VS Code Live Server

---

## 📊 Set Up Log Analytics and Azure Monitor Alerts

### 1. Add Log Analytics Workspace in Bicep

Add to your `main.bicep` file:

```bicep
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'cloudtopiala'
  location: resourceGroup().location
  sku: {
    name: 'PerGB2018'
  }
  properties: {
    retentionInDays: 30
  }
}
```

### 2. Enable Diagnostic Logs for Storage

Still in `main.bicep`, attach diagnostics:

```bicep
resource diagnostic 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'weatherdiag'
  scope: storageAccount
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      },
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}
```

### 3. Create an Alert Rule in Azure Portal (manually)

1. Go to **Monitor > Alerts > New Alert Rule**
2. Scope: your Log Analytics workspace
3. Condition:

   * Use **Log search** and enter query, e.g.:

```kusto
StorageBlobLogs
| where Uri endswith "latest_weather.json"
| where HttpStatusCode == 200
```

4. Actions: Create an email or webhook action group
5. Alert logic: Set frequency and thresholds (e.g., extreme temps)

---

## 🔁 Redeploy in a New Sandbox

1. Fork or clone your repo
2. Update secrets & ACR name in GitHub & Bicep
3. Follow steps 1–5 above

That’s it! Let me know if you'd like alert automation via Bicep or additional dashboard visualizations.

docker build -t $ACR_LOGIN_SERVER/weather-simulator:latest .
docker push $ACR_LOGIN_SERVER/weather-simulator:latest
```

### 3. Update Bicep File (if needed)

Confirm `image:` in `infrastructure/main.bicep`:

```bicep
image: 'cloudtopiaacr.azurecr.io/weather-simulator:latest'
```

### 4. Set Up GitHub Secret for Deployment

In your GitHub repo:

* Go to **Settings > Secrets and Variables > Actions**
* Add new secret:

  * Name: `AZURE_CREDENTIALS`
  * Value: Output of:

```bash
az ad sp create-for-rbac --name "cloudtopia-sp" --role contributor \
  --scopes /subscriptions/<sub-id>/resourceGroups/<rg-name> \
  --sdk-auth
```

### 5. Push Everything to GitHub

```bash
git add .
git commit -m "Deploy CloudTopia infrastructure and container"
git push origin main
```

Your workflows (`deploy-infra.yaml` and `container-build.yaml`) will now auto-deploy.

---

## 🌐 Dashboard Access

* Once deployed, weather data will appear at:

```
https://<your-storage-account>.blob.core.windows.net/weatherdata/latest_weather.json
```

### ✅ Host Dashboard with GitHub Pages

1. Go to your GitHub repo → **Settings > Pages**
2. Source: Choose `Deploy from branch`
3. Branch: Select `main`, folder: `/dashboard`
4. Save and wait a few minutes
5. Access your dashboard at:

```
https://your-username.github.io/cloudtopia-capstone/
```

Other options:

* Azure Static Web Apps
* VS Code Live Server

---

## 📊 Set Up Log Analytics and Azure Monitor Alerts

### 1. Add Log Analytics Workspace in Bicep

Add to your `main.bicep` file:

```bicep
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'cloudtopiala'
  location: resourceGroup().location
  sku: {
    name: 'PerGB2018'
  }
  properties: {
    retentionInDays: 30
  }
}
```

### 2. Enable Diagnostic Logs for Storage

Still in `main.bicep`, attach diagnostics:

```bicep
resource diagnostic 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'weatherdiag'
  scope: storageAccount
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      },
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}
```

### 3. Create an Alert Rule in Azure Portal (manually)

1. Go to **Monitor > Alerts > New Alert Rule**
2. Scope: your Log Analytics workspace
3. Condition:

   * Use **Log search** and enter query, e.g.:

```kusto
StorageBlobLogs
| where Uri endswith "latest_weather.json"
| where HttpStatusCode == 200
```

4. Actions: Create an email or webhook action group
5. Alert logic: Set frequency and thresholds (e.g., extreme temps)

---

## 🔁 Redeploy in a New Sandbox

1. Fork or clone your repo
2. Update secrets & ACR name in GitHub & Bicep
3. Follow steps 1–5 above

That’s it! Let me know if you'd like alert automation via Bicep or additional dashboard visualizations.

