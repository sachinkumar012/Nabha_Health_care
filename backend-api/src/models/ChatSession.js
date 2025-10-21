const mongoose = require('mongoose');

const chatSessionSchema = new mongoose.Schema({
  // Session Identification
  sessionId: {
    type: String,
    unique: true,
    required: true
  },
  
  // Participants
  participants: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    role: {
      type: String,
      enum: ['patient', 'doctor', 'support', 'bot'],
      required: true
    },
    joinedAt: {
      type: Date,
      default: Date.now
    },
    leftAt: Date,
    isActive: {
      type: Boolean,
      default: true
    }
  }],
  
  // Chat Context
  context: {
    type: {
      type: String,
      enum: ['appointment', 'general_inquiry', 'support', 'emergency', 'pharmacy', 'symptom_checker'],
      required: [true, 'Chat context type is required']
    },
    relatedId: mongoose.Schema.Types.ObjectId, // Appointment ID, Order ID, etc.
    subject: String,
    priority: {
      type: String,
      enum: ['low', 'medium', 'high', 'urgent'],
      default: 'medium'
    }
  },
  
  // Messages
  messages: [{
    messageId: {
      type: String,
      required: true,
      unique: true
    },
    sender: {
      userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      role: {
        type: String,
        enum: ['patient', 'doctor', 'support', 'bot'],
        required: true
      },
      name: String
    },
    content: {
      text: String,
      type: {
        type: String,
        enum: ['text', 'image', 'file', 'audio', 'video', 'location', 'prescription', 'appointment_link'],
        default: 'text'
      },
      metadata: {
        fileName: String,
        fileSize: Number,
        fileUrl: String,
        thumbnailUrl: String,
        duration: Number, // for audio/video
        coordinates: {
          latitude: Number,
          longitude: Number
        },
        appointmentId: mongoose.Schema.Types.ObjectId,
        prescriptionId: mongoose.Schema.Types.ObjectId
      }
    },
    timestamp: {
      type: Date,
      default: Date.now
    },
    readBy: [{
      userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      readAt: {
        type: Date,
        default: Date.now
      }
    }],
    edited: {
      isEdited: {
        type: Boolean,
        default: false
      },
      editedAt: Date,
      originalContent: String
    },
    reactions: [{
      userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      reaction: {
        type: String,
        enum: ['like', 'love', 'laugh', 'sad', 'angry', 'helpful', 'not_helpful']
      },
      reactedAt: {
        type: Date,
        default: Date.now
      }
    }],
    isDeleted: {
      type: Boolean,
      default: false
    },
    deletedAt: Date,
    deletedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }
  }],
  
  // Bot Integration
  botContext: {
    isActive: {
      type: Boolean,
      default: false
    },
    currentFlow: String,
    currentStep: String,
    userData: mongoose.Schema.Types.Mixed,
    sessionData: mongoose.Schema.Types.Mixed,
    lastBotResponse: Date,
    handoverToHuman: {
      requested: {
        type: Boolean,
        default: false
      },
      reason: String,
      requestedAt: Date,
      assignedTo: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      }
    }
  },
  
  // Session Status
  status: {
    type: String,
    enum: ['active', 'waiting', 'assigned', 'resolved', 'closed', 'escalated'],
    default: 'active'
  },
  
  // Assignment (for support chats)
  assignment: {
    assignedTo: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    assignedAt: Date,
    assignedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    department: String,
    skillsRequired: [String]
  },
  
  // Session Timing
  startedAt: {
    type: Date,
    default: Date.now
  },
  endedAt: Date,
  lastActivity: {
    type: Date,
    default: Date.now
  },
  
  // Session Metrics
  metrics: {
    totalMessages: {
      type: Number,
      default: 0
    },
    responseTime: {
      average: Number, // in seconds
      first: Number,
      longest: Number
    },
    sessionDuration: Number, // in seconds
    participantCount: {
      type: Number,
      default: 0
    },
    botInteractions: {
      type: Number,
      default: 0
    },
    humanHandovers: {
      type: Number,
      default: 0
    }
  },
  
  // Tags and Categories
  tags: [String],
  category: String,
  subcategory: String,
  
  // Resolution
  resolution: {
    isResolved: {
      type: Boolean,
      default: false
    },
    resolvedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    resolvedAt: Date,
    resolutionType: {
      type: String,
      enum: ['answered', 'appointment_booked', 'escalated', 'referred', 'closed_by_user']
    },
    summary: String,
    followUpRequired: {
      type: Boolean,
      default: false
    },
    followUpDate: Date
  },
  
  // Feedback and Rating
  feedback: {
    rating: {
      type: Number,
      min: [1, 'Rating must be at least 1'],
      max: [5, 'Rating cannot exceed 5']
    },
    comment: String,
    ratedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    ratedAt: Date,
    categories: {
      helpfulness: Number,
      responsiveness: Number,
      professionalism: Number,
      resolution: Number
    }
  },
  
  // Privacy and Security
  isEncrypted: {
    type: Boolean,
    default: false
  },
  isConfidential: {
    type: Boolean,
    default: false
  },
  
  // Archive Settings
  autoArchiveAfter: {
    type: Number,
    default: 30 // days
  },
  isArchived: {
    type: Boolean,
    default: false
  },
  archivedAt: Date
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Generate session ID before saving
chatSessionSchema.pre('save', function(next) {
  if (!this.sessionId) {
    this.sessionId = `chat_${Date.now()}_${Math.random().toString(36).substr(2, 8)}`;
  }
  
  // Update metrics
  this.metrics.totalMessages = this.messages.length;
  this.metrics.participantCount = this.participants.length;
  
  // Update last activity
  if (this.messages.length > 0) {
    const lastMessage = this.messages[this.messages.length - 1];
    this.lastActivity = lastMessage.timestamp;
  }
  
  // Calculate session duration if ended
  if (this.endedAt) {
    this.metrics.sessionDuration = Math.floor((this.endedAt - this.startedAt) / 1000);
  }
  
  next();
});

