const express = require("express");
const Medicine = require("../models/Medicine");
const { asyncHandler } = require("../middleware/auth");

const router = express.Router();

// @desc    Get all medicines
// @route   GET /api/pharmacy/medicines
// @access  Public
router.get(
  "/medicines",
  asyncHandler(async (req, res) => {
    const {
      search,
      category,
      minPrice,
      maxPrice,
      inStock = true,
      page = 1,
      limit = 20,
    } = req.query;

    const options = {
      category,
      minPrice: minPrice ? parseFloat(minPrice) : undefined,
      maxPrice: maxPrice ? parseFloat(maxPrice) : undefined,
      inStock: inStock === "true",
      limit: parseInt(limit),
      skip: (parseInt(page) - 1) * parseInt(limit),
    };

    const medicines = await Medicine.searchMedicines(search, options);
    const total = await Medicine.countDocuments({
      isActive: true,
      ...(inStock === "true" && {
        isAvailable: true,
        "inventory.currentStock": { $gt: 0 },
      }),
    });

    res.status(200).json({
      success: true,
      count: medicines.length,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      data: medicines,
    });
  })
);

// @desc    Get medicine by ID
// @route   GET /api/pharmacy/medicines/:id
// @access  Public
router.get(
  "/medicines/:id",
  asyncHandler(async (req, res) => {
    const medicine = await Medicine.findById(req.params.id);

    if (!medicine) {
      return res.status(404).json({
        success: false,
        message: "Medicine not found",
      });
    }

    res.status(200).json({
      success: true,
      data: medicine,
    });
  })
);

// @desc    Search medicines
// @route   GET /api/pharmacy/search
// @access  Public
router.get(
  "/search",
  asyncHandler(async (req, res) => {
    const { q: query, category, page = 1, limit = 10 } = req.query;

    if (!query) {
      return res.status(400).json({
        success: false,
        message: "Search query is required",
      });
    }

    const options = {
      category,
      inStock: true,
      limit: parseInt(limit),
      skip: (parseInt(page) - 1) * parseInt(limit),
    };

    const medicines = await Medicine.searchMedicines(query, options);

    res.status(200).json({
      success: true,
      count: medicines.length,
      query,
      data: medicines,
    });
  })
);

// @desc    Get medicine categories
// @route   GET /api/pharmacy/categories
// @access  Public
router.get(
  "/categories",
  asyncHandler(async (req, res) => {
    const categories = await Medicine.distinct("category", { isActive: true });

    res.status(200).json({
      success: true,
      data: categories,
    });
  })
);

// @desc    Get low stock medicines
// @route   GET /api/pharmacy/low-stock
// @access  Private (Admin)
router.get(
  "/low-stock",
  asyncHandler(async (req, res) => {
    const medicines = await Medicine.findLowStock();

    res.status(200).json({
      success: true,
      count: medicines.length,
      data: medicines,
    });
  })
);

module.exports = router;
