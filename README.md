# Nabha Healthcare 🏥

A modern, multilingual healthcare platform designed specifically for rural and underserved communities. Built with React.js (web) and Flutter (mobile), this comprehensive healthcare solution provides easy access to medical services through video consultations, appointment booking, health records management, AI-powered health assistance, and ABHA (Ayushman Bharat Health Account) integration.

## 🌟 Features

### 🎯 Core Healthcare Services
- **Video Consultations**: Real-time video calls with qualified doctors with MongoDB backend integration
- **Consultation Booking**: Book, reschedule, and cancel video consultations with doctors
- **Doctor Directory**: Browse 5+ specialized healthcare professionals with ratings and specialties
- **Health Records Management**: Secure digital health record storage and management
- **ABHA Integration**: Create and link Ayushman Bharat Health Account for unified health records
- **Symptom Checker**: AI-powered preliminary health assessment tool
- **Pharmacy Integration**: Connect with local pharmacies for prescription fulfillment with order tracking
- **Phone Authentication**: Secure OTP-based phone login system

### 🤖 AI-Powered Features
- **Smart Chatbot**: AI appointment booking assistant with voice support
- **Symptom Analysis**: Intelligent symptom checker with medical guidance
- **Multilingual Support**: Full support for English, Hindi, and Punjabi languages

### 📱 Cross-Platform Support
- **Web Application**: React.js-based responsive web platform
- **Mobile Application**: Flutter-based native Android/iOS app (NabhaMobile)
- **Responsive Design**: Optimized for desktop, tablet, and mobile devices
- **Demo Mode**: Test features without backend dependency
- **Accessibility**: Screen reader support and keyboard navigation

## 🚀 Tech Stack

### Frontend (Web)
- **React.js 18** - Modern JavaScript framework
- **Vite** - Fast build tool and development server
- **Tailwind CSS** - Utility-first CSS framework
- **Framer Motion** - Smooth animations and transitions
- **Lucide React** - Beautiful icon library with medical icons

### Mobile App (Flutter)
- **Flutter 3.x** - Cross-platform mobile framework
- **Dart** - Programming language for Flutter
- **Riverpod 2.6.1** - State management solution
- **SharedPreferences** - Local data persistence
- **Firebase Auth** - Authentication (with custom phone auth)
- **HTTP Package** - API communication

### Backend
- **Node.js & Express** - Backend server framework
- **MongoDB** - NoSQL database for healthcare data
- **Mongoose** - MongoDB object modeling
- **JWT Authentication** - Secure token-based auth
- **RESTful APIs** - Video consultation, pharmacy, ABHA endpoints

### Integration & APIs
- **Google Gemini AI** - Advanced AI for chatbot and symptom analysis
- **WebRTC** - Real-time video communication
- **WhatsApp Business API** - Direct messaging integration
- **ABHA API** - Ayushman Bharat Health Account integration
- **Cloudinary** - Image and file storage

### Development Tools
- **ESLint** - Code linting and quality assurance
- **PostCSS** - CSS processing and optimization
- **Git** - Version control system

## 📦 Installation

### Prerequisites
- Node.js 16.0 or higher
- npm or yarn package manager
- Git
- MongoDB (for backend)
- Flutter SDK 3.x (for mobile app development)

### Web Application Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/sachinkumar012/Nabha_Health_care.git
   cd Nabha_Health_care
   ```

2. **Install dependencies**
   ```bash
   npm install
   # or
   yarn install
   ```

3. **Environment Setup**
   Create a `.env` file in the root directory:
   ```env
   VITE_GEMINI_API_KEY=your_google_gemini_api_key_here
   VITE_APP_TITLE=Nabha Healthcare
   VITE_WEBRTC_ICE_SERVERS=your_webrtc_ice_servers
   ```

4. **Start the development server**
   ```bash
   npm run dev
   # or
   yarn dev
   ```

5. **Open your browser**
   Navigate to `http://localhost:5173` (or the port shown in terminal)

### Mobile App Setup (Flutter)

1. **Navigate to Flutter app directory**
   ```bash
   cd flutter_app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoints**
   Update `lib/src/core/config/api_config.dart` with your backend URL

4. **Run the app**
   ```bash
   # For Android
   flutter run
   
   # For iOS
   flutter run -d ios
   
   # For specific device
   flutter devices
   flutter run -d <device-id>
   ```

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend-api
   ```

