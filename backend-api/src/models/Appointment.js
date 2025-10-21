const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  // Patient Information
  patient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Patient is required']
  },
  
  // Doctor Information
  doctor: {
    name: {
      type: String,
      required: [true, 'Doctor name is required'],
      trim: true
    },
    specialization: {
      type: String,
      required: [true, 'Doctor specialization is required'],
      trim: true
    },
    hospital: {
      type: String,
      required: [true, 'Hospital name is required'],
      trim: true
    },
    hospitalId: {
      type: String,
      required: [true, 'Hospital ID is required']
    },
    experience: {
      type: Number,
      min: [0, 'Experience cannot be negative']
    },
    rating: {
      type: Number,
      min: [0, 'Rating cannot be negative'],
      max: [5, 'Rating cannot exceed 5']
    },
    fees: {
      consultation: {
        type: Number,
        required: [true, 'Consultation fee is required'],
        min: [0, 'Fee cannot be negative']
      },
      currency: {
        type: String,
        default: 'INR'
      }
    },
    avatar: String,
    languages: [String]
  },
  
  // Appointment Details
  appointmentDate: {
    type: Date,
    required: [true, 'Appointment date is required'],
    validate: {
      validator: function(v) {
        return v > new Date();
      },
      message: 'Appointment date must be in the future'
    }
  },
  appointmentTime: {
    type: String,
    required: [true, 'Appointment time is required'],
    match: [/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Please enter time in HH:MM format']
  },
  duration: {
    type: Number,
    default: 30, // in minutes
    min: [15, 'Minimum duration is 15 minutes'],
    max: [120, 'Maximum duration is 120 minutes']
  },
  
  // Appointment Type
  type: {
    type: String,
    enum: ['video_call', 'in_person', 'phone_call'],
    required: [true, 'Appointment type is required']
  },
  
  // Status Management
  status: {
    type: String,
    enum: ['scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show'],
    default: 'scheduled'
  },
  
  // Patient Information
  symptoms: {
    type: String,
    maxlength: [1000, 'Symptoms description cannot exceed 1000 characters']
  },
  notes: {
    type: String,
    maxlength: [2000, 'Notes cannot exceed 2000 characters']
  },
  
  // Payment Information
  payment: {
    amount: {
      type: Number,
      required: [true, 'Payment amount is required'],
      min: [0, 'Amount cannot be negative']
    },
    currency: {
      type: String,
      default: 'INR'
    },
    status: {
      type: String,
      enum: ['pending', 'completed', 'failed', 'refunded'],
      default: 'pending'
    },
    paymentId: String,
    orderId: String,
    signature: String,
    method: {
      type: String,
      enum: ['razorpay', 'upi', 'card', 'netbanking', 'wallet'],
      default: 'razorpay'
    },
    paidAt: Date,
    refundId: String,
    refundedAt: Date
  },
  
  // Video Call Information (for video appointments)
  videoCall: {
    roomId: String,
    meetingUrl: String,
    startedAt: Date,
    endedAt: Date,
    duration: Number, // actual duration in minutes
    participants: [{
      userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      joinedAt: Date,
      leftAt: Date,
      role: {
        type: String,
        enum: ['patient', 'doctor'],
        required: true
      }
    }]
  },
  
  // Prescription and Follow-up
  prescription: {
    medicines: [{
      name: String,
      dosage: String,
      frequency: String,
      duration: String,
      instructions: String
    }],
    tests: [String],
    advice: String,
    followUpDate: Date,
    followUpRequired: {
      type: Boolean,
      default: false
    }
  },
  
  // Rating and Feedback
  rating: {
    patientRating: {
      rating: {
        type: Number,
        min: [1, 'Rating must be at least 1'],
        max: [5, 'Rating cannot exceed 5']
      },
      feedback: String,
      ratedAt: Date
    },
    doctorRating: {
      rating: {
        type: Number,
        min: [1, 'Rating must be at least 1'],
        max: [5, 'Rating cannot exceed 5']
      },
      feedback: String,
      ratedAt: Date
    }
  },
  
  // Reminders
  reminders: [{
    type: {
      type: String,
      enum: ['appointment', 'follow_up', 'medicine'],
      required: true
    },
    scheduledAt: {
      type: Date,
      required: true
    },
    sent: {
      type: Boolean,
      default: false
    },
    sentAt: Date
  }],
  
  // Cancellation
  cancellation: {
    cancelledBy: {
      type: String,
      enum: ['patient', 'doctor', 'system']
    },
    reason: String,
    cancelledAt: Date,
    refundProcessed: {
      type: Boolean,
      default: false
    }
  },
  
  // Medical Records Reference
  medicalRecords: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'MedicalRecord'
  }]
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for appointment date time
appointmentSchema.virtual('appointmentDateTime').get(function() {
  if (!this.appointmentDate || !this.appointmentTime) return null;
  
  const date = new Date(this.appointmentDate);
  const [hours, minutes] = this.appointmentTime.split(':');
  date.setHours(parseInt(hours), parseInt(minutes));
  return date;
});

