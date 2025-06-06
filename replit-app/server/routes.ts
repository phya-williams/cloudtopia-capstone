import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { insertWeatherLogSchema, insertWeatherAlertSchema } from "../shared/schema";
import { z } from "zod";

const locations = ['Main Plaza', 'Adventure Zone', 'Water Park', 'Sky Deck', 'Forest Trail'];
const conditions = ['Sunny', 'Partly Cloudy', 'Cloudy', 'Overcast', 'Light Rain', 'Clear'];
const windDirections = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];

function generateRandomWeatherData() {
  const now = new Date();
  return {
    timestamp: now,
    temperature: Math.round((65 + Math.random() * 25) * 10) / 10,
    humidity: Math.round(30 + Math.random() * 50),
    windSpeed: Math.round(Math.random() * 15 * 10) / 10,
    windDirection: windDirections[Math.floor(Math.random() * windDirections.length)],
    visibility: Math.round((5 + Math.random() * 10) * 10) / 10,
    pressure: Math.round((29.5 + Math.random() * 1.5) * 100) / 100,
    conditions: conditions[Math.floor(Math.random() * conditions.length)],
    status: Math.random() > 0.1 ? 'Normal' : 'Watch',
    location: locations[Math.floor(Math.random() * locations.length)],
  };
}

function generateRandomAlert() {
  const alertTypes = [
    {
      type: 'weather',
      title: 'High UV Index',
      message: 'Recommend shade stations for guests',
      severity: 'warning'
    },
    {
      type: 'system',
      title: 'All Systems Operational',
      message: 'Weather conditions optimal for park operations',
      severity: 'info'
    },
    {
      type: 'forecast',
      title: 'Rain Possible',
      message: '30% chance of light rain in the next 2 hours',
      severity: 'warning'
    }
  ];
  
  const alert = alertTypes[Math.floor(Math.random() * alertTypes.length)];
  return {
    ...alert,
    timestamp: new Date(),
    isActive: 1
  };
}

export async function registerRoutes(app: Express): Promise<Server> {
  const server = createServer(app);

  // Weather data endpoints
  app.get("/api/weather/logs", async (req, res) => {
    try {
      const limit = parseInt(req.query.limit as string) || 50;
      const logs = await storage.getWeatherLogs(limit);
      res.json(logs);
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch weather logs" });
    }
  });

  app.get("/api/weather/latest", async (req, res) => {
    try {
      const latest = await storage.getLatestWeatherLog();
      if (!latest) {
        return res.status(404).json({ error: "No weather data available" });
      }
      res.json(latest);
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch latest weather data" });
    }
  });

  app.get("/api/weather/alerts", async (req, res) => {
    try {
      const alerts = await storage.getActiveWeatherAlerts();
      res.json(alerts);
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch alerts" });
    }
  });

  app.get("/api/weather/analytics", async (req, res) => {
    try {
      const logs = await storage.getWeatherLogs(100);
      
      if (logs.length === 0) {
        return res.json({
          averageTemperature: 0,
          maxTemperature: 0,
          minTemperature: 0,
          averageHumidity: 0,
          totalLogs: 0,
          extremeWeatherEvents: 0
        });
      }

      const temperatures = logs.map(log => log.temperature);
      const humidity = logs.map(log => log.humidity);
      
      const analytics = {
        averageTemperature: Math.round((temperatures.reduce((a, b) => a + b, 0) / temperatures.length) * 10) / 10,
        maxTemperature: Math.max(...temperatures),
        minTemperature: Math.min(...temperatures),
        averageHumidity: Math.round(humidity.reduce((a, b) => a + b, 0) / humidity.length),
        totalLogs: logs.length,
        extremeWeatherEvents: logs.filter(log => log.status !== 'Normal').length
      };

      res.json(analytics);
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch analytics" });
    }
  });

  // System status endpoint
  app.get("/api/system/status", async (req, res) => {
    try {
      const status = {
        blobStorageStatus: process.env.AZURE_STORAGE_ACCOUNT_NAME ? "connected" : "disconnected",
        dataRefreshStatus: "active",
        dataQualityStatus: "good",
        latestDataTimestamp: new Date().toISOString(),
        activeAlertsCount: (await storage.getActiveWeatherAlerts()).length,
        isOperational: true
      };
      res.json(status);
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch system status" });
    }
  });

  // Monitoring endpoints (simplified)
  app.get("/api/monitoring/metrics", async (req, res) => {
    try {
      const metrics = {
        containerHealth: {
          cpuUsage: Math.round(Math.random() * 50),
          memoryUsage: Math.round(Math.random() * 60),
          requestCount: Math.round(Math.random() * 1000),
          errorRate: Math.round(Math.random() * 5)
        },
        weatherDataMetrics: {
          dataIngestionRate: Math.round(Math.random() * 100),
          storageLatency: Math.round(Math.random() * 200),
          alertsGenerated: await storage.getActiveWeatherAlerts().then(alerts => alerts.length),
          systemUptime: 99.9
        },
        performanceMetrics: {
          responseTime: Math.round(Math.random() * 100),
          throughput: Math.round(Math.random() * 500),
          availabilityPercentage: 99.9
        }
      };
      res.json(metrics);
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch monitoring metrics" });
    }
  });

  // Auto-generate weather data every 4 seconds
  setInterval(async () => {
    try {
      const weatherData = generateRandomWeatherData();
      const validatedData = insertWeatherLogSchema.parse(weatherData);
      
      // Store in local memory
      await storage.createWeatherLog(validatedData);
      
      // Try Azure storage if configured
      if (process.env.AZURE_STORAGE_ACCOUNT_NAME && process.env.AZURE_STORAGE_ACCOUNT_KEY) {
        try {
          // Azure upload would go here when properly configured
          console.log("Azure storage upload would happen here");
        } catch (azureError) {
          console.log("Azure storage not available, using local storage");
        }
      }

      // Generate occasional alerts
      if (Math.random() < 0.1) {
        const alertData = generateRandomAlert();
        const validatedAlert = insertWeatherAlertSchema.parse(alertData);
        await storage.createWeatherAlert(validatedAlert);
      }

    } catch (error) {
      console.error("Error generating weather data:", error);
    }
  }, 4000);

  return server;
}
