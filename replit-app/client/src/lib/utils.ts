import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatTimestamp(timestamp: string | Date): string {
  return new Date(timestamp).toLocaleString();
}

export function formatDate(timestamp: string | Date): string {
  return new Date(timestamp).toLocaleDateString();
}

export function getStatusColor(status: string): string {
  switch (status.toLowerCase()) {
    case 'normal':
    case 'good':
    case 'operational':
      return 'text-green-600';
    case 'warning':
    case 'watch':
      return 'text-yellow-600';
    case 'critical':
    case 'error':
      return 'text-red-600';
    default:
      return 'text-gray-600';
  }
}

export function getSeverityColor(severity: string): string {
  switch (severity.toLowerCase()) {
    case 'info':
      return 'text-blue-600';
    case 'warning':
      return 'text-yellow-600';
    case 'critical':
      return 'text-red-600';
    default:
      return 'text-gray-600';
  }
}
