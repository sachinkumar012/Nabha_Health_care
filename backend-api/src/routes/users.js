const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const MedicalRecord = require("../models/MedicalRecord");
const { protect, authorize, asyncHandler } = require("../middleware/auth");
const {
  uploadProfileImage,
  handleUploadError,
} = require("../middleware/upload");

const router = express.Router();

// Generate JWT Token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE || "30d",
  });
};

// @desc    Register user
// @route   POST /api/users/register
// @access  Public
router.post(
  "/register",
  asyncHandler(async (req, res) => {
    const {
      name,
      email,
      password,
      phone,
      role = "patient",
      dateOfBirth,
      gender,
      address,
      abhaNumber,
      emergencyContact,
      specialization,
      experience,
      qualifications,
      licenseNumber,
    } = req.body;

    // Check if user exists
    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(400).json({
        success: false,
        message: "User already exists with this email",
      });
    }

    // Check for duplicate phone
    const phoneExists = await User.findOne({ phone });
    if (phoneExists) {
      return res.status(400).json({
        success: false,
        message: "User already exists with this phone number",
      });
    }

    // Create user object
    const userData = {
      name,
      email,
      password,
      phone,
      role,
      dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : undefined,
      gender,
      address,
      abhaNumber,
      emergencyContact,
    };

    // Add doctor-specific fields
    if (role === "doctor") {
      userData.specialization = specialization;
      userData.experience = experience;
      userData.qualifications = qualifications;
      userData.licenseNumber = licenseNumber;
    }

    // Create user
    const user = await User.create(userData);

    // Generate token
    const token = generateToken(user._id);

    // Remove password from response
    user.password = undefined;

    res.status(201).json({
      success: true,
      token,
      data: user,
    });
  })
);

// @desc    Login user
// @route   POST /api/users/login
// @access  Public
router.post(
  "/login",
  asyncHandler(async (req, res) => {
    const { email, password } = req.body;

    // Validate email & password
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Please provide an email and password",
      });
    }

    // Check for user
    const user = await User.findOne({ email }).select("+password");

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    // Check if password matches
    const isMatch = await user.matchPassword(password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    // Check if account is active
    if (!user.isActive) {
      return res.status(401).json({
        success: false,
        message: "Account has been deactivated",
      });
    }

    // Update last login
    user.lastLogin = new Date();
    await user.save();

    // Generate token
    const token = generateToken(user._id);

    // Remove password from response
    user.password = undefined;

    res.status(200).json({
      success: true,
      token,
      data: user,
    });
  })
);

// @desc    Get current logged in user
// @route   GET /api/users/me
// @access  Private
router.get(
  "/me",
  protect,
  asyncHandler(async (req, res) => {
    const user = await User.findById(req.user.id);

    res.status(200).json({
      success: true,
      data: user,
    });
  })
);

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
router.put(
  "/profile",
  protect,
  asyncHandler(async (req, res) => {
    const fieldsToUpdate = {
      name: req.body.name,
      phone: req.body.phone,
      dateOfBirth: req.body.dateOfBirth
        ? new Date(req.body.dateOfBirth)
        : undefined,
      gender: req.body.gender,
      address: req.body.address,
      emergencyContact: req.body.emergencyContact,
      avatar: req.body.profileImage || req.body.avatar,
    };

    // Add doctor-specific fields
    if (req.user.role === "doctor") {
      fieldsToUpdate.specialization = req.body.specialization;
      fieldsToUpdate.experience = req.body.experience;
      fieldsToUpdate.qualifications = req.body.qualifications;
      fieldsToUpdate.consultationFee = req.body.consultationFee;
      fieldsToUpdate.availability = req.body.availability;
    }

    // Remove undefined fields
    Object.keys(fieldsToUpdate).forEach(
      (key) => fieldsToUpdate[key] === undefined && delete fieldsToUpdate[key]
    );

    const user = await User.findByIdAndUpdate(req.user.id, fieldsToUpdate, {
      new: true,
      runValidators: true,
    });

    res.status(200).json({
      success: true,
      data: user,
    });
  })
);

// @desc    Upload profile image
// @route   POST /api/users/profile/image
// @access  Private
router.post("/profile/image", protect, (req, res) => {
  uploadProfileImage(req, res, async (error) => {
    if (error) {
      return handleUploadError(error, req, res, () => {
        return res.status(500).json({
          success: false,
          message: "Server error during upload",
        });
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No image file provided",
      });
    }

    try {
      // Update user's avatar URL in database
      const user = await User.findByIdAndUpdate(
        req.user.id,
        { avatar: req.file.path },
        { new: true, runValidators: true }
      );

      res.status(200).json({
        success: true,
        message: "Profile image uploaded successfully",
        data: {
          avatar: req.file.path,
          profileImage: req.file.path, // Also include profileImage for frontend compatibility
          cloudinaryId: req.file.filename,
          user: user,
        },
      });
    } catch (dbError) {
      console.error("Database error:", dbError);
      res.status(500).json({
        success: false,
        message: "Failed to update profile image in database",
      });
    }
  });
});

