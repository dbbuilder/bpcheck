import axios from 'axios';
import type { AxiosInstance } from 'axios';
import type { BloodPressureReading, CreateReadingInput, UpdateReadingInput, User } from '../types';

const API_URL = import.meta.env.VITE_API_URL || 'https://bpcheck-api.servicevision.io/api';

class ApiService {
  private api: AxiosInstance;

  constructor() {
    this.api = axios.create({
      baseURL: API_URL,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Add request interceptor to include auth token
    this.api.interceptors.request.use(
      async (config) => {
        // Get token from Clerk
        const token = await this.getAuthToken();
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );
  }

  private async getAuthToken(): Promise<string | null> {
    // This will be set by the Clerk provider
    if (typeof window !== 'undefined' && (window as any).__clerk) {
      try {
        const session = await (window as any).__clerk.session;
        return session?.getToken() || null;
      } catch {
        return null;
      }
    }
    return null;
  }

  // Health Check
  async healthCheck() {
    const response = await this.api.get('/authtest/health');
    return response.data;
  }

  // User endpoints
  async getCurrentUser(): Promise<User> {
    const response = await this.api.get('/authtest/me');
    return response.data;
  }

  // Blood Pressure Reading endpoints
  async getReadings(): Promise<BloodPressureReading[]> {
    const response = await this.api.get('/bloodpressure');
    return response.data;
  }

  async getReading(id: string): Promise<BloodPressureReading> {
    const response = await this.api.get(`/bloodpressure/${id}`);
    return response.data;
  }

  async createReading(reading: CreateReadingInput): Promise<BloodPressureReading> {
    const response = await this.api.post('/bloodpressure', reading);
    return response.data;
  }

  async updateReading(id: string, reading: UpdateReadingInput): Promise<BloodPressureReading> {
    const response = await this.api.put(`/bloodpressure/${id}`, reading);
    return response.data;
  }

  async deleteReading(id: string): Promise<void> {
    await this.api.delete(`/bloodpressure/${id}`);
  }
}

export const apiService = new ApiService();