2. **Install backend dependencies**
   ```bash
   npm install
   ```

3. **Configure MongoDB**
   Create `.env` file in backend-api directory:
   ```env
   MONGODB_URI=mongodb://localhost:27017/nabha_healthcare
   JWT_SECRET=your_jwt_secret_here
   PORT=5000
   ```

4. **Start backend server**
   ```bash
   npm start
   # or
   node server.js
   ```

5. **Seed database (optional)**
   ```bash
   node scripts/seedData.js
   ```

## 🏗️ Project Structure

```
Nabha_Health_care/
├── public/                     # Static assets (web)
│   ├── prescription_sample.pdf
│   └── vite.svg
├── src/                        # Web app source code
│   ├── assets/                 # Images and static files
│   ├── components/             # Reusable React components
│   │   ├── Layout/            # Header, Footer components
│   │   ├── UI/                # Common UI components
│   │   └── VideoCall/         # Video consultation components
│   ├── context/               # React Context providers
│   │   ├── HealthContext.jsx  # Health data management
│   │   └── LanguageContext.jsx # Multilingual support
│   ├── pages/                 # Main application pages
│   │   ├── Home.jsx          # Landing page
│   │   ├── Doctors.jsx       # Doctor directory
│   │   ├── HealthRecords.jsx # Health records management
│   │   ├── Pharmacy.jsx      # Pharmacy services
│   │   └── About.jsx         # About page
│   ├── Login/                # Authentication components
│   ├── App.jsx               # Main application component
│   ├── main.jsx             # Application entry point
│   └── index.css           # Global styles
├── flutter_app/              # Flutter mobile application
│   ├── lib/
│   │   └── src/
│   │       ├── core/        # Core utilities and config
│   │       │   ├── config/  # API configuration
│   │       │   ├── routes/  # App routing
│   │       │   └── theme/   # App theming
│   │       ├── features/    # Feature modules
│   │       │   ├── auth/    # Authentication (Google, Phone OTP)
│   │       │   ├── home/    # Home screen
│   │       │   ├── profile/ # User profile management
│   │       │   ├── pharmacy/# Pharmacy orders
│   │       │   ├── abha/    # ABHA integration
│   │       │   └── video_consultation/ # Video consultation
│   │       │       ├── data/       # Data models
│   │       │       ├── presentation/ # UI screens
│   │       │       │   ├── pages/
│   │       │       │   │   ├── video_consultation_page.dart
│   │       │       │   │   ├── doctor_detail_page.dart
│   │       │       │   │   └── my_consultations_page.dart
│   │       │       │   └── widgets/
│   │       │       └── services/
│   │       │           └── video_consultation_service.dart
│   │       ├── services/   # Global services
│   │       └── shared/     # Shared widgets/providers
│   ├── android/           # Android native code
│   ├── ios/              # iOS native code
│   └── pubspec.yaml     # Flutter dependencies
├── backend-api/            # Node.js backend server
│   ├── src/
│   │   ├── config/        # Database & app config
│   │   ├── models/        # MongoDB models
│   │   │   ├── User.js
│   │   │   ├── Appointment.js
│   │   │   ├── Medicine.js
│   │   │   └── VideoConsultation.js
│   │   ├── routes/        # API routes
│   │   │   ├── auth.js
│   │   │   ├── appointments.js
│   │   │   ├── pharmacy.js
│   │   │   └── videoConsultation.js
│   │   └── middleware/   # Auth, upload, validation
│   ├── scripts/          # Database seed scripts
│   └── server.js        # Server entry point
├── NabhaMobile/          # Alternative Flutter app directory
├── server/               # Additional backend services
├── backend-setup/        # Backend deployment scripts
├── eslint.config.js     # ESLint configuration
├── postcss.config.js    # PostCSS configuration
├── tailwind.config.js   # Tailwind CSS configuration
├── vite.config.js      # Vite build configuration
└── package.json       # Project dependencies
```
│   │   └── LanguageContext.jsx # Multilingual support
│   ├── pages/                 # Main application pages
│   │   ├── Home.jsx          # Landing page
│   │   ├── Doctors.jsx       # Doctor directory
│   │   ├── HealthRecords.jsx # Health records management
│   │   ├── Pharmacy.jsx      # Pharmacy services
│   │   └── About.jsx         # About page
│   ├── Login/                # Authentication components
│   ├── App.jsx               # Main application component
│   ├── main.jsx             # Application entry point
│   └── index.css           # Global styles and CSS variables
├── eslint.config.js         # ESLint configuration
├── postcss.config.js        # PostCSS configuration
├── tailwind.config.js       # Tailwind CSS configuration
├── vite.config.js          # Vite build configuration
└── package.json           # Project dependencies and scripts
```

## 🎨 Design System

### Color Palette
- **Primary**: Emerald green (#059669) - Trust and health
- **Secondary**: Amber (#f59e0b) - Warmth and care
- **Accent**: Blue (#3b82f6) - Technology and reliability
- **Neutral**: Gray scale for text and backgrounds

### Typography
- **Font Family**: Inter - Clean, professional, and highly readable
- **Font Weights**: 300 (Light) to 800 (Extra Bold)
- **Responsive scaling**: Optimized for all screen sizes

## 🌍 Multilingual Support

The platform supports three languages:
- **English** - Primary language
- **Hindi** (हिंदी) - For Hindi-speaking users
- **Punjabi** (ਪੰਜਾਬੀ) - For Punjabi-speaking communities

### Adding New Languages
1. Update `src/context/LanguageContext.jsx`
2. Add translation keys for all text elements
3. Test across all components

## 🏥 Healthcare Features Guide

### Video Consultations
1. **Browse Doctors**: View 5+ available healthcare professionals with specialties and ratings
2. **Doctor Profiles**: See detailed information including experience, consultation fees, and availability
3. **Book Consultation**: Select date, time, and provide patient information
4. **My Consultations**: View all upcoming and completed consultations
5. **Reschedule/Cancel**: Easy rescheduling and cancellation with updated booking management
6. **Demo Mode**: Test features with mock data without backend dependency
7. **Backend Integration**: MongoDB storage for persistent consultation records

### ABHA (Ayushman Bharat Health Account) Integration
- **Create ABHA**: Generate new ABHA health accounts
- **Link ABHA**: Connect existing ABHA accounts to the platform
- **Health Records**: Access unified health records through ABHA
- **Secure Storage**: Encrypted health data with ABHA compliance

### Pharmacy Orders
- **Browse Medicines**: Search and filter pharmaceutical products
- **Order Tracking**: Real-time order status updates with persistent storage
- **Prescription Upload**: Submit prescriptions for verification
- **Order History**: View past orders and reorder easily

### Health Records
- **Secure Storage**: Encrypted health data storage
- **Easy Access**: Quick retrieval of medical history
- **Multi-format Support**: PDF prescriptions and medical reports
- **Sharing Options**: Secure sharing with healthcare providers

### Phone Authentication
- **OTP Login**: Secure phone number verification
- **Profile Completion**: Complete user profile after first login
- **Multi-platform**: Works on both web and mobile apps

### AI Chatbot
- **Natural Language**: Conversational appointment booking
- **Voice Support**: Speech-to-text and text-to-speech
- **Smart Scheduling**: Automatic availability checking
- **Multi-step Booking**: Guided appointment process

## 🛠️ Development

### Available Scripts

#### Web Application
```bash
# Development
npm run dev          # Start development server
npm run build        # Build for production
npm run preview      # Preview production build

