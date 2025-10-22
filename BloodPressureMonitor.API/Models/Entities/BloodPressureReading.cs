using System;

namespace BloodPressureMonitor.API.Models.Entities
{
    /// <summary>
    /// Represents a blood pressure and heart rate reading
    /// </summary>
    public class BloodPressureReading
    {
        /// <summary>
        /// Unique identifier for the reading
        /// </summary>
        public Guid ReadingId { get; set; }

        /// <summary>
        /// User who owns this reading
        /// </summary>
        public Guid UserId { get; set; }

        /// <summary>
        /// Primary image associated with this reading
        /// </summary>
        public Guid? PrimaryImageId { get; set; }

        /// <summary>
        /// Systolic blood pressure value (mmHg)
        /// Range: 70-250
        /// </summary>
        public int SystolicValue { get; set; }

        /// <summary>
        /// Diastolic blood pressure value (mmHg)
        /// Range: 40-150
        /// </summary>
        public int DiastolicValue { get; set; }

        /// <summary>
        /// Pulse/heart rate value (BPM)
        /// Range: 30-220
        /// Optional - may not be captured by all devices
        /// </summary>
        public int? PulseValue { get; set; }

        /// <summary>
        /// Date and time when the reading was taken
        /// </summary>
        public DateTime ReadingDate { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Optional notes about the reading
        /// </summary>
        public string? Notes { get; set; }

        /// <summary>
        /// Indicates if the reading was entered manually (vs OCR)
        /// </summary>
        public bool IsManualEntry { get; set; } = false;

        /// <summary>
        /// OCR confidence score (0-100)
        /// Null for manual entries
        /// </summary>
        public decimal? OcrConfidence { get; set; }

        /// <summary>
        /// Indicates if reading values are outside normal ranges
        /// </summary>
        public bool IsFlagged { get; set; } = false;

        /// <summary>
        /// Record creation timestamp
        /// </summary>
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Last modification timestamp
        /// </summary>
        public DateTime ModifiedDate { get; set; } = DateTime.UtcNow;
    }
}
