const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const userSchema = new mongoose.Schema(
  {
    // Basic Information
    name: {
      type: String,
      required: [true, "Name is required"],
      trim: true,
      maxlength: [100, "Name cannot exceed 100 characters"],
    },
    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      lowercase: true,
      trim: true,
      match: [
        /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/,
        "Please enter a valid email",
      ],
    },
    phone: {
      type: String,
      required: [true, "Phone number is required"],
      match: [/^[6-9]\d{9}$/, "Please enter a valid Indian phone number"],
    },
    password: {
      type: String,
      required: function () {
        return !this.googleId; // Password required only if not Google user
      },
      minlength: [6, "Password must be at least 6 characters"],
    },

    // Authentication
    googleId: {
      type: String,
      sparse: true, // Allows multiple null values
    },
    emailVerified: {
      type: Boolean,
      default: false,
    },
    phoneVerified: {
      type: Boolean,
      default: false,
    },

    // Profile Information
    avatar: {
      type: String,
      default: null,
    },
    dateOfBirth: {
      type: Date,
      validate: {
        validator: function (v) {
          return !v || v < new Date();
        },
        message: "Date of birth cannot be in the future",
      },
    },
    gender: {
      type: String,
      enum: ["Male", "Female", "Other"],
      default: null,
    },
    bloodGroup: {
      type: String,
      enum: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"],
      default: null,
    },

    // Address Information
    address: {
      street: String,
      city: String,
      state: String,
      pincode: {
        type: String,
        match: [/^\d{6}$/, "Please enter a valid pincode"],
      },
      country: {
        type: String,
        default: "India",
      },
    },

    // ABHA (Ayushman Bharat Health Account) Integration
    abhaId: {
      type: String,
      unique: true,
      sparse: true,
      match: [
        /^\d{2}-\d{4}-\d{4}-\d{4}$/,
        "Please enter a valid ABHA ID format (XX-XXXX-XXXX-XXXX)",
      ],
    },
    abhaAddress: {
      type: String,
      sparse: true,
    },

    // Emergency Contact
    emergencyContact: {
      name: String,
      phone: {
        type: String,
        match: [/^[6-9]\d{9}$/, "Please enter a valid Indian phone number"],
      },
      relation: String,
    },

    // Preferences
    language: {
      type: String,
      enum: [
        "en",
        "hi",
        "te",
        "ta",
        "bn",
        "gu",
        "kn",
        "ml",
        "mr",
        "or",
        "pa",
        "ur",
      ],
      default: "en",
    },
    notifications: {
      email: {
        type: Boolean,
        default: true,
      },
      sms: {
        type: Boolean,
        default: true,
      },
      push: {
        type: Boolean,
        default: true,
      },
    },

    // Account Status
    isActive: {
      type: Boolean,
      default: true,
    },
    lastLogin: {
      type: Date,
      default: null,
    },

    // Security
    refreshTokens: [
      {
        token: String,
        createdAt: {
          type: Date,
          default: Date.now,
          expires: 604800, // 7 days in seconds
        },
      },
    ],

    // Password Reset
    resetPasswordToken: String,
    resetPasswordExpire: Date,

    // Email Verification
    emailVerificationToken: String,
    emailVerificationExpire: Date,
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Virtual for age calculation
userSchema.virtual("age").get(function () {
  if (!this.dateOfBirth) return null;
  const today = new Date();
  const birthDate = new Date(this.dateOfBirth);
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  if (
    monthDiff < 0 ||
    (monthDiff === 0 && today.getDate() < birthDate.getDate())
  ) {
    age--;
  }
  return age;
});

// Index for better performance (email, abhaId, googleId already have unique indexes)
// userSchema.index({ email: 1 }); // Removed: unique: true already creates index
userSchema.index({ phone: 1 });
// userSchema.index({ abhaId: 1 }); // Removed: unique: true already creates index
// userSchema.index({ googleId: 1 }); // Removed: sparse unique already creates index

// Pre-save middleware to hash password
userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();

  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Method to compare password
userSchema.methods.comparePassword = async function (candidatePassword) {
  if (!this.password) return false;
  return await bcrypt.compare(candidatePassword, this.password);
};

// Method to generate auth token payload
userSchema.methods.getTokenPayload = function () {
  return {
    id: this._id,
    email: this.email,
    name: this.name,
    phone: this.phone,
    emailVerified: this.emailVerified,
    phoneVerified: this.phoneVerified,
  };
};

// Method to get public profile
userSchema.methods.getPublicProfile = function () {
  const user = this.toObject();
  delete user.password;
  delete user.refreshTokens;
  delete user.resetPasswordToken;
  delete user.resetPasswordExpire;
  delete user.emailVerificationToken;
  delete user.emailVerificationExpire;
  delete user.googleId;
  return user;
};

// Static method to find by email or phone
userSchema.statics.findByEmailOrPhone = function (identifier) {
  return this.findOne({
    $or: [{ email: identifier }, { phone: identifier }],
  });
};

module.exports = mongoose.model("User", userSchema);