// Virtual for status color coding
appointmentSchema.virtual('statusColor').get(function() {
  const colors = {
    scheduled: '#FFA500',
    confirmed: '#008000',
    in_progress: '#0000FF',
    completed: '#006400',
    cancelled: '#FF0000',
    no_show: '#8B0000'
  };
  return colors[this.status] || '#808080';
});

// Indexes for better performance
appointmentSchema.index({ patient: 1, appointmentDate: 1 });
appointmentSchema.index({ 'doctor.hospitalId': 1, appointmentDate: 1 });
appointmentSchema.index({ status: 1 });
appointmentSchema.index({ appointmentDate: 1 });
appointmentSchema.index({ 'payment.status': 1 });

// Pre-save middleware
appointmentSchema.pre('save', function(next) {
  // Generate room ID for video calls
  if (this.type === 'video_call' && !this.videoCall.roomId) {
    this.videoCall.roomId = `room_${this._id}_${Date.now()}`;
  }
  
  // Set payment amount based on doctor fees
  if (!this.payment.amount && this.doctor.fees.consultation) {
    this.payment.amount = this.doctor.fees.consultation;
  }
  
  next();
});

// Static methods
appointmentSchema.statics.findUpcoming = function(patientId, limit = 10) {
  return this.find({
    patient: patientId,
    appointmentDate: { $gte: new Date() },
    status: { $in: ['scheduled', 'confirmed'] }
  })
  .sort({ appointmentDate: 1 })
  .limit(limit)
  .populate('patient', 'name email phone avatar');
};

appointmentSchema.statics.findByDoctor = function(hospitalId, doctorName, startDate, endDate) {
  const query = {
    'doctor.hospitalId': hospitalId,
    'doctor.name': doctorName
  };
  
  if (startDate && endDate) {
    query.appointmentDate = {
      $gte: new Date(startDate),
      $lte: new Date(endDate)
    };
  }
  
  return this.find(query)
    .sort({ appointmentDate: 1 })
    .populate('patient', 'name email phone avatar');
};

// Instance methods
appointmentSchema.methods.canCancel = function() {
  const now = new Date();
  const appointmentDateTime = this.appointmentDateTime;
  
  if (!appointmentDateTime) return false;
  
  // Can cancel if appointment is more than 2 hours away
  const timeDiff = appointmentDateTime.getTime() - now.getTime();
  const hoursDiff = timeDiff / (1000 * 60 * 60);
  
  return hoursDiff > 2 && this.status === 'scheduled';
};

appointmentSchema.methods.calculateRefund = function() {
  if (!this.canCancel()) return 0;
  
  const now = new Date();
  const appointmentDateTime = this.appointmentDateTime;
  const timeDiff = appointmentDateTime.getTime() - now.getTime();
  const hoursDiff = timeDiff / (1000 * 60 * 60);
  
  // Refund policy
  if (hoursDiff > 24) return this.payment.amount; // 100% refund
  if (hoursDiff > 12) return this.payment.amount * 0.75; // 75% refund
  if (hoursDiff > 2) return this.payment.amount * 0.50; // 50% refund
  
  return 0;
};

module.exports = mongoose.model('Appointment', appointmentSchema);