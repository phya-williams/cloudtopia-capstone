import { pgTable, text, serial, real, timestamp, integer } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

export const weatherLogs = pgTable("weather_logs", {
  id: serial("id").primaryKey(),
  timestamp: timestamp("timestamp").notNull(),
  temperature: real("temperature").notNull(),
  humidity: integer("humidity").notNull(),
  windSpeed: real("wind_speed").notNull(),
  windDirection: text("wind_direction").notNull(),
  visibility: real("visibility").notNull(),
  pressure: real("pressure").notNull(),
  conditions: text("conditions").notNull(),
  status: text("status").notNull().default("Normal"),
  location: text("location").notNull().default("Main Plaza"),
});

export const weatherAlerts = pgTable("weather_alerts", {
  id: serial("id").primaryKey(),
  type: text("type").notNull(),
  title: text("title").notNull(),
  message: text("message").notNull(),
  severity: text("severity").notNull(),
  timestamp: timestamp("timestamp").notNull(),
  isActive: integer("is_active").notNull().default(1),
});

export const insertWeatherLogSchema = createInsertSchema(weatherLogs).omit({
  id: true,
});

export const insertWeatherAlertSchema = createInsertSchema(weatherAlerts).omit({
  id: true,
});

export type InsertWeatherLog = z.infer<typeof insertWeatherLogSchema>;
export type WeatherLog = typeof weatherLogs.$inferSelect;
export type InsertWeatherAlert = z.infer<typeof insertWeatherAlertSchema>;
export type WeatherAlert = typeof weatherAlerts.$inferSelect;

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: text("username").notNull().unique(),
  password: text("password").notNull(),
});

export const insertUserSchema = createInsertSchema(users).pick({
  username: true,
  password: true,
});

export type InsertUser = z.infer<typeof insertUserSchema>;
export type User = typeof users.$inferSelect;
