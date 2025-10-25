const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const { protect, asyncHandler } = require("../middleware/auth");

const router = express.Router();

// Generate JWT Token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE || "30d",
  });
};

// @desc    Register user
// @route   POST /api/auth/register
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
// @route   POST /api/auth/login
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
// @route   GET /api/auth/me
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

// @desc    Logout user / clear cookie
// @route   POST /api/auth/logout
// @access  Private
router.post(
  "/logout",
  protect,
  asyncHandler(async (req, res) => {
    res.status(200).json({
      success: true,
      message: "User logged out successfully",
    });
  })
);

// @desc    Forgot password
// @route   POST /api/auth/forgotpassword
// @access  Public
router.post(
  "/forgotpassword",
  asyncHandler(async (req, res) => {
    const { email } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found with this email",
      });
    }

    // For now, just return success message
    // In production, you would generate a reset token and send email
    res.status(200).json({
      success: true,
      message: "Password reset instructions sent to email",
    });
  })
);

// @desc    Reset password
// @route   PUT /api/auth/resetpassword/:resettoken
// @access  Public
router.put(
  "/resetpassword/:resettoken",
  asyncHandler(async (req, res) => {
    const { password } = req.body;
    const { resettoken } = req.params;

    // For now, just return success message
    // In production, you would validate the reset token
    res.status(200).json({
      success: true,
      message: "Password has been reset successfully",
    });
  })
);

// @desc    Update password
// @route   PUT /api/auth/updatepassword
// @access  Private
router.put(
  "/updatepassword",
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

// @desc    Verify phone number
// @route   POST /api/auth/verify-phone
// @access  Private
router.post(
  "/verify-phone",
  protect,
  asyncHandler(async (req, res) => {
    const { otp } = req.body;

    // For now, just return success
    // In production, you would validate the OTP
    res.status(200).json({
      success: true,
      message: "Phone number verified successfully",
    });
  })
);

// @desc    Send OTP for phone verification
// @route   POST /api/auth/send-otp
// @access  Private
router.post(
  "/send-otp",
  protect,
  asyncHandler(async (req, res) => {
    const { phone } = req.body;

    // For now, just return success
    // In production, you would send actual OTP via SMS
    res.status(200).json({
      success: true,
      message: "OTP sent to phone number",
      otp: "123456", // Only for development
    });
  })
);

module.exports = router;
