import { useState, useEffect } from 'react';
import { useUser, UserButton } from '@clerk/clerk-react';
import { apiService } from '../services/api';
import type { BloodPressureReading } from '../types';
import ReadingForm from '../components/ReadingForm';
import ReadingsList from '../components/ReadingsList';
import ReadingsChart from '../components/ReadingsChart';

export default function Dashboard() {
  const { user } = useUser();
  const [readings, setReadings] = useState<BloodPressureReading[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [selectedReading, setSelectedReading] = useState<BloodPressureReading | null>(null);

  useEffect(() => {
    loadReadings();
  }, []);

  const loadReadings = async () => {
    try {
      setLoading(true);
      const data = await apiService.getReadings();
      setReadings(data.sort((a, b) =>
        new Date(b.measuredAt).getTime() - new Date(a.measuredAt).getTime()
      ));
    } catch (error) {
      console.error('Failed to load readings:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateReading = async (data: any) => {
    try {
      await apiService.createReading(data);
      await loadReadings();
      setShowForm(false);
    } catch (error) {
      console.error('Failed to create reading:', error);
      alert('Failed to create reading. Please try again.');
    }
  };

  const handleUpdateReading = async (id: string, data: any) => {
    try {
      await apiService.updateReading(id, data);
      await loadReadings();
      setSelectedReading(null);
      setShowForm(false);
    } catch (error) {
      console.error('Failed to update reading:', error);
      alert('Failed to update reading. Please try again.');
    }
  };

  const handleDeleteReading = async (id: string) => {
    if (!confirm('Are you sure you want to delete this reading?')) return;

    try {
      await apiService.deleteReading(id);
      await loadReadings();
    } catch (error) {
      console.error('Failed to delete reading:', error);
      alert('Failed to delete reading. Please try again.');
    }
  };

  const handleEditReading = (reading: BloodPressureReading) => {
    setSelectedReading(reading);
    setShowForm(true);
  };

  const handleCancelForm = () => {
    setShowForm(false);
    setSelectedReading(null);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-2xl font-bold text-blue-600">Blood Pressure Monitor</h1>
              <p className="text-sm text-gray-600">Welcome, {user?.firstName || user?.emailAddresses[0]?.emailAddress}</p>
            </div>
            <UserButton afterSignOutUrl="/login" />
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Action Bar */}
        <div className="mb-6">
          <button
            onClick={() => setShowForm(!showForm)}
            className="bg-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors shadow-md"
          >
            {showForm ? 'Cancel' : '+ Add New Reading'}
          </button>
        </div>

        {/* Add/Edit Form */}
        {showForm && (
          <div className="mb-8">
            <ReadingForm
              reading={selectedReading}
              onSubmit={selectedReading
                ? (data) => handleUpdateReading(selectedReading.id, data)
                : handleCreateReading
              }
              onCancel={handleCancelForm}
            />
          </div>
        )}

        {loading ? (
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            <p className="mt-4 text-gray-600">Loading your readings...</p>
          </div>
        ) : (
          <>
            {/* Chart */}
            {readings.length > 0 && (
              <div className="mb-8">
                <ReadingsChart readings={readings} />
              </div>
            )}

            {/* Readings List */}
            {readings.length > 0 ? (
              <ReadingsList
                readings={readings}
                onEdit={handleEditReading}
                onDelete={handleDeleteReading}
              />
            ) : (
              <div className="bg-white rounded-lg shadow-sm p-12 text-center">
                <svg
                  className="mx-auto h-16 w-16 text-gray-400 mb-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                  />
                </svg>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">No readings yet</h3>
                <p className="text-gray-600 mb-4">Start tracking your blood pressure by adding your first reading.</p>
                <button
                  onClick={() => setShowForm(true)}
                  className="text-blue-600 hover:text-blue-700 font-semibold"
                >
                  Add your first reading →
                </button>
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}
