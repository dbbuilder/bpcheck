// TypeScript type definitions for Blood Pressure Monitor

export interface User {
  userId: string;
  email: string;
  firstName?: string;
  lastName?: string;
  dateOfBirth?: string;
  storageQuotaMB: number;
  currentStorageUsedMB: number;
  isActive: boolean;
  lastLoginDate?: string;
  createdDate: string;
  modifiedDate: string;
}

export interface BloodPressureReading {
  readingId: string;
  userId: string;
  primaryImageId?: string;
  systolicValue: number;
  diastolicValue: number;
  pulseValue?: number;
  readingDate: string;
  notes?: string;
  isManualEntry: boolean;
  ocrConfidence?: number;
  isFlagged: boolean;
  createdDate: string;
  modifiedDate: string;
}

export interface ReadingImage {
  imageId: string;
  readingId?: string;
  userId: string;
  originalBlobUrl: string;
  thumbnail150Url?: string;
  thumbnail400Url?: string;
  fileSizeMB: number;
  imageFormat: string;
  width: number;
  height: number;
  isFavorite: boolean;
  lastViewedDate?: string;
  uploadDate: string;
}

export interface Album {
  albumId: string;
  userId: string;
  albumName: string;
  description?: string;
  imageCount: number;
  createdDate: string;
  modifiedDate: string;
}

export interface AuthState {
  user: User | null;
  token: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  email: string;
  password: string;
  firstName?: string;
  lastName?: string;
}

export interface AuthResponse {
  user: User;
  token: string;
  refreshToken: string;
}

export interface ApiError {
  message: string;
  statusCode: number;
  errors?: Record<string, string[]>;
}

export type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
  Onboarding: undefined;
};

export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
};

export type MainTabParamList = {
  Dashboard: undefined;
  Camera: undefined;
  Readings: undefined;
  Settings: undefined;
};
