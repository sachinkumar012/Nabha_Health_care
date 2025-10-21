const mongoose = require('mongoose');

const medicalRecordSchema = new mongoose.Schema({
  // Patient Information
  patient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Patient is required']
  },
  
  // Record Identification
  recordId: {
    type: String,
    unique: true,
    required: true
  },
  recordType: {
    type: String,
    enum: [
      'consultation',
      'lab_report',
      'prescription',
      'diagnostic_report',
      'surgery_report',
      'vaccination',
      'health_checkup',
      'emergency_visit',
      'follow_up',
      'other'
    ],
    required: [true, 'Record type is required']
  },
  
  // Healthcare Provider Information
  provider: {
    doctorName: {
      type: String,
      required: function() {
        return ['consultation', 'prescription', 'surgery_report', 'follow_up'].includes(this.recordType);
      }
    },
    doctorSpecialization: String,
    hospitalName: {
      type: String,
      required: [true, 'Hospital/Provider name is required']
    },
    hospitalId: String,
    department: String,
    licenseNumber: String
  },
  
  // Visit Information
  visitDate: {
    type: Date,
    required: [true, 'Visit date is required'],
    default: Date.now
  },
  visitType: {
    type: String,
    enum: ['emergency', 'scheduled', 'walk_in', 'follow_up', 'routine_checkup'],
    default: 'scheduled'
  },
  
  // Clinical Information
  chiefComplaint: {
    type: String,
    maxlength: [1000, 'Chief complaint cannot exceed 1000 characters']
  },
  presentIllness: {
    type: String,
    maxlength: [2000, 'Present illness description cannot exceed 2000 characters']
  },
  pastHistory: {
    medicalHistory: [String],
    surgicalHistory: [String],
    familyHistory: [String],
    allergies: [{
      allergen: String,
      reaction: String,
      severity: {
        type: String,
        enum: ['mild', 'moderate', 'severe'],
        default: 'mild'
      }
    }],
    medications: [String],
    socialHistory: {
      smoking: {
        type: String,
        enum: ['never', 'former', 'current']
      },
      alcohol: {
        type: String,
        enum: ['never', 'occasional', 'regular', 'heavy']
      },
      exercise: String,
      diet: String
    }
  },
  
  // Physical Examination
  vitalSigns: {
    bloodPressure: {
      systolic: {
        type: Number,
        min: [50, 'Systolic BP too low'],
        max: [300, 'Systolic BP too high']
      },
      diastolic: {
        type: Number,
        min: [30, 'Diastolic BP too low'],
        max: [200, 'Diastolic BP too high']
      },
      unit: {
        type: String,
        default: 'mmHg'
      }
    },
    heartRate: {
      value: {
        type: Number,
        min: [20, 'Heart rate too low'],
        max: [250, 'Heart rate too high']
      },
      unit: {
        type: String,
        default: 'bpm'
      }
    },
    temperature: {
      value: {
        type: Number,
        min: [90, 'Temperature too low'],
        max: [110, 'Temperature too high']
      },
      unit: {
        type: String,
        enum: ['F', 'C'],
        default: 'F'
      }
    },
    respiratoryRate: {
      value: {
        type: Number,
        min: [8, 'Respiratory rate too low'],
        max: [60, 'Respiratory rate too high']
      },
      unit: {
        type: String,
        default: 'breaths/min'
      }
    },
    oxygenSaturation: {
      value: {
        type: Number,
        min: [70, 'Oxygen saturation too low'],
        max: [100, 'Oxygen saturation cannot exceed 100']
      },
      unit: {
        type: String,
        default: '%'
      }
    },
    weight: {
      value: {
        type: Number,
        min: [0, 'Weight cannot be negative']
      },
      unit: {
        type: String,
        enum: ['kg', 'lbs'],
        default: 'kg'
      }
    },
    height: {
      value: {
        type: Number,
        min: [0, 'Height cannot be negative']
      },
      unit: {
        type: String,
        enum: ['cm', 'ft'],
        default: 'cm'
      }
    },
    bmi: Number
  },
  
  // Laboratory Results
  labResults: [{
    testName: {
      type: String,
      required: true
    },
    testCode: String,
    category: {
      type: String,
      enum: ['blood', 'urine', 'stool', 'radiology', 'pathology', 'microbiology', 'other']
    },
    result: {
      value: String,
      unit: String,
      referenceRange: String,
      status: {
        type: String,
        enum: ['normal', 'abnormal', 'high', 'low', 'critical'],
        default: 'normal'
      }
    },
    testDate: {
      type: Date,
      default: Date.now
    },
    laboratoryName: String,
    reportUrl: String,
    notes: String
  }],
  
  // Diagnosis
  diagnosis: {
    primary: {
      type: String,
      required: function() {
        return ['consultation', 'emergency_visit'].includes(this.recordType);
      }
    },
    secondary: [String],
    icdCodes: [String],
    severity: {
      type: String,
      enum: ['mild', 'moderate', 'severe', 'critical']
    },
    stage: String,
    notes: String
  },
  
  // Treatment Plan
  treatment: {
    medications: [{
      name: {
        type: String,
        required: true
      },
      dosage: String,
      frequency: String,
      duration: String,
      instructions: String,
      startDate: Date,
      endDate: Date,
      prescribedBy: String
    }],
    procedures: [{
      name: String,
      description: String,
      performedBy: String,
      date: Date,
      outcome: String,
      complications: String
    }],
    therapies: [String],
    lifestyle: [String],
    diet: String,
    restrictions: [String]
  },
  
  // Prescription Information
  prescription: {
    prescriptionNumber: String,
    issuedDate: Date,
    validUntil: Date,
    pharmacyInstructions: String,
    refillsAllowed: {
      type: Number,
      default: 0
    },
    refillsUsed: {
      type: Number,
      default: 0
    }
  },
  
  // Follow-up Information
  followUp: {
    required: {
      type: Boolean,
      default: false
    },
    date: Date,
    instructions: String,
    tests: [String],
    specialist: String,
    completed: {
      type: Boolean,
      default: false
    }
  },
  
  // Documents and Files
  documents: [{
    name: String,
    type: {
      type: String,
      enum: ['pdf', 'image', 'video', 'audio', 'other']
    },
    url: String,
    size: Number,
    uploadedAt: {
      type: Date,
      default: Date.now
    },
    uploadedBy: String,
    isPublic: {
      type: Boolean,
      default: false
    }
  }],
  
  // Digital Signatures and Verification
  signatures: [{
    signedBy: String,
    designation: String,
    timestamp: {
      type: Date,
      default: Date.now
    },
    digitalSignature: String,
    verified: {
      type: Boolean,
      default: false
    }
  }],
  
  // ABHA Integration
  abhaConsent: {
    consentId: String,
    consentDate: Date,
    purpose: String,
    dataTypes: [String],
    validUntil: Date,
    status: {
      type: String,
      enum: ['active', 'expired', 'revoked'],
      default: 'active'
    }
  },
  
  // Privacy and Access Control
  privacy: {
    isConfidential: {
      type: Boolean,
      default: false
    },
    accessLevel: {
      type: String,
      enum: ['public', 'restricted', 'private'],
      default: 'private'
    },
    sharedWith: [{
      userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      role: String,
      permissions: [String],
      sharedAt: Date,
      expiresAt: Date
    }]
  },
  
  // Emergency Information
  emergency: {
    isEmergency: {
      type: Boolean,
      default: false
    },
    severity: {
      type: String,
      enum: ['low', 'medium', 'high', 'critical']
    },
    triageCategory: String,
    admissionRequired: {
      type: Boolean,
      default: false
    }
  },
  
  // Insurance and Billing
  insurance: {
    provider: String,
    policyNumber: String,
    claimNumber: String,
    coverage: String,
    copay: Number,
    deductible: Number,
    preAuthRequired: {
      type: Boolean,
      default: false
    },
    preAuthNumber: String
  },
  
  // Record Status
  status: {
    type: String,
    enum: ['draft', 'pending_review', 'approved', 'final', 'amended', 'cancelled'],
    default: 'draft'
  },
  
  // Version Control
  version: {
    type: Number,
    default: 1
  },
  previousVersions: [{
    version: Number,
    data: mongoose.Schema.Types.Mixed,
    amendedBy: String,
    amendedAt: Date,
    reason: String
  }],
  
  // Audit Trail
  auditTrail: [{
    action: {
      type: String,
      enum: ['created', 'viewed', 'updated', 'shared', 'exported', 'printed'],
      required: true
    },
    performedBy: String,
    timestamp: {
      type: Date,
      default: Date.now
    },
    ipAddress: String,
    userAgent: String,
    details: String
  }]
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Generate record ID before saving
medicalRecordSchema.pre('save', function(next) {
  if (!this.recordId) {
    const date = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const random = Math.random().toString(36).substr(2, 6).toUpperCase();
    this.recordId = `MR${date}${random}`;
  }
  
  // Calculate BMI if height and weight are available
  if (this.vitalSigns?.height?.value && this.vitalSigns?.weight?.value) {
    const heightInM = this.vitalSigns.height.unit === 'cm' 
      ? this.vitalSigns.height.value / 100 
      : this.vitalSigns.height.value * 0.3048;
    const weightInKg = this.vitalSigns.weight.unit === 'kg' 
      ? this.vitalSigns.weight.value 
      : this.vitalSigns.weight.value * 0.453592;
    
    this.vitalSigns.bmi = Math.round((weightInKg / (heightInM * heightInM)) * 10) / 10;
  }
  
  next();
});

// Indexes for better performance
medicalRecordSchema.index({ patient: 1, visitDate: -1 });
medicalRecordSchema.index({ recordId: 1 });
medicalRecordSchema.index({ recordType: 1 });
medicalRecordSchema.index({ 'provider.hospitalId': 1 });
medicalRecordSchema.index({ visitDate: -1 });
medicalRecordSchema.index({ status: 1 });

// Virtual for record age
medicalRecordSchema.virtual('recordAge').get(function() {
  const now = new Date();
  const visitDate = new Date(this.visitDate);
  const daysDiff = Math.floor((now - visitDate) / (1000 * 60 * 60 * 24));
  
  if (daysDiff === 0) return 'Today';
  if (daysDiff === 1) return 'Yesterday';
  if (daysDiff < 7) return `${daysDiff} days ago`;
  if (daysDiff < 30) return `${Math.floor(daysDiff / 7)} weeks ago`;
  if (daysDiff < 365) return `${Math.floor(daysDiff / 30)} months ago`;
  return `${Math.floor(daysDiff / 365)} years ago`;
});

// Virtual for BMI category
medicalRecordSchema.virtual('bmiCategory').get(function() {
  const bmi = this.vitalSigns?.bmi;
  if (!bmi) return null;
  
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25) return 'Normal';
  if (bmi < 30) return 'Overweight';
  return 'Obese';
});

