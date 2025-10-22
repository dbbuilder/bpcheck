import { useState } from 'react';
import type { BloodPressureReading, CreateReadingInput } from '../types';

interface ReadingFormProps {
  reading?: BloodPressureReading | null;
  onSubmit: (data: CreateReadingInput) => void;
  onCancel: () => void;
}

export default function ReadingForm({ reading, onSubmit, onCancel }: ReadingFormProps) {
  const [formData, setFormData] = useState({
    systolic: reading?.systolic || '',
    diastolic: reading?.diastolic || '',
    pulse: reading?.pulse || '',
    notes: reading?.notes || '',
    measuredAt: reading?.measuredAt
      ? new Date(reading.measuredAt).toISOString().slice(0, 16)
      : new Date().toISOString().slice(0, 16),
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    const data: CreateReadingInput = {
      systolic: Number(formData.systolic),
      diastolic: Number(formData.diastolic),
      pulse: formData.pulse ? Number(formData.pulse) : undefined,
      notes: formData.notes || undefined,
      measuredAt: new Date(formData.measuredAt).toISOString(),
    };

    onSubmit(data);
  };

  const getBPCategory = (systolic: number, diastolic: number): { text: string; color: string } => {
    if (systolic < 120 && diastolic < 80) {
      return { text: 'Normal', color: 'text-green-600' };
    } else if (systolic < 130 && diastolic < 80) {
      return { text: 'Elevated', color: 'text-yellow-600' };
    } else if (systolic < 140 || diastolic < 90) {
      return { text: 'High Blood Pressure (Stage 1)', color: 'text-orange-600' };
    } else if (systolic < 180 || diastolic < 120) {
      return { text: 'High Blood Pressure (Stage 2)', color: 'text-red-600' };
    } else {
      return { text: 'Hypertensive Crisis', color: 'text-red-800 font-bold' };
    }
  };

  const category = formData.systolic && formData.diastolic
    ? getBPCategory(Number(formData.systolic), Number(formData.diastolic))
    : null;

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-xl font-semibold text-gray-900 mb-4">
        {reading ? 'Edit Reading' : 'Add New Reading'}
      </h2>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label htmlFor="systolic" className="block text-sm font-medium text-gray-700 mb-1">
              Systolic (Top Number) *
            </label>
            <input
              type="number"
              id="systolic"
              required
              min="70"
              max="250"
              value={formData.systolic}
              onChange={(e) => setFormData({ ...formData, systolic: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="120"
            />
          </div>

          <div>
            <label htmlFor="diastolic" className="block text-sm font-medium text-gray-700 mb-1">
              Diastolic (Bottom Number) *
            </label>
            <input
              type="number"
              id="diastolic"
              required
              min="40"
              max="150"
              value={formData.diastolic}
              onChange={(e) => setFormData({ ...formData, diastolic: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="80"
            />
          </div>
        </div>

        {category && (
          <div className={`p-3 rounded-lg bg-gray-50 border border-gray-200`}>
            <p className="text-sm text-gray-600">
              Category: <span className={`font-semibold ${category.color}`}>{category.text}</span>
            </p>
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label htmlFor="pulse" className="block text-sm font-medium text-gray-700 mb-1">
              Pulse (bpm)
            </label>
            <input
              type="number"
              id="pulse"
              min="30"
              max="200"
              value={formData.pulse}
              onChange={(e) => setFormData({ ...formData, pulse: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="70"
            />
          </div>

          <div>
            <label htmlFor="measuredAt" className="block text-sm font-medium text-gray-700 mb-1">
              Date & Time *
            </label>
            <input
              type="datetime-local"
              id="measuredAt"
              required
              value={formData.measuredAt}
              onChange={(e) => setFormData({ ...formData, measuredAt: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>

        <div>
          <label htmlFor="notes" className="block text-sm font-medium text-gray-700 mb-1">
            Notes
          </label>
          <textarea
            id="notes"
            rows={3}
            value={formData.notes}
            onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            placeholder="Add any notes about this reading (optional)"
          />
        </div>

        <div className="flex gap-3 pt-2">
          <button
            type="submit"
            className="flex-1 bg-blue-600 text-white px-6 py-2 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
          >
            {reading ? 'Update Reading' : 'Save Reading'}
          </button>
          <button
            type="button"
            onClick={onCancel}
            className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg font-semibold hover:bg-gray-50 transition-colors"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}
