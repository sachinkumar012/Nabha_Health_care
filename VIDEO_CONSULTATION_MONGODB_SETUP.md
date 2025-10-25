# Video Consultation MongoDB Integration

## Setup Instructions

### 1. Update your server/index.js to include video consultation routes:

```javascript
const express = require('express');
const cors = require('cors');
const { MongoClient } = require('mongodb');
const videoConsultationRoutes = require('./routes/videoConsultation');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// MongoDB Connection
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/nabha_healthcare';
let db;

MongoClient.connect(MONGO_URI, { useUnifiedTopology: true })
  .then(client => {
    console.log('Connected to MongoDB');
    db = client.db();
    
    // Initialize video consultation routes with DB
    videoConsultationRoutes.initDB(db);
    
    // Use routes
    app.use('/api/video-consultations', videoConsultationRoutes.router);
    
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch(error => console.error('MongoDB connection error:', error));
```

### 2. Insert Sample Doctors into MongoDB

Run this in MongoDB shell or use a tool like MongoDB Compass:

```javascript
db.doctors.insertMany([
  {
    name: "Dr. Rajesh Kumar",
    specialty: "Cardiologist",
    qualification: "MBBS, MD (Cardiology)",
    image: "https://randomuser.me/api/portraits/men/1.jpg",
    experience: 15,
    rating: 4.8,
    totalConsultations: 1250,
    consultationFee: 800,
    languages: ["English", "Hindi", "Punjabi"],
    about: "Experienced cardiologist specializing in heart diseases and interventional cardiology.",
    isAvailable: true,
    availableSlots: []
  },
  {
    name: "Dr. Priya Sharma",
    specialty: "General Physician",
    qualification: "MBBS, MD",
    image: "https://randomuser.me/api/portraits/women/2.jpg",
    experience: 12,
    rating: 4.9,
    totalConsultations: 1800,
    consultationFee: 600,
    languages: ["English", "Hindi"],
    about: "General physician with expertise in preventive medicine and chronic disease management.",
    isAvailable: true,
    availableSlots: []
  },
  {
    name: "Dr. Amit Verma",
    specialty: "Dermatologist",
    qualification: "MBBS, MD (Dermatology)",
    image: "https://randomuser.me/api/portraits/men/3.jpg",
    experience: 10,
    rating: 4.7,
    totalConsultations: 950,
    consultationFee: 700,
    languages: ["English", "Hindi"],
    about: "Specializes in skin disorders, cosmetic dermatology, and laser treatments.",
    isAvailable: true,
    availableSlots: []
  },
  {
    name: "Dr. Sunita Reddy",
    specialty: "Pediatrician",
    qualification: "MBBS, MD (Pediatrics)",
    image: "https://randomuser.me/api/portraits/women/4.jpg",
    experience: 14,
    rating: 4.9,
    totalConsultations: 2100,
    consultationFee: 650,
    languages: ["English", "Hindi", "Telugu"],
    about: "Child health specialist with focus on vaccination, growth monitoring, and pediatric care.",
    isAvailable: true,
    availableSlots: []
  },
  {
    name: "Dr. Vikram Singh",
    specialty: "Orthopedic",
    qualification: "MBBS, MS (Orthopedics)",
    image: "https://randomuser.me/api/portraits/men/5.jpg",
    experience: 18,
    rating: 4.8,
    totalConsultations: 1400,
    consultationFee: 900,
    languages: ["English", "Hindi"],
    about: "Orthopedic surgeon specializing in joint replacement, sports injuries, and trauma care.",
    isAvailable: true,
    availableSlots: []
  }
]);
```

### 3. Update Flutter App API Config

In your Flutter app, update the `api_config.dart` file with your backend URL:

```dart
class ApiConfig {
  // Change this to your actual backend URL
  static const String baseUrl = 'http://YOUR_IP:5000'; // e.g., http://192.168.1.100:5000
  
  // Rest of the code...
}
```

### 4. MongoDB Collections

The integration uses these collections:

- `doctors` - Stores doctor profiles
- `video_consultations` - Stores booking data

### 5. Test the Integration

1. Start your MongoDB server
2. Start your Node.js backend: `node server/index.js`
3. Run your Flutter app
4. Try booking a consultation
5. Check "My Bookings" to see your scheduled consultations

### API Endpoints

- `GET /api/video-consultations/doctors?specialty=Cardiologist` - Get doctors
- `POST /api/video-consultations/book` - Book consultation
- `GET /api/video-consultations/my-consultations?userId=xxx&status=scheduled` - Get user's consultations
- `POST /api/video-consultations/cancel/:id` - Cancel consultation
- `POST /api/video-consultations/reschedule/:id` - Reschedule consultation
- `POST /api/video-consultations/join/:id` - Join video call

### Request/Response Examples

#### Book Consultation
```json
POST /api/video-consultations/book
{
  "userId": "user_123",
  "doctorId": "doctor_id_from_mongodb",
  "scheduledTime": "2025-10-26T10:00:00.000Z",
  "symptoms": "Chest pain",
  "notes": "Experiencing discomfort"
}
```

#### Get My Consultations
```json
GET /api/video-consultations/my-consultations?userId=user_123&status=scheduled
```

Response:
```json
{
  "success": true,
  "consultations": [
    {
      "id": "consultation_id",
      "doctorName": "Dr. Rajesh Kumar",
      "doctorSpecialty": "Cardiologist",
      "scheduledTime": "2025-10-26T10:00:00.000Z",
      "status": "scheduled",
      "symptoms": "Chest pain"
    }
  ]
}
```

## Important Notes

1. Set `demoMode = false` in `video_consultation_service.dart` to use real backend
2. Make sure your backend server is running
3. Update the `baseUrl` in `api_config.dart` with your actual server IP/URL
4. Ensure MongoDB is running and accessible
5. The service will now save bookings to MongoDB and fetch real data
