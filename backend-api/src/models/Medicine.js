const mongoose = require("mongoose");

const medicineSchema = new mongoose.Schema(
  {
    // Basic Information
    name: {
      type: String,
      required: [true, "Medicine name is required"],
      trim: true,
      index: true,
    },
    genericName: {
      type: String,
      trim: true,
      index: true,
    },
    brand: {
      type: String,
      trim: true,
    },
    manufacturer: {
      type: String,
      required: [true, "Manufacturer is required"],
      trim: true,
    },

    // Medicine Details
    composition: {
      type: String,
      required: [true, "Composition is required"],
    },
    strength: {
      type: String,
      required: [true, "Strength is required"],
    },
    category: {
      type: String,
      enum: [
        "tablet",
        "capsule",
        "syrup",
        "injection",
        "ointment",
        "drops",
        "inhaler",
        "powder",
        "gel",
        "cream",
        "lotion",
        "spray",
        "patch",
        "suppository",
        "other",
      ],
      required: [true, "Category is required"],
    },
    therapeuticClass: {
      type: String,
      required: [true, "Therapeutic class is required"],
    },

    // Regulatory Information
    drugCode: {
      type: String,
      unique: true,
      sparse: true,
    },
    licenseNumber: String,
    approvalDate: Date,
    regulatoryAuthority: {
      type: String,
      default: "CDSCO", // Central Drugs Standard Control Organization
    },

    // Prescription Requirements
    requiresPrescription: {
      type: Boolean,
      required: [true, "Prescription requirement must be specified"],
      default: false,
    },
    scheduleType: {
      type: String,
      enum: ["H", "H1", "X", "G", "OTC"], // Indian drug scheduling
      required: function () {
        return this.requiresPrescription;
      },
    },

    // Packaging Information
    packaging: {
      packSize: {
        type: Number,
        required: [true, "Pack size is required"],
        min: [1, "Pack size must be at least 1"],
      },
      unit: {
        type: String,
        enum: ["piece", "ml", "gm", "strip", "vial"],
        required: [true, "Unit is required"],
      },
      packType: {
        type: String,
        enum: ["strip", "bottle", "vial", "tube", "box", "blister", "sachet"],
        required: [true, "Pack type is required"],
      },
    },

    // Pricing Information
    pricing: {
      mrp: {
        type: Number,
        required: [true, "MRP is required"],
        min: [0, "MRP cannot be negative"],
      },
      costPrice: {
        type: Number,
        min: [0, "Cost price cannot be negative"],
      },
      sellingPrice: {
        type: Number,
        required: [true, "Selling price is required"],
        min: [0, "Selling price cannot be negative"],
      },
      discount: {
        type: Number,
        default: 0,
        min: [0, "Discount cannot be negative"],
        max: [100, "Discount cannot exceed 100%"],
      },
      currency: {
        type: String,
        default: "INR",
      },
      gst: {
        type: Number,
        default: 12, // Default GST rate for medicines in India
        min: [0, "GST cannot be negative"],
      },
    },

    // Stock Information
    inventory: {
      currentStock: {
        type: Number,
        required: [true, "Current stock is required"],
        min: [0, "Stock cannot be negative"],
        default: 0,
      },
      minStock: {
        type: Number,
        default: 10,
        min: [0, "Minimum stock cannot be negative"],
      },
      maxStock: {
        type: Number,
        default: 1000,
        min: [0, "Maximum stock cannot be negative"],
      },
      reorderLevel: {
        type: Number,
        default: 20,
        min: [0, "Reorder level cannot be negative"],
      },
      lastRestocked: Date,
      supplier: String,
    },

    // Expiry and Batch Information
    batches: [
      {
        batchNumber: {
          type: String,
          required: true,
        },
        manufactureDate: {
          type: Date,
          required: true,
        },
        expiryDate: {
          type: Date,
          required: true,
          validate: {
            validator: function (v) {
              return v > this.manufactureDate;
            },
            message: "Expiry date must be after manufacture date",
          },
        },
        quantity: {
          type: Number,
          required: true,
          min: [0, "Quantity cannot be negative"],
        },
        costPrice: Number,
        sellingPrice: Number,
      },
    ],

    // Usage Information
    indications: [String],
    contraindications: [String],
    sideEffects: [String],
    dosage: {
      adult: String,
      child: String,
      elderly: String,
      instructions: String,
    },
    interactions: [String],
    warnings: [String],
    storage: {
      type: String,
      default: "Store in a cool, dry place",
    },

    // Search and SEO
    keywords: [String],
    tags: [String],
    description: String,

    // Media
    images: [
      {
        url: String,
        alt: String,
        isPrimary: {
          type: Boolean,
          default: false,
        },
      },
    ],

    // Availability
    isActive: {
      type: Boolean,
      default: true,
    },
    isAvailable: {
      type: Boolean,
      default: true,
    },
    availabilityStatus: {
      type: String,
      enum: ["in_stock", "out_of_stock", "limited_stock", "discontinued"],
      default: "in_stock",
    },

    // Alternative Medicines
    alternatives: [
      {
        medicineId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Medicine",
        },
        name: String,
        reason: String, // e.g., 'same_composition', 'similar_effect', 'cheaper_option'
      },
    ],

    // Ratings and Reviews
    ratings: {
      average: {
        type: Number,
        default: 0,
        min: [0, "Rating cannot be negative"],
        max: [5, "Rating cannot exceed 5"],
      },
      count: {
        type: Number,
        default: 0,
        min: [0, "Count cannot be negative"],
      },
    },

    // Usage Statistics
    statistics: {
      viewCount: {
        type: Number,
        default: 0,
      },
      orderCount: {
        type: Number,
        default: 0,
      },
      lastOrdered: Date,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes for better search performance
medicineSchema.index({ name: "text", genericName: "text", keywords: "text" });
medicineSchema.index({ name: 1 });
medicineSchema.index({ genericName: 1 });
medicineSchema.index({ category: 1 });
medicineSchema.index({ therapeuticClass: 1 });
medicineSchema.index({ manufacturer: 1 });
medicineSchema.index({ requiresPrescription: 1 });
medicineSchema.index({ isActive: 1, isAvailable: 1 });
medicineSchema.index({ "pricing.sellingPrice": 1 });

// Virtual for checking if medicine is in stock
medicineSchema.virtual("inStock").get(function () {
  return this.inventory.currentStock > 0 && this.isAvailable;
});

// Virtual for checking if medicine needs reordering
medicineSchema.virtual("needsReorder").get(function () {
  return this.inventory.currentStock <= this.inventory.reorderLevel;
});

// Virtual for checking if medicine is expiring soon
medicineSchema.virtual("expiringSoon").get(function () {
  const now = new Date();
  const thirtyDaysFromNow = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

  return this.batches.some(
    (batch) => batch.expiryDate <= thirtyDaysFromNow && batch.quantity > 0
  );
});

// Virtual for effective price after discount
medicineSchema.virtual("effectivePrice").get(function () {
  const discount = this.pricing.discount || 0;
  return this.pricing.sellingPrice * (1 - discount / 100);
});

// Pre-save middleware
medicineSchema.pre("save", function (next) {
  // Update availability status based on stock
  if (this.inventory.currentStock === 0) {
    this.availabilityStatus = "out_of_stock";
    this.isAvailable = false;
  } else if (this.inventory.currentStock <= this.inventory.minStock) {
    this.availabilityStatus = "limited_stock";
  } else {
    this.availabilityStatus = "in_stock";
    this.isAvailable = true;
  }

  // Ensure only one primary image
  if (this.images && this.images.length > 0) {
    const primaryImages = this.images.filter((img) => img.isPrimary);
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
medicineSchema.statics.searchMedicines = function (query, options = {}) {
  const {
    category,
    requiresPrescription,
    minPrice,
    maxPrice,
    manufacturer,
    inStock = true,
    limit = 20,
    skip = 0,
    sortBy = "name",
  } = options;

  const searchQuery = {
    isActive: true,
    ...(inStock && { isAvailable: true, "inventory.currentStock": { $gt: 0 } }),
  };

  // Text search
  if (query) {
    searchQuery.$text = { $search: query };
  }

  // Filters
  if (category) searchQuery.category = category;
  if (typeof requiresPrescription === "boolean")
    searchQuery.requiresPrescription = requiresPrescription;
  if (manufacturer) searchQuery.manufacturer = manufacturer;
  if (minPrice || maxPrice) {
    searchQuery["pricing.sellingPrice"] = {};
    if (minPrice) searchQuery["pricing.sellingPrice"].$gte = minPrice;
    if (maxPrice) searchQuery["pricing.sellingPrice"].$lte = maxPrice;
  }

  return this.find(searchQuery).sort(sortBy).limit(limit).skip(skip);
};

medicineSchema.statics.findExpiringBatches = function (days = 30) {
  const expiryDate = new Date();
  expiryDate.setDate(expiryDate.getDate() + days);

  return this.find({
    "batches.expiryDate": { $lte: expiryDate },
    "batches.quantity": { $gt: 0 },
  });
};

medicineSchema.statics.findLowStock = function () {
  return this.find({
    $expr: { $lte: ["$inventory.currentStock", "$inventory.reorderLevel"] },
    isActive: true,
  });
};

// Instance methods
medicineSchema.methods.updateStock = function (quantity, operation = "add") {
  if (operation === "add") {
    this.inventory.currentStock += quantity;
    this.inventory.lastRestocked = new Date();
  } else if (operation === "subtract") {
    this.inventory.currentStock = Math.max(
      0,
      this.inventory.currentStock - quantity
    );
  } else {
    this.inventory.currentStock = quantity;
  }

  return this.save();
};

medicineSchema.methods.addBatch = function (batchData) {
  this.batches.push(batchData);
  this.inventory.currentStock += batchData.quantity;
  this.inventory.lastRestocked = new Date();
  return this.save();
};

medicineSchema.methods.updateRating = function (newRating) {
  const currentTotal = this.ratings.average * this.ratings.count;
  this.ratings.count += 1;
  this.ratings.average = (currentTotal + newRating) / this.ratings.count;
  return this.save();
};

module.exports = mongoose.model("Medicine", medicineSchema);
