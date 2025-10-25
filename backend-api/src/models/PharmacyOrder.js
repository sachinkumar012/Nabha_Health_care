const mongoose = require("mongoose");

const pharmacyOrderSchema = new mongoose.Schema(
  {
    // Order Information
    orderId: {
      type: String,
      unique: true,
      required: true,
    },

    // Customer Information
    customer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Customer is required"],
    },

    // Order Items
    items: [
      {
        medicine: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Medicine",
          required: [true, "Medicine is required"],
        },
        name: {
          type: String,
          required: [true, "Medicine name is required"],
        },
        manufacturer: String,
        composition: String,
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
            "other",
          ],
          required: true,
        },
        requiresPrescription: {
          type: Boolean,
          default: false,
        },
        quantity: {
          type: Number,
          required: [true, "Quantity is required"],
          min: [1, "Quantity must be at least 1"],
        },
        unit: {
          type: String,
          enum: ["piece", "strip", "bottle", "vial", "tube", "box"],
          default: "piece",
        },
        pricePerUnit: {
          type: Number,
          required: [true, "Price per unit is required"],
          min: [0, "Price cannot be negative"],
        },
        discount: {
          type: Number,
          default: 0,
          min: [0, "Discount cannot be negative"],
          max: [100, "Discount cannot exceed 100%"],
        },
        totalPrice: {
          type: Number,
          required: [true, "Total price is required"],
          min: [0, "Total price cannot be negative"],
        },
        expiryDate: Date,
        batchNumber: String,
        availability: {
          type: String,
          enum: ["in_stock", "out_of_stock", "limited_stock"],
          default: "in_stock",
        },
      },
    ],

    // Prescription Information
    prescription: {
      required: {
        type: Boolean,
        default: false,
      },
      uploaded: {
        type: Boolean,
        default: false,
      },
      prescriptionUrl: String,
      doctorName: String,
      hospitalName: String,
      prescriptionDate: Date,
      verified: {
        type: Boolean,
        default: false,
      },
      verifiedBy: String,
      verifiedAt: Date,
      notes: String,
    },

    // Order Summary
    summary: {
      subtotal: {
        type: Number,
        required: [true, "Subtotal is required"],
        min: [0, "Subtotal cannot be negative"],
      },
      discount: {
        type: Number,
        default: 0,
        min: [0, "Discount cannot be negative"],
      },
      deliveryCharges: {
        type: Number,
        default: 0,
        min: [0, "Delivery charges cannot be negative"],
      },
      tax: {
        type: Number,
        default: 0,
        min: [0, "Tax cannot be negative"],
      },
      total: {
        type: Number,
        required: [true, "Total is required"],
        min: [0, "Total cannot be negative"],
      },
      currency: {
        type: String,
        default: "INR",
      },
    },

    // Delivery Information
    delivery: {
      type: {
        type: String,
        enum: ["home_delivery", "store_pickup"],
        default: "home_delivery",
      },
      address: {
        name: String,
        phone: String,
        street: String,
        landmark: String,
        city: String,
        state: String,
        pincode: String,
        country: {
          type: String,
          default: "India",
        },
        coordinates: {
          latitude: Number,
          longitude: Number,
        },
      },
      instructions: String,
      estimatedDeliveryDate: Date,
      actualDeliveryDate: Date,
      deliveryTime: {
        type: String,
        enum: ["morning", "afternoon", "evening", "anytime"],
        default: "anytime",
      },
      deliveryPartner: {
        name: String,
        phone: String,
        vehicleNumber: String,
      },
      trackingId: String,
    },

    // Order Status
    status: {
      type: String,
      enum: [
        "pending",
        "prescription_verification",
        "confirmed",
        "processing",
        "packed",
        "shipped",
        "out_for_delivery",
        "delivered",
        "cancelled",
        "refunded",
      ],
      default: "pending",
    },

    // Status History
    statusHistory: [
      {
        status: {
          type: String,
          required: true,
        },
        timestamp: {
          type: Date,
          default: Date.now,
        },
        note: String,
        updatedBy: String,
      },
    ],

    // Payment Information
    payment: {
      method: {
        type: String,
        enum: ["razorpay", "cod", "upi", "card", "netbanking", "wallet"],
        required: [true, "Payment method is required"],
      },
      status: {
        type: String,
        enum: ["pending", "completed", "failed", "refunded", "partial_refund"],
        default: "pending",
      },
      paymentId: String,
      orderId: String,
      signature: String,
      amount: {
        type: Number,
        required: [true, "Payment amount is required"],
      },
      paidAt: Date,
      refundId: String,
      refundAmount: Number,
      refundedAt: Date,
      refundReason: String,
    },

    // Pharmacy Information
    pharmacy: {
      name: {
        type: String,
        required: [true, "Pharmacy name is required"],
      },
      licenseNumber: String,
      address: {
        street: String,
        city: String,
        state: String,
        pincode: String,
      },
      phone: String,
      email: String,
    },

    // Order Dates
    orderDate: {
      type: Date,
      default: Date.now,
    },
    confirmedAt: Date,
    packedAt: Date,
    shippedAt: Date,
    deliveredAt: Date,
    cancelledAt: Date,

    // Cancellation Information
    cancellation: {
      reason: String,
      cancelledBy: {
        type: String,
        enum: ["customer", "pharmacy", "system"],
      },
      refundProcessed: {
        type: Boolean,
        default: false,
      },
    },

    // Rating and Review
    rating: {
      overall: {
        type: Number,
        min: [1, "Rating must be at least 1"],
        max: [5, "Rating cannot exceed 5"],
      },
      delivery: {
        type: Number,
        min: [1, "Rating must be at least 1"],
        max: [5, "Rating cannot exceed 5"],
      },
      packaging: {
        type: Number,
        min: [1, "Rating must be at least 1"],
        max: [5, "Rating cannot exceed 5"],
      },
      review: String,
      ratedAt: Date,
    },

    // Return/Exchange
    return: {
      requested: {
        type: Boolean,
        default: false,
      },
      reason: String,
      requestedAt: Date,
      status: {
        type: String,
        enum: ["pending", "approved", "rejected", "completed"],
      },
      processedAt: Date,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Generate order ID before saving
pharmacyOrderSchema.pre("save", function (next) {
  if (!this.orderId) {
    this.orderId = `PH${Date.now()}${Math.random()
      .toString(36)
      .substr(2, 6)
      .toUpperCase()}`;
  }

  // Calculate total if not provided
  if (!this.summary.total) {
    this.summary.total =
      this.summary.subtotal +
      this.summary.deliveryCharges +
      this.summary.tax -
      this.summary.discount;
  }

  // Add status to history
  if (this.isModified("status")) {
    this.statusHistory.push({
      status: this.status,
      timestamp: new Date(),
      note: `Status changed to ${this.status}`,
    });
  }

  next();
});

// Indexes for better performance
pharmacyOrderSchema.index({ customer: 1, orderDate: -1 });
pharmacyOrderSchema.index({ orderId: 1 });
pharmacyOrderSchema.index({ status: 1 });
pharmacyOrderSchema.index({ "payment.status": 1 });
pharmacyOrderSchema.index({ orderDate: -1 });

// Virtual for checking if prescription is required
pharmacyOrderSchema.virtual("requiresPrescriptionCheck").get(function () {
  return this.items.some((item) => item.requiresPrescription);
});

// Virtual for order value classification
pharmacyOrderSchema.virtual("orderValueCategory").get(function () {
  const total = this.summary.total;
  if (total < 500) return "low";
  if (total < 2000) return "medium";
  return "high";
});

// Static methods
pharmacyOrderSchema.statics.findByCustomer = function (
  customerId,
  status = null,
  limit = 20
) {
  const query = { customer: customerId };
  if (status) query.status = status;

  return this.find(query)
    .sort({ orderDate: -1 })
    .limit(limit)
    .populate("customer", "name email phone")
    .populate("items.medicine");
};

pharmacyOrderSchema.statics.findPendingPrescriptionVerification = function () {
  return this.find({
    "prescription.required": true,
    "prescription.uploaded": true,
    "prescription.verified": false,
    status: "prescription_verification",
  }).populate("customer", "name email phone");
};

// Instance methods
pharmacyOrderSchema.methods.canCancel = function () {
  const cancellableStatuses = [
    "pending",
    "prescription_verification",
    "confirmed",
  ];
  return cancellableStatuses.includes(this.status);
};

pharmacyOrderSchema.methods.canReturn = function () {
  if (this.status !== "delivered") return false;

  const deliveryDate = this.deliveredAt;
  if (!deliveryDate) return false;

  // Allow returns within 7 days of delivery
  const daysSinceDelivery = (new Date() - deliveryDate) / (1000 * 60 * 60 * 24);
  return daysSinceDelivery <= 7;
};

pharmacyOrderSchema.methods.updateStatus = function (
  newStatus,
  note = "",
  updatedBy = "system"
) {
  this.status = newStatus;
  this.statusHistory.push({
    status: newStatus,
    timestamp: new Date(),
    note: note || `Status updated to ${newStatus}`,
    updatedBy,
  });

  // Set date fields based on status
  const now = new Date();
  switch (newStatus) {
    case "confirmed":
      this.confirmedAt = now;
      break;
    case "packed":
      this.packedAt = now;
      break;
    case "shipped":
      this.shippedAt = now;
      break;
    case "delivered":
      this.deliveredAt = now;
      break;
    case "cancelled":
      this.cancelledAt = now;
      break;
  }

  return this.save();
};

module.exports = mongoose.model("PharmacyOrder", pharmacyOrderSchema);