// Static methods
medicalRecordSchema.statics.findByPatient = function(patientId, recordType = null, limit = 20) {
  const query = { patient: patientId };
  if (recordType) query.recordType = recordType;
  
  return this.find(query)
    .sort({ visitDate: -1 })
    .limit(limit)
    .populate('patient', 'name email phone dateOfBirth gender bloodGroup');
};

medicalRecordSchema.statics.findByDateRange = function(startDate, endDate, patientId = null) {
  const query = {
    visitDate: {
      $gte: new Date(startDate),
      $lte: new Date(endDate)
    }
  };
  
  if (patientId) query.patient = patientId;
  
  return this.find(query)
    .sort({ visitDate: -1 })
    .populate('patient', 'name email phone');
};

medicalRecordSchema.statics.searchRecords = function(searchTerm, patientId = null) {
  const query = {
    $or: [
      { chiefComplaint: { $regex: searchTerm, $options: 'i' } },
      { 'diagnosis.primary': { $regex: searchTerm, $options: 'i' } },
      { 'diagnosis.secondary': { $regex: searchTerm, $options: 'i' } },
      { 'provider.doctorName': { $regex: searchTerm, $options: 'i' } },
      { 'provider.hospitalName': { $regex: searchTerm, $options: 'i' } }
    ]
  };
  
  if (patientId) query.patient = patientId;
  
  return this.find(query)
    .sort({ visitDate: -1 })
    .populate('patient', 'name email phone');
};

