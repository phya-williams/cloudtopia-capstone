import type { User, InsertUser, WeatherLog, InsertWeatherLog, WeatherAlert, InsertWeatherAlert } from "../shared/schema";

export interface IStorage {
  getUser(id: number): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  
  getWeatherLogs(limit?: number): Promise<WeatherLog[]>;
  createWeatherLog(log: InsertWeatherLog): Promise<WeatherLog>;
  getLatestWeatherLog(): Promise<WeatherLog | undefined>;
  
  getActiveWeatherAlerts(): Promise<WeatherAlert[]>;
  createWeatherAlert(alert: InsertWeatherAlert): Promise<WeatherAlert>;
  deactivateWeatherAlert(id: number): Promise<void>;
}

export class MemStorage implements IStorage {
  private users: Map<number, User>;
  private weatherLogs: Map<number, WeatherLog>;
  private weatherAlerts: Map<number, WeatherAlert>;
  private currentUserId: number;
  private currentWeatherLogId: number;
  private currentWeatherAlertId: number;

  constructor() {
    this.users = new Map();
    this.weatherLogs = new Map();
    this.weatherAlerts = new Map();
    this.currentUserId = 1;
    this.currentWeatherLogId = 1;
    this.currentWeatherAlertId = 1;
  }

  async getUser(id: number): Promise<User | undefined> {
    return this.users.get(id);
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    for (const user of this.users.values()) {
      if (user.username === username) {
        return user;
      }
    }
    return undefined;
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const id = this.currentUserId++;
    const user: User = { ...insertUser, id };
    this.users.set(id, user);
    return user;
  }

  async getWeatherLogs(limit: number = 50): Promise<WeatherLog[]> {
    const logs = Array.from(this.weatherLogs.values())
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
      .slice(0, limit);
    return logs;
  }

  async createWeatherLog(insertLog: InsertWeatherLog): Promise<WeatherLog> {
    const id = this.currentWeatherLogId++;
    const log: WeatherLog = { 
      ...insertLog, 
      id,
      timestamp: insertLog.timestamp || new Date()
    };
    this.weatherLogs.set(id, log);
    
    // Keep only last 1000 logs to prevent memory issues
    if (this.weatherLogs.size > 1000) {
      const oldestId = Math.min(...Array.from(this.weatherLogs.keys()));
      this.weatherLogs.delete(oldestId);
    }
    
    return log;
  }

  async getLatestWeatherLog(): Promise<WeatherLog | undefined> {
    if (this.weatherLogs.size === 0) return undefined;
    
    return Array.from(this.weatherLogs.values())
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())[0];
  }

  async getActiveWeatherAlerts(): Promise<WeatherAlert[]> {
    return Array.from(this.weatherAlerts.values())
      .filter(alert => alert.isActive === 1)
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
  }

  async createWeatherAlert(insertAlert: InsertWeatherAlert): Promise<WeatherAlert> {
    const id = this.currentWeatherAlertId++;
    const alert: WeatherAlert = { 
      ...insertAlert, 
      id,
      timestamp: insertAlert.timestamp || new Date(),
      isActive: insertAlert.isActive || 1
    };
    this.weatherAlerts.set(id, alert);
    return alert;
  }

  async deactivateWeatherAlert(id: number): Promise<void> {
    const alert = this.weatherAlerts.get(id);
    if (alert) {
      alert.isActive = 0;
      this.weatherAlerts.set(id, alert);
    }
  }
}

export const storage = new MemStorage();
