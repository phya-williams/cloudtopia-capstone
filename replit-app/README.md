# CloudTopia Weather Dashboard

Real-time weather monitoring dashboard for CloudTopia theme park with Azure cloud integration.

## Features

- Real-time weather data updates every 4 seconds
- Azure Blob Storage integration for data persistence
- System monitoring and health status
- Weather analytics and trend analysis
- Responsive design with CloudTopia branding

## Technology Stack

- **Frontend**: React 18, TypeScript, Tailwind CSS, TanStack Query
- **Backend**: Node.js, Express, TypeScript
- **Cloud**: Microsoft Azure (Blob Storage, Web Apps)
- **Deployment**: GitHub Actions + Azure Web Apps

## Quick Start

1. Clone the repository
2. Install dependencies: `npm install`
3. Set environment variables for Azure storage
4. Run development server: `npm run dev`
5. Build for production: `npm run build`

## Azure Deployment

This application is configured for deployment to Azure Web Apps using GitHub Actions. 

To deploy:
1. Create an Azure Web App
2. Configure GitHub secrets with Azure publish profile
3. Push to main branch to trigger automatic deployment

## Environment Variables

- `AZURE_STORAGE_ACCOUNT_NAME`: Azure storage account name
- `AZURE_STORAGE_ACCOUNT_KEY`: Azure storage account access key
- `AZURE_STORAGE_CONTAINER_NAME`: Storage container name (default: weatherdata)

## License

MIT License - CloudTopia Theme Park
