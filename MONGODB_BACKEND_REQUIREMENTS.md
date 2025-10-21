# 🏥 Nabha Healthcare - MongoDB Backend Requirements

## 📋 Overview

Based on your Flutter healthcare app, here are the comprehensive requirements for setting up a MongoDB backend to support all your app's features.

## 🎯 Current App Features Requiring Backend

### 🔐 **User Management**
- User registration/login (Google Sign-In integration)
- Profile management with image uploads
- Role-based access (patients, doctors, pharmacists, admins)
- Session management and JWT tokens

### 🏥 **Healthcare Features**
- **Appointments**: Booking, scheduling, management
- **Pharmacy**: Medicine catalog, cart, orders, payments
- **Medical Records**: Patient health history, prescriptions
- **Symptom Checker**: AI chat history, health assessments
- **Video Calls**: Call scheduling, room management
- **ABHA**: Health ID integration
- **Hospitals**: Location data, services, reviews

### 💾 **Current Data Storage**
Your app currently uses:
- Local storage (SharedPreferences)
- In-memory state (Riverpod providers)
- Mock data for testing

## 🛠️ MongoDB Backend Requirements

### **1. Technology Stack**
```
Backend Framework: Node.js + Express.js
Database: MongoDB (Atlas Cloud or Local)
ODM: Mongoose
Authentication: JWT + bcrypt
File Storage: Multer + AWS S3/Cloudinary
Payment: Razorpay integration
Real-time: Socket.io (for chat/video calls)
```

### **2. Dependencies Required**
```json
{
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^8.0.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "multer": "^1.4.5",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "express-rate-limit": "^7.0.0",
    "razorpay": "^2.9.2",
    "socket.io": "^4.7.2",
    "nodemailer": "^6.9.7",
    "cloudinary": "^1.40.0",
    "dotenv": "^16.3.1",
    "express-validator": "^7.0.1",
    "compression": "^1.7.4",
    "winston": "^3.10.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.7.0",
    "supertest": "^6.3.3"
  }
}
```

### **3. Database Collections Needed**

#### **Users Collection**
```javascript
{
  _id: ObjectId,
  email: String,
  phone: String,
  name: String,
  profileImageUrl: String,
  userType: ["patient", "doctor", "pharmacist", "admin"],
  googleId: String, // For Google Sign-In
  password: String, // Hashed
  isVerified: Boolean,
  createdAt: Date,
  updatedAt: Date,
  // Patient specific fields
  dateOfBirth: Date,
  gender: String,
  address: Object,
  emergencyContact: Object,
  // Doctor specific fields
  specialization: String,
  license: String,
  experience: Number,
  rating: Number,
  // Pharmacist specific fields
  pharmacyId: ObjectId
}
```

#### **Appointments Collection**
```javascript
{
  _id: ObjectId,
  patientId: ObjectId,
  doctorId: ObjectId,
  appointmentType: ["video", "in-person", "chat"],
  dateTime: Date,
  duration: Number,
  status: ["scheduled", "completed", "cancelled", "no-show"],
  fee: Number,
  symptoms: [String],
  notes: String,
  prescription: Object,
  paymentStatus: String,
  createdAt: Date,
  updatedAt: Date
}
```

#### **Pharmacy Orders Collection**
```javascript
{
  _id: ObjectId,
  orderId: String, // NH + timestamp format
  userId: ObjectId,
  items: [{
    medicineId: ObjectId,
    name: String,
    price: Number,
    quantity: Number,
    dosage: String,
    manufacturer: String
  }],
  customerInfo: {
    name: String,
    email: String,
    phone: String,
    address: String,
    pincode: String
  },
  paymentInfo: {
    method: ["cod", "online"],
    status: ["pending", "completed", "failed"],
    razorpayOrderId: String,
    razorpayPaymentId: String
  },
  status: ["pending", "confirmed", "processing", "shipped", "delivered", "cancelled"],
  totalAmount: Number,
  deliveryFee: Number,
  estimatedDelivery: Date,
  trackingNumber: String,
  statusHistory: [{
    status: String,
    timestamp: Date,
    message: String,
    location: String
  }],
  createdAt: Date,
  updatedAt: Date
}
```

#### **Medicines Collection**
```javascript
{
  _id: ObjectId,
  name: String,
  type: ["tablet", "capsule", "syrup", "injection"],
  manufacturer: String,
  price: Number,
  originalPrice: Number,
  discount: Number,
  description: String,
  uses: [String],
  sideEffects: [String],
  dosage: String,
  prescriptionRequired: Boolean,
  inStock: Number,
  imageUrl: String,
  category: String,
  rating: Number,
  reviews: [{
    userId: ObjectId,
    rating: Number,
    comment: String,
    date: Date
  }],
  createdAt: Date,
  updatedAt: Date
}
```

