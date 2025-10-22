import type { BloodPressureReading } from '../types';
import { format } from 'date-fns';

interface ReadingsListProps {
  readings: BloodPressureReading[];
  onEdit: (reading: BloodPressureReading) => void;
  onDelete: (id: string) => void;
}

export default function ReadingsList({ readings, onEdit, onDelete }: ReadingsListProps) {
  const getBPColor = (systolic: number, diastolic: number): string => {
    if (systolic < 120 && diastolic < 80) return 'bg-green-50 border-green-200';
    if (systolic < 130 && diastolic < 80) return 'bg-yellow-50 border-yellow-200';
    if (systolic < 140 || diastolic < 90) return 'bg-orange-50 border-orange-200';
    if (systolic < 180 || diastolic < 120) return 'bg-red-50 border-red-200';
    return 'bg-red-100 border-red-300';
  };

  const getBPBadge = (systolic: number, diastolic: number) => {
    if (systolic < 120 && diastolic < 80) {
      return <span className="px-2 py-1 text-xs font-semibold rounded bg-green-100 text-green-800">Normal</span>;
    }
    if (systolic < 130 && diastolic < 80) {
      return <span className="px-2 py-1 text-xs font-semibold rounded bg-yellow-100 text-yellow-800">Elevated</span>;
    }
    if (systolic < 140 || diastolic < 90) {
      return <span className="px-2 py-1 text-xs font-semibold rounded bg-orange-100 text-orange-800">Stage 1</span>;
    }
    if (systolic < 180 || diastolic < 120) {
      return <span className="px-2 py-1 text-xs font-semibold rounded bg-red-100 text-red-800">Stage 2</span>;
    }
    return <span className="px-2 py-1 text-xs font-semibold rounded bg-red-200 text-red-900">Crisis</span>;
  };

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden">
      <div className="px-6 py-4 border-b border-gray-200">
        <h2 className="text-xl font-semibold text-gray-900">Your Readings</h2>
        <p className="text-sm text-gray-600 mt-1">{readings.length} total readings</p>
      </div>

      <div className="divide-y divide-gray-200">
        {readings.map((reading) => (
          <div
            key={reading.id}
            className={`p-6 hover:bg-gray-50 transition-colors border-l-4 ${getBPColor(reading.systolic, reading.diastolic)}`}
          >
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <div className="text-3xl font-bold text-gray-900">
                    {reading.systolic}/{reading.diastolic}
                  </div>
                  {getBPBadge(reading.systolic, reading.diastolic)}
                </div>

                <div className="space-y-1 text-sm text-gray-600">
                  <div className="flex items-center gap-2">
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    <span>{format(new Date(reading.measuredAt), 'PPp')}</span>
                  </div>

                  {reading.pulse && (
                    <div className="flex items-center gap-2">
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                      </svg>
                      <span>Pulse: {reading.pulse} bpm</span>
                    </div>
                  )}

                  {reading.notes && (
                    <div className="flex items-start gap-2 mt-2">
                      <svg className="w-4 h-4 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z" />
                      </svg>
                      <span className="text-gray-700">{reading.notes}</span>
                    </div>
                  )}
                </div>
              </div>

              <div className="flex gap-2 sm:flex-col">
                <button
                  onClick={() => onEdit(reading)}
                  className="flex-1 sm:flex-none px-4 py-2 text-sm text-blue-600 hover:bg-blue-50 rounded-lg font-medium transition-colors"
                >
                  Edit
                </button>
                <button
                  onClick={() => onDelete(reading.id)}
                  className="flex-1 sm:flex-none px-4 py-2 text-sm text-red-600 hover:bg-red-50 rounded-lg font-medium transition-colors"
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