// Indexes for better performance
chatSessionSchema.index({ sessionId: 1 });
chatSessionSchema.index({ 'participants.userId': 1 });
chatSessionSchema.index({ status: 1 });
chatSessionSchema.index({ 'context.type': 1 });
chatSessionSchema.index({ startedAt: -1 });
chatSessionSchema.index({ lastActivity: -1 });
chatSessionSchema.index({ 'assignment.assignedTo': 1 });

// Virtual for active participants
chatSessionSchema.virtual('activeParticipants').get(function() {
  return this.participants.filter(p => p.isActive);
});

// Virtual for unread message count
chatSessionSchema.virtual('unreadCount').get(function() {
  // This would need to be calculated based on specific user
  return this.messages.filter(m => m.readBy.length === 0).length;
});

// Virtual for session age
chatSessionSchema.virtual('sessionAge').get(function() {
  const now = new Date();
  const created = new Date(this.startedAt);
  const daysDiff = Math.floor((now - created) / (1000 * 60 * 60 * 24));
  
  if (daysDiff === 0) return 'Today';
  if (daysDiff === 1) return 'Yesterday';
  if (daysDiff < 7) return `${daysDiff} days ago`;
  if (daysDiff < 30) return `${Math.floor(daysDiff / 7)} weeks ago`;
  return `${Math.floor(daysDiff / 30)} months ago`;
});

// Static methods
chatSessionSchema.statics.findActiveByUser = function(userId, limit = 10) {
  return this.find({
    'participants.userId': userId,
    'participants.isActive': true,
    status: { $in: ['active', 'waiting', 'assigned'] }
  })
  .sort({ lastActivity: -1 })
  .limit(limit)
  .populate('participants.userId', 'name avatar')
  .populate('assignment.assignedTo', 'name avatar');
};

chatSessionSchema.statics.findByContext = function(contextType, relatedId = null) {
  const query = { 'context.type': contextType };
  if (relatedId) query['context.relatedId'] = relatedId;
  
  return this.find(query)
    .sort({ startedAt: -1 })
    .populate('participants.userId', 'name avatar');
};