# Code Quality
npm run lint         # Run ESLint
npm run lint:fix     # Fix ESLint issues automatically
```

#### Flutter Mobile App
```bash
# Development
flutter run          # Run app in debug mode
flutter run --release # Run app in release mode
flutter build apk    # Build Android APK
flutter build ios    # Build iOS app
flutter build appbundle # Build Android App Bundle

# Testing
flutter test         # Run unit tests
flutter analyze      # Analyze code for issues

# Maintenance
flutter clean        # Clean build artifacts
flutter pub get      # Update dependencies
flutter pub upgrade  # Upgrade dependencies
```

#### Backend Server
```bash
# Development
npm start            # Start backend server
node server.js       # Alternative start command
npm run seed         # Seed database with sample data

# Testing (if implemented)
npm run test         # Run test suite
```

### Development Guidelines

1. **Component Structure**
   - Use functional components with hooks
   - Keep components small and focused
   - Use proper prop validation

2. **Styling**
   - Prefer Tailwind utility classes
   - Use CSS variables for theming
   - Maintain responsive design principles

3. **State Management**
   - Use React Context for global state
   - Keep local state minimal
   - Use proper cleanup for effects

## 🚀 Deployment

### Production Build
```bash
npm run build
```

### Deployment Options
- **Vercel**: Recommended for React applications
- **Netlify**: Great for static site hosting
- **AWS S3 + CloudFront**: Scalable cloud solution
- **GitHub Pages**: Free hosting for open source projects

### Environment Variables for Production
```env
VITE_GEMINI_API_KEY=production_gemini_api_key
VITE_APP_TITLE=Nabha Healthcare
VITE_API_URL=https://api.yourdomain.com
```

## 🔒 Security & Privacy

- **Data Encryption**: All health data encrypted in transit and at rest
- **HIPAA Compliance**: Designed with healthcare privacy regulations in mind
- **Secure Authentication**: Token-based authentication system
- **WebRTC Security**: Peer-to-peer encrypted video communications

## 🤝 Contributing

We welcome contributions to make healthcare more accessible! Please read our contributing guidelines:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Contribution Areas
- 🌐 **Translations**: Add support for more languages
- 🎨 **UI/UX**: Improve user interface and experience
- 🚀 **Features**: Add new healthcare functionalities
- 🐛 **Bug Fixes**: Report and fix issues
- 📖 **Documentation**: Improve documentation and guides

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support & Contact

### Getting Help
- **Documentation**: Check this README and inline code comments
- **Issues**: Create a GitHub issue for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas

### Healthcare Partnership
For healthcare providers interested in using or customizing this platform:
- **Email**: healthcare@nabha.com
- **Phone**: +91-XXXX-XXXXXX
- **Website**: https://nabha-healthcare.com

## 🙏 Acknowledgments

- **Healthcare Professionals**: For guidance on medical workflows
- **Open Source Community**: For the amazing tools and libraries
- **Rural Communities**: For inspiring this accessible healthcare solution
- **Contributors**: Everyone who helps improve this platform

## 📊 Project Status

- **Version**: 2.0.0
- **Status**: Active Development
- **Last Updated**: October 2025
- **Next Release**: Q1 2026

### Recent Updates
- ✅ **Flutter Mobile App**: Native Android/iOS application (NabhaMobile)
- ✅ **Video Consultation System**: Complete with MongoDB backend integration
- ✅ **Consultation Booking**: Book, reschedule, and cancel consultations
- ✅ **Demo Mode**: Test features without backend dependency
- ✅ **ABHA Integration**: Create and link Ayushman Bharat Health Accounts
- ✅ **Phone OTP Authentication**: Secure phone-based login system
- ✅ **Profile Management**: Complete user profile with Cloudinary image upload
- ✅ **Pharmacy Order Tracking**: Persistent order storage with SharedPreferences
- ✅ **AI Chatbot**: Google Gemini AI integration
- ✅ **Multilingual Support**: English, Hindi, and Punjabi
- ✅ **Responsive Design**: Mobile-first approach
- ✅ **Backend APIs**: RESTful APIs for video consultation, pharmacy, and ABHA
- 🔄 **In Progress**: Real-time video call integration with Agora SDK
- 📋 **Planned**: Push notifications, payment gateway integration

### Documentation
- 📖 [Video Consultation Setup Guide](VIDEO_CONSULTATION_GUIDE.md)
- 📖 [Video Consultation MongoDB Setup](VIDEO_CONSULTATION_MONGODB_SETUP.md)
- 📖 [Demo Mode Instructions](DEMO_MODE_INSTRUCTIONS.md)
- 📖 [Phone OTP Setup Guide](PHONE_OTP_SETUP_GUIDE.md)
- 📖 [ABHA Integration Guide](ABHA_INTEGRATION_GUIDE.md)
- 📖 [Order Persistence Fix](ORDER_PERSISTENCE_FIX.md)
- 📖 [Network Setup Guide](NETWORK_SETUP.md)
- 📖 [Deployment Guide](DEPLOYMENT_GUIDE.md)

---

**Made with ❤️ for accessible healthcare**

*Empowering rural communities with modern healthcare technology*