// @desc    Change password
// @route   PUT /api/users/password
// @access  Private
router.put(
  "/password",
  protect,
  asyncHandler(async (req, res) => {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: "Please provide current and new password",
      });
    }

    // Get user with password
    const user = await User.findById(req.user.id).select("+password");

    // Check current password
    const isMatch = await user.matchPassword(currentPassword);

    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: "Current password is incorrect",
      });
    }

    // Update password
    user.password = newPassword;
    await user.save();

    const token = generateToken(user._id);

    res.status(200).json({
      success: true,
      token,
      message: "Password updated successfully",
    });
  })
);

// @desc    Get all doctors
// @route   GET /api/users/doctors
// @access  Public
router.get(
  "/doctors",
  asyncHandler(async (req, res) => {
    const {
      specialization,
      experience,
      city,
      minRating = 0,
      availability,
      page = 1,
      limit = 20,
    } = req.query;

    let filter = {
      role: "doctor",
      isActive: true,
      isVerified: true,
    };

    // Add filters
    if (specialization) {
      filter.specialization = { $regex: specialization, $options: "i" };
    }

    if (experience) {
      filter.experience = { $gte: parseInt(experience) };
    }

    if (city) {
      filter["address.city"] = { $regex: city, $options: "i" };
    }

    if (availability) {
      filter[`availability.${availability}`] = true;
    }

    const doctors = await User.find(filter)
      .select("-password")
      .sort({ "ratings.overall": -1, experience: -1 })
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    const total = await User.countDocuments(filter);

    res.status(200).json({
      success: true,
      count: doctors.length,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      data: doctors,
    });
  })
);

// @desc    Get doctor by ID
// @route   GET /api/users/doctors/:id
// @access  Public
router.get(
  "/doctors/:id",
  asyncHandler(async (req, res) => {
    const doctor = await User.findOne({
      _id: req.params.id,
      role: "doctor",
      isActive: true,
    }).select("-password");

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: "Doctor not found",
      });
    }

    res.status(200).json({
      success: true,
      data: doctor,
    });
  })
);

// @desc    Get user's medical records
// @route   GET /api/users/medical-records
// @access  Private
router.get(
  "/medical-records",
  protect,
  asyncHandler(async (req, res) => {
    const { type, fromDate, toDate, page = 1, limit = 10 } = req.query;

    let filter = { patient: req.user.id };

    // Add filters
    if (type) {
      filter.type = type;
    }

    if (fromDate || toDate) {
      filter.date = {};
      if (fromDate) {
        filter.date.$gte = new Date(fromDate);
      }
      if (toDate) {
        filter.date.$lte = new Date(toDate);
      }
    }

    const records = await MedicalRecord.find(filter)
      .populate("doctor", "name specialization")
      .populate("hospital", "name address")
      .sort({ date: -1 })
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    const total = await MedicalRecord.countDocuments(filter);

    res.status(200).json({
      success: true,
      count: records.length,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      data: records,
    });
  })
);

// @desc    Add medical record
// @route   POST /api/users/medical-records
// @access  Private (Doctor only)
router.post(
  "/medical-records",
  protect,
  authorize("doctor"),
  asyncHandler(async (req, res) => {
    const {
      patient,
      type,
      diagnosis,
      treatment,
      medications,
      notes,
      vitals,
      attachments,
    } = req.body;

    const record = await MedicalRecord.create({
      patient,
      doctor: req.user.id,
      type,
      diagnosis,
      treatment,
      medications,
      notes,
      vitals,
      attachments,
    });

    const populatedRecord = await MedicalRecord.findById(record._id)
      .populate("patient", "name email abhaNumber")
      .populate("doctor", "name specialization")
      .populate("hospital", "name address");

    res.status(201).json({
      success: true,
      data: populatedRecord,
    });
  })
);

// @desc    Search doctors
// @route   GET /api/users/search/doctors
// @access  Public
router.get(
  "/search/doctors",
  asyncHandler(async (req, res) => {
    const { q: query, city, specialization, page = 1, limit = 10 } = req.query;

    if (!query) {
      return res.status(400).json({
        success: false,
        message: "Search query is required",
      });
    }

    let filter = {
      role: "doctor",
      isActive: true,
      isVerified: true,
      $or: [
        { name: { $regex: query, $options: "i" } },
        { specialization: { $regex: query, $options: "i" } },
        { qualifications: { $regex: query, $options: "i" } },
      ],
    };

    if (city) {
      filter["address.city"] = { $regex: city, $options: "i" };
    }

    if (specialization) {
      filter.specialization = { $regex: specialization, $options: "i" };
    }

    const doctors = await User.find(filter)
      .select("-password")
      .sort({ "ratings.overall": -1, experience: -1 })
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    res.status(200).json({
      success: true,
      count: doctors.length,
      query,
      data: doctors,
    });
  })
);

module.exports = router;