#### **Medical Records Collection**
```javascript
{
  _id: ObjectId,
  patientId: ObjectId,
  doctorId: ObjectId,
  appointmentId: ObjectId,
  recordType: ["consultation", "prescription", "lab-report", "imaging"],
  title: String,
  description: String,
  diagnosis: String,
  prescription: [{
    medicine: String,
    dosage: String,
    frequency: String,
    duration: String,
    instructions: String
  }],
  attachments: [String], // File URLs
  isPrivate: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

#### **Hospitals Collection**
```javascript
{
  _id: ObjectId,
  name: String,
  address: Object,
  location: {
    type: "Point",
    coordinates: [Number, Number] // [longitude, latitude]
  },
  phone: [String],
  email: String,
  website: String,
  services: [String],
  specialties: [String],
  rating: Number,
  reviews: [{
    userId: ObjectId,
    rating: Number,
    comment: String,
    date: Date
  }],
  facilities: [String],
  timings: Object,
  emergency: Boolean,
  images: [String],
  createdAt: Date,
  updatedAt: Date
}
```

#### **Chat Sessions Collection** (for AI Symptom Checker)
```javascript
{
  _id: ObjectId,
  sessionId: String,
  userId: ObjectId,
  messages: [{
    role: ["user", "assistant"],
    content: String,
    timestamp: Date
  }],
  symptoms: [String],
  assessment: Object,
  recommendedActions: [String],
  createdAt: Date,
  updatedAt: Date
}
```

### **4. API Endpoints Structure**

#### **Authentication Routes** (`/api/auth`)
```
POST /register           # User registration
POST /login             # Email/password login
POST /google-login      # Google Sign-In
POST /logout            # User logout
GET  /profile           # Get user profile
PUT  /profile           # Update user profile
POST /upload-avatar     # Upload profile image
POST /forgot-password   # Password reset
POST /verify-otp        # OTP verification
```

#### **Appointment Routes** (`/api/appointments`)
```
GET    /                # Get user appointments
POST   /                # Book new appointment
GET    /:id             # Get specific appointment
PUT    /:id             # Update appointment
DELETE /:id             # Cancel appointment
GET    /doctors         # Get available doctors
POST   /payment         # Process appointment payment
```

#### **Pharmacy Routes** (`/api/pharmacy`)
```
GET    /medicines       # Search medicines
GET    /medicines/:id   # Get medicine details
POST   /cart/add        # Add to cart
GET    /cart            # Get cart items
PUT    /cart/:id        # Update cart item
DELETE /cart/:id        # Remove from cart
POST   /orders          # Place order
GET    /orders          # Get order history
GET    /orders/:id      # Get order details
PUT    /orders/:id      # Update order status
```

#### **Medical Records Routes** (`/api/records`)
```
GET    /                # Get patient records
POST   /                # Create new record
GET    /:id             # Get specific record
PUT    /:id             # Update record
DELETE /:id             # Delete record
POST   /upload          # Upload document
```

#### **Hospital Routes** (`/api/hospitals`)
```
GET    /                # Search hospitals
GET    /:id             # Get hospital details
GET    /nearby          # Get nearby hospitals
POST   /:id/review      # Add hospital review
```

#### **Video Call Routes** (`/api/video-calls`)
```
POST   /create-room     # Create video call room
GET    /room/:id        # Get room details
POST   /join            # Join video call
POST   /end             # End video call
```

### **5. Environment Configuration**

```env
# Server Configuration
NODE_ENV=development
PORT=3000
CLIENT_URL=http://localhost:3000

# Database
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/nabha_healthcare

# JWT Secret
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRE=7d

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Razorpay Payment
RAZORPAY_KEY_ID=rzp_test_5KDLZcQOeZLk8K
RAZORPAY_KEY_SECRET=iup6OxBjjs22NfyIV2vN4x8p

# File Storage (Cloudinary)
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# Email (for notifications)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Gemini AI (for symptom checker)
GEMINI_API_KEY=your-gemini-api-key
```

### **6. Flutter Integration Changes Needed**

#### **HTTP Client Setup**
```dart
// Create API service base class
class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  Future<Map<String, dynamic>> get(String endpoint);
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data);
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data);
  Future<bool> delete(String endpoint);
}
```

#### **Update State Management**
```dart
// Replace local storage with API calls
class UserRepository {
  Future<User> login(String email, String password);
  Future<User> googleSignIn();
  Future<void> updateProfile(User user);
}

class PharmacyRepository {
  Future<List<Medicine>> searchMedicines(String query);
  Future<PharmacyOrder> placeOrder(PharmacyOrder order);
  Future<List<PharmacyOrder>> getOrderHistory();
}
```

### **7. Database Setup Options**

#### **Option A: MongoDB Atlas (Recommended)**
- ✅ Cloud-hosted, managed service
- ✅ Free tier available (512MB)
- ✅ Automatic backups and scaling
- ✅ Built-in security features
- 🔗 Setup: [MongoDB Atlas](https://www.mongodb.com/atlas)

#### **Option B: Local MongoDB**
- ✅ Full control over database
- ✅ No internet dependency
- ❌ Manual backups and maintenance
- ❌ Limited scalability

### **8. Development Phases**

#### **Phase 1: Core Setup**
1. Set up Express.js server with MongoDB connection
2. Implement user authentication (JWT + Google OAuth)
3. Create basic CRUD operations for users
4. Test with Flutter app login

#### **Phase 2: Healthcare Features**
1. Implement appointment booking system
2. Add pharmacy order management
3. Create medical records storage
4. Integrate payment processing

#### **Phase 3: Advanced Features**
1. Add real-time chat/video call support
2. Implement search and filtering
3. Add notification system
4. Performance optimization

#### **Phase 4: Production Ready**
1. Add comprehensive error handling
2. Implement rate limiting and security
3. Set up monitoring and logging
4. Deploy to cloud platform

### **9. Estimated Timeline**

- **Backend Setup**: 2-3 days
- **Core APIs**: 1 week
- **Healthcare Features**: 2 weeks
- **Flutter Integration**: 1 week
- **Testing & Deployment**: 3-4 days

### **10. Next Steps**

1. **Choose MongoDB hosting** (Atlas recommended)
2. **Set up project structure** with Express.js
3. **Create database schemas** using Mongoose
4. **Implement authentication** with JWT
5. **Start with user management APIs**
6. **Gradually migrate Flutter features** to use backend

Would you like me to start implementing any specific part of this backend setup?