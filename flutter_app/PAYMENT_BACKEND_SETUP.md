# Razorpay Payment Backend Setup

This file contains the Node.js backend code needed to handle Razorpay payments for the Nabha Healthcare app.

## Installation

```bash
npm install express razorpay cors dotenv
```

## Environment Variables (.env)

```env
RAZORPAY_KEY_ID=rzp_test_5KDLZcQOeZLk8K
RAZORPAY_KEY_SECRET=iup6OxBjjs22NfyIV2vN4x8p
RAZORPAY_WEBHOOK_SECRET=69f8825c-ae86-4a76-89d5-501a621e772e
PORT=3001
```

## Backend Code (server.js)

```javascript
const express = require('express');
const Razorpay = require('razorpay');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// Create Order
app.post('/api/payments/create-order', async (req, res) => {
  try {
    const { amount, currency, receipt, notes } = req.body;
    
    const order = await razorpay.orders.create({
      amount: amount, // Amount in paise
      currency: currency || 'INR',
      receipt: receipt,
      notes: notes || {},
    });
    
    res.json(order);
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ error: 'Order creation failed' });
  }
});

// Verify Payment
app.post('/api/payments/verify', async (req, res) => {
  try {
    const { payment_id, order_id, signature } = req.body;
    
    const crypto = require('crypto');
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(order_id + '|' + payment_id)
      .digest('hex');
    
    if (expectedSignature === signature) {
      // Payment is verified
      res.json({ status: 'success', message: 'Payment verified successfully' });
    } else {
      res.status(400).json({ status: 'failure', message: 'Invalid signature' });
    }
  } catch (error) {
    console.error('Error verifying payment:', error);
    res.status(500).json({ error: 'Payment verification failed' });
  }
});

// Webhook
app.post('/api/payments/webhook', (req, res) => {
  const crypto = require('crypto');
  const expectedSignature = crypto
    .createHmac('sha256', process.env.RAZORPAY_WEBHOOK_SECRET)
    .update(JSON.stringify(req.body))
    .digest('hex');
  
  if (expectedSignature === req.headers['x-razorpay-signature']) {
    console.log('Webhook verified:', req.body);
    // Handle webhook events here
    res.status(200).json({ status: 'ok' });
  } else {
    res.status(400).json({ error: 'Invalid webhook signature' });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Payment server running on port ${PORT}`);
});
```

## Running the Backend

```bash
node server.js
```

The backend will be available at `http://localhost:3001`

## Testing

Use Razorpay test cards for testing:
- Card Number: 4111 1111 1111 1111
- Expiry: Any future date
- CVV: Any 3-digit number