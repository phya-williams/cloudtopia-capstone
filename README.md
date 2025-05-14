# 🌩️ CloudTopia Weather Detection & Alert System

Welcome to the **CloudTopia Capstone Project** — a fully containerized, cloud-based weather detection and alert system for a fictional theme park! Built as part of a Junior Cloud Engineer training program, this system uses Azure services, GitHub Actions, and real-time data to simulate weather events and update a live dashboard.

---

## 🔧 Technologies Used

- **Azure Blob Storage**
- **Azure Container Instances**
- **Docker + Python**
- **Bicep (Infrastructure as Code)**
- **GitHub Actions**
- **JavaScript + HTML Dashboard**

---

## 🗂️ Project Structure


---

## 🚀 How It Works

1. **Simulator** generates random weather data and uploads it to a blob storage container.
2. **Azure Container Instance (ACI)** runs the simulator using a Docker image.
3. **Blob Storage** stores a JSON blob of the latest weather data.
4. **Dashboard** fetches and displays the latest weather every minute.
5. **GitHub Actions** deploys infrastructure on Bicep changes.

---

## 🔌 Prerequisites

- Azure Subscription
- GitHub Account
- Docker Hub account (to push your Docker image)

---

## 🛠️ Setup Instructions

🌀 CloudTopia Capstone: Weather Detection System Deployment Instructions (ACR Edition)
✅ 1. Clone the Repository
bash
Copy
Edit
git clone https://github.com/your-username/cloudtopia-capstone.git
cd cloudtopia-capstone

✅ 2. Build and Push Docker Image to Azure Container Registry (ACR)
🛠️ Make sure you’ve created your ACR:
bash
Copy
Edit
az acr create --name cloudtopiaacr --resource-group CloudTopiaRG --sku Basic
🔐 Log in to ACR:
bash
Copy
Edit
az acr login --name cloudtopiaacr
🧱 Build and tag your image:
bash
Copy
Edit
cd weather-simulator
docker build -t cloudtopiaacr.azurecr.io/weather-simulator:latest .
📤 Push to ACR:
bash
Copy
Edit
docker push cloudtopiaacr.azurecr.io/weather-simulator:latest


✅ 3. Update infrastructure/main.bicep
Make sure the container image path in your main.bicep is updated to:

bicep
Copy
Edit
image: 'cloudtopiaacr.azurecr.io/weather-simulator:latest'
Also verify that:

You're using a SystemAssigned identity in your container group.

You assign the AcrPull role to the container group’s identity (already included in the latest Bicep version).

✅ 4. Set Up GitHub Secrets
In your GitHub repository:

Go to Settings → Secrets and Variables → Actions → New repository secret.

🛡️ Add this secret:
Name: AZURE_CREDENTIALS

Value: Output of:

bash
Copy
Edit
az ad sp create-for-rbac --name "cloudtopia-deployer" --role contributor --scopes /subscriptions/<sub-id>/resourceGroups/CloudTopiaRG --sdk-auth
Replace <sub-id> with your actual Azure Subscription ID.

✅ 5. Push Your Changes
bash
Copy
Edit
git add .
git commit -m "Initial CloudTopia project setup with ACR"
git push origin main
Your GitHub Actions pipeline will automatically deploy your infrastructure using the Bicep template.

🌐 Dashboard Access
Once deployed, go to:

pgsql
Copy
Edit
https://<your-storage-account>.blob.core.windows.net/weatherdata/latest_weather.json
You can host the dashboard/index.html in any of the following:

Azure Static Web Apps (recommended for auto-updating)

GitHub Pages

Local preview (with Live Server in VS Code)