// Instance methods
medicalRecordSchema.methods.addAuditEntry = function(action, performedBy, details = '', ipAddress = '', userAgent = '') {
  this.auditTrail.push({
    action,
    performedBy,
    details,
    ipAddress,
    userAgent,
    timestamp: new Date()
  });
  
  return this.save();
};

medicalRecordSchema.methods.shareWith = function(userId, role, permissions = [], expiresAt = null) {
  // Remove existing share if exists
  this.privacy.sharedWith = this.privacy.sharedWith.filter(
    share => !share.userId.equals(userId)
  );
  
  // Add new share
  this.privacy.sharedWith.push({
    userId,
    role,
    permissions,
    sharedAt: new Date(),
    expiresAt
  });
  
  return this.save();
};

medicalRecordSchema.methods.canAccess = function(userId, permission = 'read') {
  // Patient always has full access
  if (this.patient.equals(userId)) return true;
  
  // Check if shared with user
  const share = this.privacy.sharedWith.find(share => 
    share.userId.equals(userId) && 
    (!share.expiresAt || share.expiresAt > new Date())
  );
  
  if (!share) return false;
  
  // Check permission
  return share.permissions.includes(permission) || share.permissions.includes('full');
};

medicalRecordSchema.methods.createAmendment = function(newData, amendedBy, reason) {
  // Store current version
  this.previousVersions.push({
    version: this.version,
    data: this.toObject(),
    amendedBy,
    amendedAt: new Date(),
    reason
  });
  
  // Update record
  Object.assign(this, newData);
  this.version += 1;
  this.status = 'amended';
  
  return this.save();
};

module.exports = mongoose.model('MedicalRecord', medicalRecordSchema);