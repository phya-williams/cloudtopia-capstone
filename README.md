# 🌤️ CloudTopia Capstone Deployment Guide

This document provides a step-by-step guide to deploy the CloudTopia weather simulation system using GitHub Actions, Azure Bicep, and containerization. You can reuse this guide for any new sandbox or Azure environment.

---

## 📦 What You’ll Deploy

1. **Azure Container Registry (ACR)** – Stores your weather simulator container.
2. **Azure Container Instance (ACI)** – Runs the simulator.
3. **Azure Storage Account** – Logs weather data.
4. **Log Analytics + Azure Monitor** – Observes and triggers alerts.
5. **Infrastructure as Code (Bicep)** – Defines your resources.
6. **GitHub Actions** – Automates image building and deployment.

---

## 🗂️ GitHub Repo Structure

```
cloudtopia-capstone/
├── .github/
│   └── workflows/
│       ├── deploy.yml          # Deploy infrastructure via Bicep
│       └── build-and-push.yml # Build Docker image & push to ACR
├── infrastructure/
│   └── main.bicep             # Azure Bicep template
├── weather-simulator/
│   ├── app.py
│   └── Dockerfile
├── dashboard/
│   └── index.html
```

---

## ✅ Setup Steps (Repeatable)

### 1. Sign into Azure

```bash
az login
az account set --subscription "<Your Subscription ID>"
```

### 2. Create a Resource Group

```bash
az group create --name cloudtopia-rg --location eastus
```

### 3. Create an ACR Registry

```bash
az acr create --name cloudtopiaacr --resource-group cloudtopia-rg --sku Basic --admin-enabled true
```

### 4. Get ACR Credentials

```bash
az acr credential show --name cloudtopiaacr
```

Copy `username` and `password` for use in GitHub secrets.

### 5. Create Azure Service Principal for GitHub

```bash
az ad sp create-for-rbac --name "cloudtopia-sp" \
  --sdk-auth \
  --role contributor \
  --scopes /subscriptions/<sub-id>/resourceGroups/cloudtopia-rg
```

Copy the full JSON output for use as `AZURE_CREDENTIALS` in GitHub secrets.

---

## 🔐 Set GitHub Secrets

Go to `Settings` → `Secrets and variables` → `Actions`, then add:

| Secret Name         | Value                                 |
| ------------------- | ------------------------------------- |
| `AZURE_CREDENTIALS` | Output from Service Principal command |
| `ACR_USERNAME`      | From ACR credentials                  |
| `ACR_PASSWORD`      | From ACR credentials                  |
| `ACR_NAME`          | `cloudtopiaacr`                       |
| `RESOURCE_GROUP`    | `cloudtopia-rg`                       |

---

## 🚀 GitHub Workflows

### `.github/workflows/build-and-push.yml`

```yaml
name: Build and Push to ACR

on:
  push:
    paths:
      - 'weather-simulator/**'
      - '.github/workflows/build-and-push.yml'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Log in to ACR
      uses: azure/docker-login@v1
      with:
        login-server: ${{ secrets.ACR_NAME }}.azurecr.io
        username: ${{ secrets.ACR_USERNAME }}
        password: ${{ secrets.ACR_PASSWORD }}

    - name: Build and push
      run: |
        docker build -t ${{ secrets.ACR_NAME }}.azurecr.io/weather-simulator:latest ./weather-simulator
        docker push ${{ secrets.ACR_NAME }}.azurecr.io/weather-simulator:latest
```

### `.github/workflows/deploy.yml`

```yaml
name: Deploy CloudTopia Infrastructure

on:
  push:
    paths:
      - 'infrastructure/**'
      - '.github/workflows/deploy.yml'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Login to Azure
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Deploy Bicep
      run: |
        az deployment group create \
          --resource-group ${{ secrets.RESOURCE_GROUP }} \
          --template-file infrastructure/main.bicep \
          --parameters containerImage="${{ secrets.ACR_NAME }}.azurecr.io/weather-simulator:latest"
```

---

## 📦 main.bicep Parameters

Make sure your Bicep file includes this parameter:

```bicep
param containerImage string
```

Use it to replace the hardcoded ACR URL inside your `containerGroup` resource.

---

## 🧪 Testing & Monitoring

1. The container instance will start simulating weather.
2. Logs are written to blob storage.
3. Set up Azure Monitor to stream logs into Log Analytics.
4. Define alert rules based on temperature or rain severity.

---

## 🔁 Reusing in Another Sandbox

Just rerun:

```bash
az login
az account set --subscription "<your-subscription>"
az group create --name cloudtopia-rg --location eastus
az acr create --name cloudtopiaacr --resource-group cloudtopia-rg --sku Basic --admin-enabled true
az acr update -n cloudtopiaacr --admin-enabled true
az acr credential show --name cloudtopiaacr
az ad sp create-for-rbac --name "cloudtopia-sp" --sdk-auth --role contributor --scopes /subscriptions/<sub-id>/resourceGroups/cloudtopia-rg
```

Then plug new credentials into GitHub secrets and push to GitHub.

---

## 🏁 You're Done!

All infrastructure is deployed and the simulator is running. CloudTopia is live. 🎉
