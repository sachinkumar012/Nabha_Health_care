const express = require("express");
const Hospital = require("../models/Hospital");
const { asyncHandler } = require("../middleware/auth");

const router = express.Router();

// @desc    Get all hospitals
// @route   GET /api/hospitals
// @access  Public
router.get(
  "/",
  asyncHandler(async (req, res) => {
    const {
      search,
      city,
      state,
      type,
      specialty,
      minRating = 0,
      page = 1,
      limit = 20,
    } = req.query;

    const options = {
      city,
      state,
      type,
      specialty,
      minRating: parseFloat(minRating),
      limit: parseInt(limit),
      skip: (parseInt(page) - 1) * parseInt(limit),
    };

    const hospitals = await Hospital.searchHospitals(search, options);
    const total = await Hospital.countDocuments({
      isActive: true,
      isOperational: true,
      "ratings.overall": { $gte: parseFloat(minRating) },
    });

    res.status(200).json({
      success: true,
      count: hospitals.length,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      data: hospitals,
    });
  })
);

// @desc    Get hospital by ID
// @route   GET /api/hospitals/:id
// @access  Public
router.get(
  "/:id",
  asyncHandler(async (req, res) => {
    const hospital = await Hospital.findById(req.params.id);

    if (!hospital) {
      return res.status(404).json({
        success: false,
        message: "Hospital not found",
      });
    }

    res.status(200).json({
      success: true,
      data: hospital,
    });
  })
);

// @desc    Find nearby hospitals
// @route   GET /api/hospitals/nearby
// @access  Public
router.get(
  "/nearby",
  asyncHandler(async (req, res) => {
    const { lat, lng, radius = 10000, specialty, emergency } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        message: "Latitude and longitude are required",
      });
    }

    const options = {
      specialty,
      hasEmergency: emergency === "true",
      limit: 20,
    };

    const hospitals = await Hospital.findNearby(
      parseFloat(lat),
      parseFloat(lng),
      parseInt(radius),
      options
    );

    res.status(200).json({
      success: true,
      count: hospitals.length,
      data: hospitals,
    });
  })
);

// @desc    Search hospitals
// @route   GET /api/hospitals/search
// @access  Public
router.get(
  "/search",
  asyncHandler(async (req, res) => {
    const {
      q: query,
      city,
      state,
      specialty,
      page = 1,
      limit = 10,
    } = req.query;

    if (!query) {
      return res.status(400).json({
        success: false,
        message: "Search query is required",
      });
    }

    const options = {
      city,
      state,
      specialty,
      limit: parseInt(limit),
      skip: (parseInt(page) - 1) * parseInt(limit),
    };

    const hospitals = await Hospital.searchHospitals(query, options);

    res.status(200).json({
      success: true,
      count: hospitals.length,
      query,
      data: hospitals,
    });
  })
);

// @desc    Get hospitals by specialty
// @route   GET /api/hospitals/specialty/:specialty
// @access  Public
router.get(
  "/specialty/:specialty",
  asyncHandler(async (req, res) => {
    const { specialty } = req.params;
    const { city, state, page = 1, limit = 20 } = req.query;

    const options = {
      city,
      state,
      limit: parseInt(limit),
    };

    const hospitals = await Hospital.findBySpecialty(specialty, options);

    res.status(200).json({
      success: true,
      count: hospitals.length,
      specialty,
      data: hospitals,
    });
  })
);

// @desc    Get available doctors for a hospital
// @route   GET /api/hospitals/:id/doctors
// @access  Public
router.get(
  "/:id/doctors",
  asyncHandler(async (req, res) => {
    const { specialty, day } = req.query;

    const hospital = await Hospital.findById(req.params.id);

    if (!hospital) {
      return res.status(404).json({
        success: false,
        message: "Hospital not found",
      });
    }

    const doctors = hospital.getAvailableDoctors(specialty, day);

    res.status(200).json({
      success: true,
      count: doctors.length,
      data: doctors,
    });
  })
);

module.exports = router;
