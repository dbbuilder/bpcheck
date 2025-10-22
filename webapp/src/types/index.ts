export interface User {
  id: string;
  email: string;
  firstName?: string;
  lastName?: string;
  clerkUserId: string;
}

export interface BloodPressureReading {
  id: string;
  userId: string;
  systolic: number;
  diastolic: number;
  pulse?: number;
  notes?: string;
  measuredAt: string;
  createdAt: string;
  photoUrl?: string;
}

export interface CreateReadingInput {
  systolic: number;
  diastolic: number;
  pulse?: number;
  notes?: string;
  measuredAt?: string;
}

export interface UpdateReadingInput {
  systolic?: number;
  diastolic?: number;
  pulse?: number;
  notes?: string;
  measuredAt?: string;
}

export interface ApiError {
  message: string;
  status: number;
}
