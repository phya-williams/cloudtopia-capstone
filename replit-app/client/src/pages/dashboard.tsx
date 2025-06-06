import { useQuery } from "@tanstack/react-query";
import { Cloud, Sun, CloudRain, Activity, Database, Shield } from "lucide-react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "../components/ui/card";
import { Badge } from "../components/ui/badge";
import { Skeleton } from "../components/ui/skeleton";
import type { WeatherLog, WeatherAlert } from "../../shared/schema";

interface SystemStatus {
  blobStorageStatus: string;
  dataRefreshStatus: string;
  dataQualityStatus: string;
  latestDataTimestamp: string;
  activeAlertsCount: number;
  isOperational: boolean;
}

interface WeatherAnalytics {
  averageTemperature: number;
  maxTemperature: number;
  minTemperature: number;
  averageHumidity: number;
  totalLogs: number;
  extremeWeatherEvents: number;
}

function WeatherIcon({ condition }: { condition: string }) {
  switch (condition.toLowerCase()) {
    case 'sunny':
    case 'clear':
      return <Sun className="h-6 w-6 text-sunny-yellow" />;
    case 'cloudy':
    case 'overcast':
    case 'partly cloudy':
      return <Cloud className="h-6 w-6 text-gray-500" />;
    case 'light rain':
      return <CloudRain className="h-6 w-6 text-blue-500" />;
    default:
      return <Cloud className="h-6 w-6 text-gray-500" />;
  }
}

function StatusBadge({ status }: { status: string }) {
  const variant = status === "connected" || status === "active" || status === "good" 
    ? "default" 
    : status === "disconnected" 
    ? "destructive" 
    : "secondary";
    
  return <Badge variant={variant} className="capitalize">{status}</Badge>;
}

