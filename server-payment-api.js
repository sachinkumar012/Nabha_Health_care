// Backend API endpoints for Nabha Healthcare Payment Integration
// This file shows how to implement the required endpoints for your Express.js server

const express = require("express");
const Razorpay = require("razorpay");
const crypto = require("crypto");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

// Initialize Razorpay instance
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID || "rzp_test_5KDLZcQOeZLk8K",
  key_secret: process.env.RAZORPAY_KEY_SECRET || "iup6OxBjjs22NfyIV2vN4x8p",
});

const WEBHOOK_SECRET =
  process.env.RAZORPAY_WEBHOOK_SECRET || "69f8825c-ae86-4a76-89d5-501a621e772e";

// Create Order Endpoint
app.post("/api/orders", async (req, res) => {
  try {
    const { amount, currency, customer_info } = req.body;

    const options = {
      amount: amount, // amount in paise
      currency: currency || "INR",
      receipt: `receipt_${Date.now()}`,
      payment_capture: 1,
      notes: {
        customer_name: customer_info?.name,
        customer_email: customer_info?.email,
        customer_phone: customer_info?.phone,
        delivery_address: customer_info?.address,
        city: customer_info?.city,
        pincode: customer_info?.pincode,
      },
    };

    const order = await razorpay.orders.create(options);

    res.json({
      success: true,
      id: order.id,
      amount: order.amount,
      currency: order.currency,
      receipt: order.receipt,
    });
  } catch (error) {
    console.error("Order creation error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to create order",
    });
  }
});

// Verify Payment Endpoint
app.post("/api/payments/verify", (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } =
      req.body;

    // Create signature
    const body = razorpay_order_id + "|" + razorpay_payment_id;
    const expectedSignature = crypto
      .createHmac(
        "sha256",
        process.env.RAZORPAY_KEY_SECRET || "iup6OxBjjs22NfyIV2vN4x8p"
      )
      .update(body.toString())
      .digest("hex");

    const isAuthentic = expectedSignature === razorpay_signature;

    if (isAuthentic) {
      // Payment is verified
      // Here you can update your database, send confirmation emails, etc.

      res.json({
        success: true,
        verified: true,
        payment_id: razorpay_payment_id,
        order_id: razorpay_order_id,
      });
    } else {
      res.status(400).json({
        success: false,
        verified: false,
        error: "Invalid payment signature",
      });
    }
  } catch (error) {
    console.error("Payment verification error:", error);
    res.status(500).json({
      success: false,
      verified: false,
      error: "Payment verification failed",
    });
  }
});

// Create Subscription Endpoint
app.post("/api/subscriptions", async (req, res) => {
  try {
    const { plan_id, customer_info, total_count } = req.body;

    const subscriptionOptions = {
      plan_id: plan_id,
      customer_notify: 1,
      quantity: 1,
      total_count: total_count || 12,
      start_at: Math.floor(Date.now() / 1000) + 24 * 60 * 60, // Start after 24 hours
      notes: {
        customer_name: customer_info?.name,
        customer_email: customer_info?.email,
        customer_phone: customer_info?.phone,
      },
    };

    const subscription = await razorpay.subscriptions.create(
      subscriptionOptions
    );

    res.json({
      success: true,
      id: subscription.id,
      status: subscription.status,
      plan_id: subscription.plan_id,
    });
  } catch (error) {
    console.error("Subscription creation error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to create subscription",
    });
  }
});

// Webhook Endpoint for Payment Notifications
app.post("/api/webhooks/razorpay", (req, res) => {
  try {
    const signature = req.headers["x-razorpay-signature"];
    const body = JSON.stringify(req.body);

    // Verify webhook signature
    const expectedSignature = crypto
      .createHmac("sha256", WEBHOOK_SECRET)
      .update(body)
      .digest("hex");

    if (signature === expectedSignature) {
      // Webhook is verified
      const event = req.body.event;
      const payload = req.body.payload;

      switch (event) {
        case "payment.captured":
          console.log("Payment captured:", payload.payment.entity);
          // Update order status in database
          // Send confirmation email to customer
          break;

        case "payment.failed":
          console.log("Payment failed:", payload.payment.entity);
          // Update order status in database
          // Send failure notification
          break;

        case "subscription.charged":
          console.log("Subscription charged:", payload.subscription.entity);
          // Update subscription status
          // Send receipt to customer
          break;

        case "subscription.completed":
          console.log("Subscription completed:", payload.subscription.entity);
          // Handle subscription completion
          break;

        default:
          console.log("Unhandled webhook event:", event);
      }

      res.json({ status: "ok" });
    } else {
      res.status(400).json({ error: "Invalid signature" });
    }
  } catch (error) {
    console.error("Webhook processing error:", error);
    res.status(500).json({ error: "Webhook processing failed" });
  }
});

// Get Payment Details Endpoint
app.get("/api/payments/:paymentId", async (req, res) => {
  try {
    const { paymentId } = req.params;
    const payment = await razorpay.payments.fetch(paymentId);

    res.json({
      success: true,
      payment: payment,
    });
  } catch (error) {
    console.error("Fetch payment error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to fetch payment details",
    });
  }
});

// Get Order Details Endpoint
app.get("/api/orders/:orderId", async (req, res) => {
  try {
    const { orderId } = req.params;
    const order = await razorpay.orders.fetch(orderId);

    res.json({
      success: true,
      order: order,
    });
  } catch (error) {
    console.error("Fetch order error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to fetch order details",
    });
  }
});

// Refund Payment Endpoint
app.post("/api/payments/:paymentId/refund", async (req, res) => {
  try {
    const { paymentId } = req.params;
    const { amount, reason } = req.body;

    const refundOptions = {
      amount: amount, // amount in paise, leave empty for full refund
      speed: "normal",
      notes: {
        reason: reason || "Customer request",
      },
    };

    const refund = await razorpay.payments.refund(paymentId, refundOptions);

    res.json({
      success: true,
      refund: refund,
    });
  } catch (error) {
    console.error("Refund error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to process refund",
    });
  }
});

const PORT = process.env.PORT || 5001;

app.listen(PORT, () => {
  console.log(`🚀 Nabha Healthcare Payment Server running on port ${PORT}`);
  console.log(
    `📡 Webhook endpoint: http://localhost:${PORT}/api/webhooks/razorpay`
  );
  console.log(`💳 Payment API ready with Razorpay integration`);
});

module.exports = app;
