# 🛒 Pharmacy Cart & Payment Integration

## Features Added

### 🛍️ Shopping Cart Functionality
- **Add to Cart**: Users can add medicines to their cart with quantity selection
- **Cart Management**: Update quantities, remove items, view total cost
- **Stock Validation**: Prevents adding more items than available stock
- **Prescription Check**: Identifies medicines requiring prescriptions
- **Persistent Cart**: Cart data persists during the session

### 💳 Payment Integration
- **Multiple Payment Methods**:
  - Cash on Delivery (COD)
  - Online Payment via Razorpay (UPI, Cards, Wallets)
- **Secure Checkout**: Complete customer information collection
- **Prescription Upload**: Required for prescription medicines
- **Order Confirmation**: Automatic order ID generation and confirmation

### 🏥 Enhanced Medicine Data
Each medicine now includes:
- **Price**: Display in Indian Rupees (₹)
- **Stock Information**: Available quantity tracking
- **Manufacturer**: Brand/company information
- **Description**: Brief medicine description
- **Prescription Status**: Whether prescription is required

## How to Use

### For Customers:
1. **Browse Medicines**: Search and view available medicines
2. **Add to Cart**: Click "Add to Cart" for desired medicines
3. **View Cart**: Click the floating cart button (bottom-right)
4. **Manage Cart**: Update quantities or remove items
5. **Checkout**: Click "Proceed to Checkout"
6. **Fill Details**: Provide delivery and contact information
7. **Upload Prescription**: If required for any medicine
8. **Choose Payment**: Select COD or Online Payment
9. **Complete Order**: Confirm and place your order

### For Pharmacists:
- **Inventory Management**: Add/edit medicines with pricing
- **Stock Tracking**: Monitor available quantities
- **Order Management**: View and process customer orders

## Payment Methods

### 💰 Cash on Delivery (COD)
- Pay when medicines are delivered
- No online transaction required
- Delivery charges: ₹50

### 💳 Online Payment (Razorpay)
- Secure payment processing
- Supports UPI, Credit/Debit Cards, Wallets
- Instant payment confirmation
- Same delivery charges: ₹50

## Medicine Categories & Pricing

| Medicine Type | Price Range | Prescription Required |
|---------------|-------------|----------------------|
| Basic Painkillers | ₹25 - ₹75 | No |
| Antibiotics | ₹180 - ₹220 | Yes |
| Vitamins | ₹80 - ₹150 | No |
| Chronic Care | ₹95 - ₹450 | Yes |
| Topical Treatments | ₹65 - ₹85 | No |

## Setup Instructions

### 1. Install Dependencies
```bash
npm install razorpay
```

### 2. Environment Configuration
Create a `.env` file with:
```env
VITE_RAZORPAY_KEY_ID=your_razorpay_key_id
VITE_RAZORPAY_KEY_SECRET=your_razorpay_secret
```

### 3. Get Razorpay API Keys
1. Sign up at [Razorpay Dashboard](https://dashboard.razorpay.com/)
2. Get your Test/Live API keys
3. Add them to your environment file

### 4. Backend Integration (Optional)
For production use, implement:
- Order creation API endpoint
- Payment verification webhook
- Order management system
- Email notifications

## Security Features

### 🔒 Data Protection
- Customer information encrypted during transmission
- Prescription files handled securely
- Payment processing via trusted gateway

### ✅ Validation
- Stock availability checking
- Prescription requirement enforcement
- Input sanitization and validation
- Order amount verification

## Mobile Responsive Design

The cart and checkout are fully responsive:
- **Desktop**: Full sidebar cart experience
- **Tablet**: Optimized for touch interactions
- **Mobile**: Full-screen cart and checkout modals

## Future Enhancements

### 🚀 Planned Features
- **Order Tracking**: Real-time delivery status
- **Reorder Function**: Quickly reorder previous purchases
- **Wishlist**: Save medicines for later
- **Bulk Discounts**: Quantity-based pricing
- **Insurance Integration**: Direct insurance billing
- **Subscription Service**: Regular medicine delivery

### 📱 Mobile App
- Native mobile app development planned
- Push notifications for order updates
- Barcode scanning for quick medicine search

## Support

For technical issues or questions:
- **Email**: support@nabhahealthcare.com
- **Phone**: +91 123 456 7890
- **Emergency**: Available 24/7 for urgent medicine needs

## License

This pharmacy cart and payment system is part of the Nabha Healthcare platform.
© 2025 Nabha Healthcare. All rights reserved.