chatSessionSchema.statics.findPendingAssignment = function(department = null, skills = []) {
  const query = {
    status: 'waiting',
    'assignment.assignedTo': { $exists: false }
  };
  
  if (department) query['assignment.department'] = department;
  if (skills.length > 0) query['assignment.skillsRequired'] = { $in: skills };
  
  return this.find(query)
    .sort({ 'context.priority': -1, startedAt: 1 })
    .populate('participants.userId', 'name avatar email phone');
};

// Instance methods
chatSessionSchema.methods.addMessage = function(messageData) {
  const messageId = `msg_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`;
  
  const message = {
    messageId,
    ...messageData,
    timestamp: new Date()
  };
  
  this.messages.push(message);
  this.lastActivity = message.timestamp;
  
  return this.save();
};

chatSessionSchema.methods.markAsRead = function(userId, messageIds = []) {
  if (messageIds.length === 0) {
    // Mark all messages as read
    this.messages.forEach(message => {
      const existingRead = message.readBy.find(read => read.userId.equals(userId));
      if (!existingRead) {
        message.readBy.push({
          userId,
          readAt: new Date()
        });
      }
    });
  } else {
    // Mark specific messages as read
    messageIds.forEach(msgId => {
      const message = this.messages.find(m => m.messageId === msgId);
      if (message) {
        const existingRead = message.readBy.find(read => read.userId.equals(userId));
        if (!existingRead) {
          message.readBy.push({
            userId,
            readAt: new Date()
          });
        }
      }
    });
  }
  
  return this.save();
};

chatSessionSchema.methods.assignTo = function(userId, assignedBy, department = null) {
  this.assignment = {
    assignedTo: userId,
    assignedAt: new Date(),
    assignedBy,
    department
  };
  this.status = 'assigned';
  
  return this.save();
};

chatSessionSchema.methods.resolveSession = function(resolvedBy, resolutionType, summary = '') {
  this.resolution = {
    isResolved: true,
    resolvedBy,
    resolvedAt: new Date(),
    resolutionType,
    summary
  };
  this.status = 'resolved';
  this.endedAt = new Date();
  
  return this.save();
};

chatSessionSchema.methods.addParticipant = function(userId, role) {
  // Check if user is already a participant
  const existing = this.participants.find(p => p.userId.equals(userId));
  if (existing) {
    existing.isActive = true;
    existing.joinedAt = new Date();
    existing.leftAt = null;
  } else {
    this.participants.push({
      userId,
      role,
      joinedAt: new Date(),
      isActive: true
    });
  }
  
  return this.save();
};

chatSessionSchema.methods.removeParticipant = function(userId) {
  const participant = this.participants.find(p => p.userId.equals(userId));
  if (participant) {
    participant.isActive = false;
    participant.leftAt = new Date();
  }
  
  return this.save();
};

chatSessionSchema.methods.escalate = function(reason, escalatedBy) {
  this.status = 'escalated';
  this.context.priority = 'urgent';
  
  // Add escalation message
  return this.addMessage({
    sender: {
      userId: escalatedBy,
      role: 'support',
      name: 'System'
    },
    content: {
      text: `Session escalated: ${reason}`,
      type: 'text'
    }
  });
};

chatSessionSchema.methods.getUnreadMessages = function(userId) {
  return this.messages.filter(message => 
    !message.readBy.some(read => read.userId.equals(userId))
  );
};

chatSessionSchema.methods.calculateResponseTime = function() {
  const responseTimes = [];
  let lastUserMessage = null;
  
  this.messages.forEach(message => {
    if (message.sender.role === 'patient') {
      lastUserMessage = message;
    } else if (lastUserMessage && (message.sender.role === 'doctor' || message.sender.role === 'support')) {
      const responseTime = (message.timestamp - lastUserMessage.timestamp) / 1000; // in seconds
      responseTimes.push(responseTime);
      lastUserMessage = null;
    }
  });
  
  if (responseTimes.length > 0) {
    this.metrics.responseTime = {
      average: responseTimes.reduce((a, b) => a + b) / responseTimes.length,
      first: responseTimes[0],
      longest: Math.max(...responseTimes)
    };
  }
  
  return this.save();
};

module.exports = mongoose.model('ChatSession', chatSessionSchema);