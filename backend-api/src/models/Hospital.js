const mongoose = require('mongoose');

const hospitalSchema = new mongoose.Schema({
  // Basic Information
  name: {
    type: String,
    required: [true, 'Hospital name is required'],
    trim: true,
    index: true
  },
  registrationNumber: {
    type: String,
    unique: true,
    required: [true, 'Registration number is required'],
    trim: true
  },
  
  // Contact Information
  contact: {
    phone: {
      type: String,
      required: [true, 'Phone number is required'],
      match: [/^[6-9]\d{9}$/, 'Please enter a valid Indian phone number']
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      lowercase: true,
      match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
    },
    website: String,
    emergencyContact: String
  },
  
  // Address Information
  address: {
    street: {
      type: String,
      required: [true, 'Street address is required']
    },
    landmark: String,
    city: {
      type: String,
      required: [true, 'City is required']
    },
    state: {
      type: String,
      required: [true, 'State is required']
    },
    pincode: {
      type: String,
      required: [true, 'Pincode is required'],
      match: [/^\d{6}$/, 'Please enter a valid pincode']
    },
    country: {
      type: String,
      default: 'India'
    },
    coordinates: {
      latitude: {
        type: Number,
        min: [-90, 'Latitude must be between -90 and 90'],
        max: [90, 'Latitude must be between -90 and 90']
      },
      longitude: {
        type: Number,
        min: [-180, 'Longitude must be between -180 and 180'],
        max: [180, 'Longitude must be between -180 and 180']
      }
    }
  },
  
  // Hospital Type and Classification
  type: {
    type: String,
    enum: [
      'government',
      'private',
      'semi_government',
      'trust',
      'corporate',
      'specialty',
      'super_specialty',
      'nursing_home',
      'clinic'
    ],
    required: [true, 'Hospital type is required']
  },
  category: {
    type: String,
    enum: [
      'primary',
      'secondary',
      'tertiary',
      'quaternary',
      'specialty',
      'super_specialty'
    ],
    required: [true, 'Hospital category is required']
  },
  
  // Accreditation and Certifications
  accreditation: {
    nabh: {
      certified: {
        type: Boolean,
        default: false
      },
      certificateNumber: String,
      validUntil: Date,
      grade: {
        type: String,
        enum: ['A', 'B', 'C']
      }
    },
    jci: {
      certified: {
        type: Boolean,
        default: false
      },
      certificateNumber: String,
      validUntil: Date
    },
    iso: {
      certified: {
        type: Boolean,
        default: false
      },
      standard: String,
      certificateNumber: String,
      validUntil: Date
    },
    other: [{
      name: String,
      certificateNumber: String,
      issuedBy: String,
      validUntil: Date
    }]
  },
  
  // Facilities and Services
  facilities: {
    totalBeds: {
      type: Number,
      required: [true, 'Total beds count is required'],
      min: [1, 'Hospital must have at least 1 bed']
    },
    icuBeds: {
      type: Number,
      default: 0,
      min: [0, 'ICU beds cannot be negative']
    },
    emergencyBeds: {
      type: Number,
      default: 0,
      min: [0, 'Emergency beds cannot be negative']
    },
    operationTheaters: {
      type: Number,
      default: 0,
      min: [0, 'Operation theaters cannot be negative']
    },
    ambulanceCount: {
      type: Number,
      default: 0,
      min: [0, 'Ambulance count cannot be negative']
    },
    parkingSpaces: {
      type: Number,
      default: 0,
      min: [0, 'Parking spaces cannot be negative']
    }
  },
  
  // Specialties and Departments
  specialties: [{
    name: {
      type: String,
      required: true
    },
    department: String,
    headOfDepartment: String,
    doctors: [{
      name: String,
      qualification: String,
      experience: Number,
      specialization: String,
      consultationFee: Number,
      availableDays: [String],
      availableTime: String
    }],
    services: [String],
    equipment: [String]
  }],
  
  // Services Offered
  services: {
    emergency: {
      available: {
        type: Boolean,
        default: false
      },
      hours: {
        type: String,
        default: '24x7'
      }
    },
    pharmacy: {
      available: {
        type: Boolean,
        default: false
      },
      hours: String
    },
    laboratory: {
      available: {
        type: Boolean,
        default: false
      },
      services: [String],
      hours: String
    },
    radiology: {
      available: {
        type: Boolean,
        default: false
      },
      equipment: [String],
      hours: String
    },
    bloodBank: {
      available: {
        type: Boolean,
        default: false
      },
      bloodTypes: [String]
    },
    ambulance: {
      available: {
        type: Boolean,
        default: false
      },
      types: [String], // Basic, Advanced, Air Ambulance
      coverage: String
    },
    telemedicine: {
      available: {
        type: Boolean,
        default: false
      },
      platforms: [String]
    }
  },
  
  // Insurance and Payment
  insurance: {
    accepted: [{
      provider: String,
      types: [String], // Cashless, Reimbursement
      tpaName: String,
      coverage: String
    }],
    governmentSchemes: [{
      name: String, // CGHS, ECHS, Ayushman Bharat, etc.
      empanelmentNumber: String,
      validUntil: Date
    }],
    paymentMethods: {
      cash: {
        type: Boolean,
        default: true
      },
      card: {
        type: Boolean,
        default: false
      },
      upi: {
        type: Boolean,
        default: false
      },
      netBanking: {
        type: Boolean,
        default: false
      }
    }
  },
  
  // Ratings and Reviews
  ratings: {
    overall: {
      type: Number,
      default: 0,
      min: [0, 'Rating cannot be negative'],
      max: [5, 'Rating cannot exceed 5']
    },
    cleanliness: {
      type: Number,
      default: 0,
      min: [0, 'Rating cannot be negative'],
      max: [5, 'Rating cannot exceed 5']
    },
    staff: {
      type: Number,
      default: 0,
      min: [0, 'Rating cannot be negative'],
      max: [5, 'Rating cannot exceed 5']
    },
    facilities: {
      type: Number,
      default: 0,
      min: [0, 'Rating cannot be negative'],
      max: [5, 'Rating cannot exceed 5']
    },
    cost: {
      type: Number,
      default: 0,
      min: [0, 'Rating cannot be negative'],
      max: [5, 'Rating cannot exceed 5']
    },
    totalReviews: {
      type: Number,
      default: 0,
      min: [0, 'Review count cannot be negative']
    }
  },
  
  // Operating Hours
  operatingHours: {
    monday: {
      open: String,
      close: String,
      is24Hours: {
        type: Boolean,
        default: false
      }
    },
    tuesday: {
      open: String,
      close: String,
      is24Hours: {
        type: Boolean,
        default: false
      }
    },
    wednesday: {
      open: String,
      close: String,
      is24Hours: {
        type: Boolean,
        default: false
      }
    },
    thursday: {
      open: String,
      close: String,
      is24Hours: {
        type: Boolean,
        default: false
      }
    },
    friday: {
      open: String,
      close: String,
      is24Hours: {
        type: Boolean,
        default: false
      }
    },
    saturday: {
      open: String,
      close: String,
      is24Hours: {
        type: Boolean,
        default: false
      }
    },
    sunday: {
      open: String,
      close: String,
      is24Hours: {
        type: Boolean,
        default: false
      }
    }
  },
  
  // Media and Images
  images: [{
    url: String,
    alt: String,
    type: {
      type: String,
      enum: ['exterior', 'interior', 'equipment', 'staff', 'ward', 'other'],
      default: 'other'
    },
    isPrimary: {
      type: Boolean,
      default: false
    }
  }],
  
  // Verification Status
  verification: {
    isVerified: {
      type: Boolean,
      default: false
    },
    verifiedBy: String,
    verifiedAt: Date,
    documents: [{
      type: String,
      url: String,
      verified: {
        type: Boolean,
        default: false
      }
    }]
  },
  
  // Status
  isActive: {
    type: Boolean,
    default: true
  },
  isOperational: {
    type: Boolean,
    default: true
  },
  
  // Statistics
  statistics: {
    totalPatients: {
      type: Number,
      default: 0
    },
    monthlyPatients: {
      type: Number,
      default: 0
    },
    successfulSurgeries: {
      type: Number,
      default: 0
    },
    establishedYear: {
      type: Number,
      validate: {
        validator: function(v) {
          return !v || (v >= 1800 && v <= new Date().getFullYear());
        },
        message: 'Established year must be between 1800 and current year'
      }
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better search performance
hospitalSchema.index({ name: 'text', 'specialties.name': 'text' });
hospitalSchema.index({ 'address.city': 1, 'address.state': 1 });
hospitalSchema.index({ 'address.pincode': 1 });
hospitalSchema.index({ type: 1, category: 1 });
hospitalSchema.index({ 'ratings.overall': -1 });
hospitalSchema.index({ isActive: 1, isOperational: 1 });
hospitalSchema.index({ 'address.coordinates': '2dsphere' });

// Virtual for full address
hospitalSchema.virtual('fullAddress').get(function() {
  const addr = this.address;
  return `${addr.street}, ${addr.landmark ? addr.landmark + ', ' : ''}${addr.city}, ${addr.state} - ${addr.pincode}`;
});

// Virtual for experience in years
hospitalSchema.virtual('experienceYears').get(function() {
  if (!this.statistics.establishedYear) return null;
  return new Date().getFullYear() - this.statistics.establishedYear;
});

// Virtual for checking if open now
hospitalSchema.virtual('isOpenNow').get(function() {
  const now = new Date();
  const dayNames = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
  const today = dayNames[now.getDay()];
  const currentTime = now.toTimeString().slice(0, 5); // HH:MM format
  
  const todayHours = this.operatingHours[today];
  if (!todayHours || (!todayHours.is24Hours && (!todayHours.open || !todayHours.close))) {
    return false;
  }
  
  if (todayHours.is24Hours) return true;
  
  return currentTime >= todayHours.open && currentTime <= todayHours.close;
});

// Pre-save middleware
hospitalSchema.pre('save', function(next) {
  // Ensure only one primary image
  if (this.images && this.images.length > 0) {
    const primaryImages = this.images.filter(img => img.isPrimary);
    if (primaryImages.length > 1) {
      this.images.forEach((img, index) => {
        img.isPrimary = index === 0;
      });
    } else if (primaryImages.length === 0) {
      this.images[0].isPrimary = true;
    }
  }
  
  next();
});

// Static methods
hospitalSchema.statics.findNearby = function(latitude, longitude, maxDistance = 10000, options = {}) {
  const {
    type,
    specialty,
    minRating = 0,
    hasEmergency,
    acceptsInsurance,
    limit = 20
  } = options;
  
  const query = {
    'address.coordinates': {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: [longitude, latitude]
        },
        $maxDistance: maxDistance
      }
    },
    isActive: true,
    isOperational: true,
    'ratings.overall': { $gte: minRating }
  };
  
  if (type) query.type = type;
  if (specialty) query['specialties.name'] = { $regex: specialty, $options: 'i' };
  if (hasEmergency) query['services.emergency.available'] = true;
  if (acceptsInsurance) query['insurance.accepted.0'] = { $exists: true };
  
  return this.find(query).limit(limit);
};

hospitalSchema.statics.searchHospitals = function(searchTerm, options = {}) {
  const {
    city,
    state,
    type,
    specialty,
    minRating = 0,
    limit = 20,
    skip = 0
  } = options;
  
  const query = {
    isActive: true,
    isOperational: true,
    'ratings.overall': { $gte: minRating }
  };
  
  // Text search
  if (searchTerm) {
    query.$text = { $search: searchTerm };
  }
  
  // Filters
  if (city) query['address.city'] = { $regex: city, $options: 'i' };
  if (state) query['address.state'] = { $regex: state, $options: 'i' };
  if (type) query.type = type;
  if (specialty) query['specialties.name'] = { $regex: specialty, $options: 'i' };
  
  return this.find(query)
    .sort(searchTerm ? { score: { $meta: 'textScore' } } : { 'ratings.overall': -1 })
    .limit(limit)
    .skip(skip);
};

hospitalSchema.statics.findBySpecialty = function(specialty, options = {}) {
  const { city, state, minRating = 0, limit = 20 } = options;
  
  const query = {
    'specialties.name': { $regex: specialty, $options: 'i' },
    isActive: true,
    isOperational: true,
    'ratings.overall': { $gte: minRating }
  };
  
  if (city) query['address.city'] = { $regex: city, $options: 'i' };
  if (state) query['address.state'] = { $regex: state, $options: 'i' };
  
  return this.find(query)
    .sort({ 'ratings.overall': -1 })
    .limit(limit);
};

// Instance methods
hospitalSchema.methods.updateRating = function(category, newRating) {
  if (!this.ratings[category]) return false;
  
  const currentRating = this.ratings[category];
  const currentCount = this.ratings.totalReviews;
  
  // Calculate new average
  const newAverage = ((currentRating * currentCount) + newRating) / (currentCount + 1);
  this.ratings[category] = Math.round(newAverage * 10) / 10;
  
  if (category === 'overall') {
    this.ratings.totalReviews += 1;
  }
  
  return this.save();
};

hospitalSchema.methods.addSpecialty = function(specialtyData) {
  this.specialties.push(specialtyData);
  return this.save();
};

hospitalSchema.methods.getAvailableDoctors = function(specialty = null, day = null) {
  let doctors = [];
  
  this.specialties.forEach(spec => {
    if (!specialty || spec.name.toLowerCase().includes(specialty.toLowerCase())) {
      spec.doctors.forEach(doctor => {
        if (!day || doctor.availableDays.includes(day)) {
          doctors.push({
            ...doctor.toObject(),
            department: spec.name
          });
        }
      });
    }
  });
  
  return doctors;
};

hospitalSchema.methods.checkAvailability = function(date, time) {
  const dayNames = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
  const dayName = dayNames[new Date(date).getDay()];
  
  const dayHours = this.operatingHours[dayName];
  if (!dayHours) return false;
  
  if (dayHours.is24Hours) return true;
  
  return time >= dayHours.open && time <= dayHours.close;
};

module.exports = mongoose.model('Hospital', hospitalSchema);