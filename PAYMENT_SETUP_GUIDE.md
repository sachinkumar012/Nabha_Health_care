# 💳 Payment Integration Setup Guide

## 🚀 Quick Start

Your Nabha Healthcare application is now configured with your Razorpay API keys:

### API Keys Configuration ✅
- **Key ID**: `rzp_test_5KDLZcQOeZLk8K`
- **Secret**: `iup6OxBjjs22NfyIV2vN4x8p`
- **Monthly Plan**: `plan_Qq8H89m2adcMl6`
- **Yearly Plan**: `plan_Qq8Hl09aOS9uAg`
- **Webhook Secret**: `69f8825c-ae86-4a76-89d5-501a621e772e`
- **Google OAuth**: `373702281069-uu025bq20lpq6eivio8h2674up6g57uj.apps.googleusercontent.com`

## 🏥 Frontend Payment Features

### 1. Customer Authentication Required
- Users must create an account to add medicines to cart
- Secure customer data management
- Profile information auto-fills in checkout

### 2. Shopping Cart System
- Add/remove medicines with quantity control
- Real-time price calculation
- Stock validation
- Prescription requirement checking

### 3. Checkout Process
- Customer information collection
- Prescription file upload for required medicines
- Payment method selection (COD/Online)
- Order confirmation with tracking

### 4. Payment Methods
- **Cash on Delivery (COD)**: Pay on delivery
- **Online Payment**: Razorpay integration with UPI, Cards, Wallets

## 🖥️ Backend Server Setup

### Step 1: Create Backend Directory
```bash
mkdir nabha-backend
cd nabha-backend
```

### Step 2: Initialize Node.js Project
```bash
npm init -y
```

### Step 3: Install Dependencies
```bash
npm install express razorpay cors dotenv helmet morgan
npm install -D nodemon jest
```

### Step 4: Copy Server Files
1. Copy `server-payment-api.js` to your backend directory
2. Copy `server-package.json` content to `package.json`

### Step 5: Create Environment File
Create `.env` in backend directory:
```env
PORT=5001
RAZORPAY_KEY_ID=rzp_test_5KDLZcQOeZLk8K
RAZORPAY_KEY_SECRET=iup6OxBjjs22NfyIV2vN4x8p
RAZORPAY_WEBHOOK_SECRET=69f8825c-ae86-4a76-89d5-501a621e772e
NODE_ENV=development
```

### Step 6: Start Backend Server
```bash
npm run dev
```

The server will run on `http://localhost:5001`

## 🔧 Frontend Configuration

### Environment Variables
The frontend `.env` file is already configured with your API keys:

```env
VITE_RAZORPAY_KEY_ID=rzp_test_5KDLZcQOeZLk8K
VITE_SERVER_ENDPOINT=http://localhost:5001
VITE_GOOGLE_CLIENT_ID=373702281069-uu025bq20lpq6eivio8h2674up6g57uj.apps.googleusercontent.com
```

### Start Frontend
```bash
npm run dev
```

## 📱 Testing the Integration

### 1. Customer Registration
1. Visit the pharmacy page
2. Try to add a medicine to cart
3. You'll be prompted to create an account
4. Fill in registration details

### 2. Medicine Purchase
1. Browse available medicines
2. Add medicines to cart
3. Open cart sidebar (floating button)
4. Proceed to checkout
5. Fill delivery information
6. Upload prescription if required
7. Choose payment method
8. Complete order

### 3. Test Payment Details

#### Test Card Numbers (Razorpay Test Mode)
- **Success**: 4111 1111 1111 1111
- **Failure**: 4111 1111 1111 1112
- **CVV**: Any 3 digits
- **Expiry**: Any future date

#### Test UPI IDs
- **Success**: success@razorpay
- **Failure**: failure@razorpay

## 🔒 Security Features

### 1. Payment Security
- Secure Razorpay payment gateway
- PCI DSS compliance
- Encrypted data transmission
- Server-side payment verification

### 2. Customer Data Protection
- Input validation and sanitization
- Secure file upload for prescriptions
- Customer authentication required
- HTTPS recommended for production

### 3. Order Management
- Unique order ID generation
- Order status tracking
- Payment verification
- Receipt generation

## 🌐 Production Deployment

### 1. Razorpay Live Keys
Replace test keys with live keys in production:
1. Login to [Razorpay Dashboard](https://dashboard.razorpay.com/)
2. Switch to Live mode
3. Generate Live API keys
4. Update environment variables

### 2. Webhook Configuration
Set up webhook URL in Razorpay Dashboard:
- **URL**: `https://yourdomain.com/api/webhooks/razorpay`
- **Secret**: Use your webhook secret
- **Events**: Select payment and subscription events

### 3. SSL Certificate
- Obtain SSL certificate for HTTPS
- Configure your domain
- Update CORS settings

## 📊 API Endpoints

### Payment APIs
- `POST /api/orders` - Create payment order
- `POST /api/payments/verify` - Verify payment
- `POST /api/webhooks/razorpay` - Webhook handler
- `GET /api/payments/:paymentId` - Get payment details
- `POST /api/payments/:paymentId/refund` - Process refund

### Subscription APIs
- `POST /api/subscriptions` - Create subscription
- `GET /api/subscriptions/:subscriptionId` - Get subscription details

## 🐛 Troubleshooting

### Common Issues

#### 1. Payment Fails
- Check API keys are correct
- Verify test card details
- Check network connectivity
- Review browser console for errors

#### 2. Order Not Created
- Verify backend server is running
- Check CORS configuration
- Validate request parameters
- Review server logs

#### 3. Webhook Not Received
- Verify webhook URL is accessible
- Check webhook secret matches
- Ensure server is running
- Review Razorpay dashboard logs

### Debug Mode
Set `VITE_DEBUG_MODE=true` in frontend `.env` for detailed logging.

## 📞 Support

### Razorpay Support
- **Documentation**: https://razorpay.com/docs/
- **Dashboard**: https://dashboard.razorpay.com/
- **Support**: support@razorpay.com

### Technical Issues
- Check browser console for errors
- Review network requests in developer tools
- Verify API key permissions
- Test with different payment methods

## 🎯 Next Steps

### Enhancements
1. **Order Tracking**: Real-time delivery status
2. **Email Notifications**: Order confirmations and updates
3. **SMS Integration**: Delivery notifications
4. **Inventory Management**: Real-time stock updates
5. **Analytics**: Payment and order analytics
6. **Mobile App**: React Native implementation

### Database Integration
Consider adding:
- Customer management system
- Order history database
- Inventory tracking
- Payment analytics
- Prescription management

Your payment integration is now ready for testing and deployment! 🎉