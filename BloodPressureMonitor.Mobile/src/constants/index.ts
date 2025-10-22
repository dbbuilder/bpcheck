// Constants for Blood Pressure Monitor

// API Configuration
export const API_BASE_URL = process.env.EXPO_PUBLIC_API_URL || 'https://localhost:5001/api';

// Colors (matching tailwind.config.js)
export const COLORS = {
  primary: {
    50: '#eff6ff',
    100: '#dbeafe',
    200: '#bfdbfe',
    300: '#93c5fd',
    400: '#60a5fa',
    500: '#3b82f6',
    600: '#2563eb',
    700: '#1d4ed8',
    800: '#1e40af',
    900: '#1e3a8a',
  },
  medical: {
    heart: '#ef4444',
    pulse: '#f59e0b',
    safe: '#10b981',
    warning: '#f59e0b',
    danger: '#ef4444',
  },
  neutral: {
    50: '#f9fafb',
    100: '#f3f4f6',
    200: '#e5e7eb',
    300: '#d1d5db',
    400: '#9ca3af',
    500: '#6b7280',
    600: '#4b5563',
    700: '#374151',
    800: '#1f2937',
    900: '#111827',
  },
  success: '#10b981',
  error: '#ef4444',
  warning: '#f59e0b',
  info: '#3b82f6',
};

// Blood Pressure Ranges
export const BP_RANGES = {
  systolic: {
    min: 70,
    max: 250,
    normal: { min: 90, max: 120 },
    elevated: { min: 121, max: 129 },
    high: { min: 130, max: 139 },
    crisis: { min: 180, max: 250 },
  },
  diastolic: {
    min: 40,
    max: 150,
    normal: { min: 60, max: 80 },
    elevated: { min: 81, max: 89 },
    high: { min: 90, max: 99 },
    crisis: { min: 120, max: 150 },
  },
  pulse: {
    min: 30,
    max: 220,
    normal: { min: 60, max: 100 },
  },
};

// Storage Keys
export const STORAGE_KEYS = {
  AUTH_TOKEN: 'auth_token',
  REFRESH_TOKEN: 'refresh_token',
  USER_DATA: 'user_data',
  THEME: 'app_theme',
  BIOMETRIC_ENABLED: 'biometric_enabled',
};

// Validation Rules
export const VALIDATION = {
  email: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  password: {
    minLength: 8,
    requireUppercase: true,
    requireLowercase: true,
    requireNumber: true,
    requireSpecialChar: true,
  },
};

// Image Settings
export const IMAGE_SETTINGS = {
  maxSizeMB: 5,
  minWidth: 640,
  minHeight: 480,
  thumbnailSizes: {
    small: 150,
    medium: 400,
  },
  formats: ['JPEG', 'PNG', 'HEIC'],
};

// OCR Settings
export const OCR_SETTINGS = {
  confidenceThreshold: 70,
  localOCRFirst: true,
  fallbackToCloud: true,
};

// Animation Durations (ms)
export const ANIMATION = {
  fast: 150,
  normal: 300,
  slow: 500,
};

// Pagination
export const PAGINATION = {
  readingsPerPage: 20,
  imagesPerPage: 50,
};