export default function Dashboard() {
  const { data: weather, isLoading: weatherLoading } = useQuery<WeatherLog>({
    queryKey: ["/api/weather/latest"],
    refetchInterval: 4000,
  });

  const { data: systemStatus, isLoading: statusLoading } = useQuery<SystemStatus>({
    queryKey: ["/api/system/status"],
    refetchInterval: 10000,
  });

  const { data: alerts, isLoading: alertsLoading } = useQuery<WeatherAlert[]>({
    queryKey: ["/api/weather/alerts"],
    refetchInterval: 5000,
  });

  const { data: analytics, isLoading: analyticsLoading } = useQuery<WeatherAnalytics>({
    queryKey: ["/api/weather/analytics"],
    refetchInterval: 30000,
  });

  const { data: logs, isLoading: logsLoading } = useQuery<WeatherLog[]>({
    queryKey: ["/api/weather/logs"],
    refetchInterval: 4000,
  });

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="border-b bg-card">
        <div className="container mx-auto px-4 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-cloudtopia-blue">CloudTopia Weather Dashboard</h1>
              <p className="text-muted-foreground mt-1">Real-time weather monitoring with Azure integration</p>
            </div>
            <div className="flex items-center gap-2">
              <Activity className="h-5 w-5 text-nature-green animate-pulse" />
              <span className="text-sm font-medium">Live Data</span>
            </div>
          </div>
        </div>
      </div>

      <div className="container mx-auto px-4 py-6 space-y-6">
        {/* System Status */}
        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <Shield className="h-5 w-5 text-azure-blue" />
              <CardTitle>System Status</CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            {statusLoading ? (
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                {Array.from({ length: 4 }, (_, i) => (
                  <Skeleton key={i} className="h-16 w-full" />
                ))}
              </div>
            ) : systemStatus ? (
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="space-y-2">
                  <p className="text-sm font-medium">Blob Storage</p>
                  <StatusBadge status={systemStatus.blobStorageStatus} />
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Data Refresh</p>
                  <StatusBadge status={systemStatus.dataRefreshStatus} />
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Data Quality</p>
                  <StatusBadge status={systemStatus.dataQualityStatus} />
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Active Alerts</p>
                  <Badge variant="outline">{systemStatus.activeAlertsCount}</Badge>
                </div>
              </div>
            ) : (
              <p className="text-muted-foreground">Unable to load system status</p>
            )}
          </CardContent>
        </Card>

        {/* Current Weather */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Database className="h-5 w-5 text-azure-blue" />
              Current Weather Conditions
            </CardTitle>
            <CardDescription>
              {weather ? `Last updated: ${new Date(weather.timestamp).toLocaleString()}` : "Loading..."}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {weatherLoading ? (
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                {Array.from({ length: 8 }, (_, i) => (
                  <Skeleton key={i} className="h-20 w-full" />
                ))}
              </div>
            ) : weather ? (
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="space-y-2">
                  <p className="text-sm font-medium">Temperature</p>
                  <p className="text-2xl font-bold text-sunny-yellow">{weather.temperature}°F</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Humidity</p>
                  <p className="text-2xl font-bold text-blue-500">{weather.humidity}%</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Wind Speed</p>
                  <p className="text-2xl font-bold">{weather.windSpeed} mph</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Pressure</p>
                  <p className="text-2xl font-bold">{weather.pressure} inHg</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Conditions</p>
                  <div className="flex items-center gap-2">
                    <WeatherIcon condition={weather.conditions} />
                    <p className="font-medium">{weather.conditions}</p>
                  </div>
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Visibility</p>
                  <p className="text-2xl font-bold">{weather.visibility} mi</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Wind Direction</p>
                  <p className="text-2xl font-bold">{weather.windDirection}</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Location</p>
                  <p className="font-medium text-nature-green">{weather.location}</p>
                </div>
              </div>
            ) : (
              <p className="text-muted-foreground">No weather data available</p>
            )}
          </CardContent>
        </Card>

        {/* Weather Analytics */}
        <Card>
          <CardHeader>
            <CardTitle>Weather Analytics (24h)</CardTitle>
          </CardHeader>
          <CardContent>
            {analyticsLoading ? (
              <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                {Array.from({ length: 6 }, (_, i) => (
                  <Skeleton key={i} className="h-16 w-full" />
                ))}
              </div>
            ) : analytics ? (
              <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                <div className="space-y-2">
                  <p className="text-sm font-medium">Avg Temperature</p>
                  <p className="text-xl font-bold">{analytics.averageTemperature}°F</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Max Temperature</p>
                  <p className="text-xl font-bold text-red-500">{analytics.maxTemperature}°F</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Min Temperature</p>
                  <p className="text-xl font-bold text-blue-500">{analytics.minTemperature}°F</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Avg Humidity</p>
                  <p className="text-xl font-bold">{analytics.averageHumidity}%</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Total Logs</p>
                  <p className="text-xl font-bold text-nature-green">{analytics.totalLogs}</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm font-medium">Extreme Events</p>
                  <p className="text-xl font-bold text-orange-500">{analytics.extremeWeatherEvents}</p>
                </div>
              </div>
            ) : (
              <p className="text-muted-foreground">Unable to load analytics</p>
            )}
          </CardContent>
        </Card>

        {/* Active Alerts */}
        <Card>
          <CardHeader>
            <CardTitle>Active Weather Alerts</CardTitle>
          </CardHeader>
          <CardContent>
            {alertsLoading ? (
              <div className="space-y-3">
                {Array.from({ length: 2 }, (_, i) => (
                  <Skeleton key={i} className="h-16 w-full" />
                ))}
              </div>
            ) : alerts && alerts.length > 0 ? (
              <div className="space-y-3">
                {alerts.map((alert) => (
                  <div key={alert.id} className="flex items-start gap-3 p-3 border rounded-lg">
                    <div className="flex-1 space-y-1">
                      <div className="flex items-center gap-2">
                        <h4 className="font-medium">{alert.title}</h4>
                        <Badge variant={alert.severity === 'warning' ? 'destructive' : 'secondary'}>
                          {alert.severity}
                        </Badge>
                      </div>
                      <p className="text-sm text-muted-foreground">{alert.message}</p>
                      <p className="text-xs text-muted-foreground">
                        {new Date(alert.timestamp).toLocaleString()}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-muted-foreground">No active alerts</p>
            )}
          </CardContent>
        </Card>

        {/* Recent Weather Logs */}
        <Card>
          <CardHeader>
            <CardTitle>Recent Weather Data</CardTitle>
            <CardDescription>Latest weather readings from automated sensors</CardDescription>
          </CardHeader>
          <CardContent>
            {logsLoading ? (
              <div className="space-y-3">
                {Array.from({ length: 5 }, (_, i) => (
                  <Skeleton key={i} className="h-12 w-full" />
                ))}
              </div>
            ) : logs && logs.length > 0 ? (
              <div className="space-y-2 max-h-64 overflow-y-auto">
                {logs.slice(0, 10).map((log) => (
                  <div key={log.id} className="flex items-center justify-between p-2 border rounded text-sm">
                    <div className="flex items-center gap-3">
                      <WeatherIcon condition={log.conditions} />
                      <span className="font-medium">{log.location}</span>
                      <span>{log.temperature}°F</span>
                      <span>{log.humidity}%</span>
                      <span>{log.conditions}</span>
                    </div>
                    <span className="text-muted-foreground">
                      {new Date(log.timestamp).toLocaleTimeString()}
                    </span>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-muted-foreground">No weather data available</p>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
