import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios';
import { API_BASE_URL } from '../constants';
import { User, BloodPressureReading, ReadingImage, Album } from '../types';

// Clerk auth will be injected via getToken function
let getClerkToken: (() => Promise<string | null>) | null = null;

export function setClerkTokenGetter(getter: () => Promise<string | null>) {
  getClerkToken = getter;
}

// Types for API requests/responses
export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  user: User;
  token: string;
  refreshToken: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  firstName?: string;
  lastName?: string;
}

export interface RegisterResponse {
  user: User;
  token: string;
  refreshToken: string;
}

export interface RefreshTokenRequest {
  refreshToken: string;
}

export interface RefreshTokenResponse {
  token: string;
  refreshToken: string;
}

export interface CreateReadingRequest {
  systolic: number;
  diastolic: number;
  pulse: number;
  notes?: string;
  isFlagged?: boolean;
}

export interface UpdateReadingRequest {
  readingId: string;
  systolic?: number;
  diastolic?: number;
  pulse?: number;
  notes?: string;
  isFlagged?: boolean;
}

export interface UploadImageRequest {
  imageUri: string;
  readingId?: string;
  albumId?: string;
}

class ApiService {
  private client: AxiosInstance;
  private refreshTokenPromise: Promise<string> | null = null;

  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    // Request interceptor - add Clerk auth token
    this.client.interceptors.request.use(
      async (config: InternalAxiosRequestConfig) => {
        if (getClerkToken) {
          const token = await getClerkToken();
          if (token && config.headers) {
            config.headers.Authorization = `Bearer ${token}`;
          }
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor - Clerk handles token refresh automatically
    this.client.interceptors.response.use(
      (response) => response,
      async (error: AxiosError) => {
        // Clerk automatically refreshes tokens, so we just need to handle errors
        if (error.response?.status === 401) {
          // User is not authenticated - Clerk will redirect to login
          console.error('Unauthorized request - user may need to sign in again');
        }
        return Promise.reject(error);
      }
    );
  }

  // Auth is now handled entirely by Clerk - no custom auth endpoints needed

  // User endpoints
  async getProfile(): Promise<User> {
    const response = await this.client.get<User>('/users/profile');
    return response.data;
  }

  async updateProfile(data: Partial<User>): Promise<User> {
    const response = await this.client.put<User>('/users/profile', data);
    return response.data;
  }

  async deleteAccount(): Promise<void> {
    await this.client.delete('/users/profile');
  }

  // Blood Pressure Reading endpoints
  async getReadings(
    page: number = 1,
    pageSize: number = 20,
    startDate?: string,
    endDate?: string
  ): Promise<{ readings: BloodPressureReading[]; totalCount: number }> {
    const response = await this.client.get('/readings', {
      params: { page, pageSize, startDate, endDate },
    });
    return response.data;
  }

  async getReading(readingId: string): Promise<BloodPressureReading> {
    const response = await this.client.get<BloodPressureReading>(`/readings/${readingId}`);
    return response.data;
  }

  async createReading(data: CreateReadingRequest): Promise<BloodPressureReading> {
    const response = await this.client.post<BloodPressureReading>('/readings', data);
    return response.data;
  }

  async updateReading(data: UpdateReadingRequest): Promise<BloodPressureReading> {
    const { readingId, ...updateData } = data;
    const response = await this.client.put<BloodPressureReading>(
      `/readings/${readingId}`,
      updateData
    );
    return response.data;
  }

  async deleteReading(readingId: string): Promise<void> {
    await this.client.delete(`/readings/${readingId}`);
  }

  async getReadingStats(): Promise<{
    averageSystolic: number;
    averageDiastolic: number;
    averagePulse: number;
    totalReadings: number;
  }> {
    const response = await this.client.get('/readings/stats');
    return response.data;
  }

  // Image endpoints
  async uploadImage(data: UploadImageRequest): Promise<ReadingImage> {
    const formData = new FormData();

    // Extract filename from URI
    const uriParts = data.imageUri.split('/');
    const fileName = uriParts[uriParts.length - 1];

    formData.append('image', {
      uri: data.imageUri,
      type: 'image/jpeg',
      name: fileName,
    } as any);

    if (data.readingId) {
      formData.append('readingId', data.readingId);
    }
    if (data.albumId) {
      formData.append('albumId', data.albumId);
    }

    const response = await this.client.post<ReadingImage>('/images/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  }

  async getImage(imageId: string): Promise<ReadingImage> {
    const response = await this.client.get<ReadingImage>(`/images/${imageId}`);
    return response.data;
  }

  async getImagesForReading(readingId: string): Promise<ReadingImage[]> {
    const response = await this.client.get<ReadingImage[]>(`/readings/${readingId}/images`);
    return response.data;
  }

  async deleteImage(imageId: string): Promise<void> {
    await this.client.delete(`/images/${imageId}`);
  }

  async setImageAsFavorite(imageId: string, isFavorite: boolean): Promise<void> {
    await this.client.patch(`/images/${imageId}/favorite`, { isFavorite });
  }

  // Album endpoints
  async getAlbums(): Promise<Album[]> {
    const response = await this.client.get<Album[]>('/albums');
    return response.data;
  }

  async getAlbum(albumId: string): Promise<Album> {
    const response = await this.client.get<Album>(`/albums/${albumId}`);
    return response.data;
  }

  async createAlbum(name: string, description?: string): Promise<Album> {
    const response = await this.client.post<Album>('/albums', { name, description });
    return response.data;
  }

  async updateAlbum(albumId: string, name: string, description?: string): Promise<Album> {
    const response = await this.client.put<Album>(`/albums/${albumId}`, { name, description });
    return response.data;
  }

  async deleteAlbum(albumId: string): Promise<void> {
    await this.client.delete(`/albums/${albumId}`);
  }

  async getAlbumImages(albumId: string): Promise<ReadingImage[]> {
    const response = await this.client.get<ReadingImage[]>(`/albums/${albumId}/images`);
    return response.data;
  }
}

export const apiService = new ApiService();
export default apiService;
