import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import type { BloodPressureReading } from '../types';
import { format } from 'date-fns';

interface ReadingsChartProps {
  readings: BloodPressureReading[];
}

export default function ReadingsChart({ readings }: ReadingsChartProps) {
  // Prepare data for chart (last 30 readings, most recent first)
  const chartData = readings
    .slice(0, 30)
    .reverse()
    .map((reading) => ({
      date: format(new Date(reading.measuredAt), 'MM/dd'),
      systolic: reading.systolic,
      diastolic: reading.diastolic,
      pulse: reading.pulse || 0,
    }));

  const CustomTooltip = ({ active, payload }: any) => {
    if (active && payload && payload.length) {
      return (
        <div className="bg-white p-3 rounded-lg shadow-lg border border-gray-200">
          <p className="font-semibold mb-1">{payload[0].payload.date}</p>
          <p className="text-sm text-red-600">Systolic: {payload[0].value}</p>
          <p className="text-sm text-blue-600">Diastolic: {payload[1].value}</p>
          {payload[2] && payload[2].value > 0 && (
            <p className="text-sm text-purple-600">Pulse: {payload[2].value} bpm</p>
          )}
        </div>
      );
    }
    return null;
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <h2 className="text-xl font-semibold text-gray-900 mb-4">Blood Pressure Trends</h2>
      <p className="text-sm text-gray-600 mb-6">
        Showing your last {Math.min(readings.length, 30)} readings
      </p>

      <ResponsiveContainer width="100%" height={400}>
        <LineChart data={chartData} margin={{ top: 5, right: 30, left: 0, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
          <XAxis
            dataKey="date"
            stroke="#6b7280"
            style={{ fontSize: '12px' }}
          />
          <YAxis
            stroke="#6b7280"
            style={{ fontSize: '12px' }}
            domain={[40, 200]}
          />
          <Tooltip content={<CustomTooltip />} />
          <Legend
            wrapperStyle={{ paddingTop: '20px' }}
            iconType="line"
          />
          <Line
            type="monotone"
            dataKey="systolic"
            stroke="#ef4444"
            strokeWidth={2}
            dot={{ fill: '#ef4444', strokeWidth: 2, r: 4 }}
            activeDot={{ r: 6 }}
            name="Systolic"
          />
          <Line
            type="monotone"
            dataKey="diastolic"
            stroke="#3b82f6"
            strokeWidth={2}
            dot={{ fill: '#3b82f6', strokeWidth: 2, r: 4 }}
            activeDot={{ r: 6 }}
            name="Diastolic"
          />
          {chartData.some(d => d.pulse > 0) && (
            <Line
              type="monotone"
              dataKey="pulse"
              stroke="#a855f7"
              strokeWidth={2}
              dot={{ fill: '#a855f7', strokeWidth: 2, r: 4 }}
              activeDot={{ r: 6 }}
              name="Pulse"
            />
          )}
        </LineChart>
      </ResponsiveContainer>

      {/* Reference Lines */}
      <div className="mt-6 grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
        <div className="p-3 bg-green-50 rounded-lg border border-green-200">
          <p className="font-semibold text-green-800">Normal</p>
          <p className="text-green-600">&lt;120/80</p>
        </div>
        <div className="p-3 bg-yellow-50 rounded-lg border border-yellow-200">
          <p className="font-semibold text-yellow-800">Elevated</p>
          <p className="text-yellow-600">120-129/&lt;80</p>
        </div>
        <div className="p-3 bg-orange-50 rounded-lg border border-orange-200">
          <p className="font-semibold text-orange-800">Stage 1</p>
          <p className="text-orange-600">130-139/80-89</p>
        </div>
        <div className="p-3 bg-red-50 rounded-lg border border-red-200">
          <p className="font-semibold text-red-800">Stage 2</p>
          <p className="text-red-600">≥140/≥90</p>
        </div>
      </div>
    </div>
  );
}
