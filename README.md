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

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/cloudtopia-capstone.git
cd cloudtopia-capstone


### 2. Build and Push Docker Image
bash
Copy
Edit
cd weather-simulator
docker build -t yourdockerhubusername/weather-simulator .
docker push yourdockerhubusername/weather-simulator

### 3. Update infrastructure/main.bicep
Replace <your-docker-image> with:
bicep
Copy
Edit
image: 'yourdockerhubusername/weather-simulator'

### 4. Set Up GitHub Secrets
Go to your GitHub repo → Settings → Secrets and Variables → Actions → New repository secret:

Name: AZURE_CREDENTIALS

Value: Output of az ad sp create-for-rbac --sdk-auth (with contributor role on your resource group)

5. Push Your Changes
bash
Copy
Edit
git add .
git commit -m "Initial CloudTopia project setup"
git push origin main
The GitHub Action will deploy your infrastructure.

🌐 Dashboard
Once deployed, go to:

pgsql
Copy
Edit
https://<your-storage-account>.blob.core.windows.net/weatherdata/latest_weather.json
You can host the dashboard/index.html on:

Azure Static Web Apps

GitHub Pages

Or view it locally with Live Server in VS Code.







