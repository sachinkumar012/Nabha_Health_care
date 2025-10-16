# Nabha Healthcare - Flutter Mobile App

A comprehensive healthcare mobile application built with Flutter, providing essential healthcare services for rural communities.

## 🏥 Features

### 🎯 Core Features
- **Splash Screen** - Animated app introduction
- **Onboarding** - User-friendly introduction to app features
- **Authentication** - Secure login and registration
- **Home Dashboard** - Quick access to all services

### 💊 Healthcare Services
- **Video Consultation** - Remote doctor consultations
- **Appointment Booking** - Schedule medical appointments
- **Pharmacy Services** - Online medicine ordering
- **Health Records** - Secure medical history management
- **Symptom Checker** - AI-powered symptom analysis
- **Hospital Directory** - Find nearby healthcare facilities

### 🎨 UI/UX Features
- **Modern Design** - Clean and intuitive interface
- **Responsive Layout** - Optimized for all screen sizes
- **Dark/Light Theme** - Adaptive theme support
- **Smooth Animations** - Enhanced user experience
- **Accessibility** - Screen reader and accessibility support

## 🛠 Tech Stack

### Framework & Language
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language

### State Management
- **Riverpod** - Modern state management solution
- **Provider** - Alternative state management

### UI & Design
- **Material Design 3** - Modern design system
- **Google Fonts** - Typography
- **Lottie** - Animations
- **Flutter SVG** - Vector graphics

### Backend & Storage
- **HTTP/Dio** - API communication
- **Hive** - Local database
- **Shared Preferences** - Simple key-value storage

### Media & Communication
- **Agora RTC** - Video calling functionality
- **Image Picker** - Camera and gallery access
- **File Picker** - Document selection

### Location & Maps
- **Geolocator** - Location services
- **Google Maps** - Map integration

### Security & Authentication
- **Local Auth** - Biometric authentication
- **Crypto** - Encryption utilities

## 📱 Screenshots

[Screenshots will be added here]

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Android SDK or Xcode (for iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/sachinkumar012/Nabha_Health_care.git
   cd Nabha_Health_care/flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Release

**Android APK:**
```bash
flutter build apk --release
```

**iOS IPA:**
```bash
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── src/
│   ├── core/                # Core utilities
│   │   ├── constants/       # App constants
│   │   ├── theme/          # App themes
│   │   └── routes/         # Navigation routes
│   └── features/           # Feature modules
│       ├── splash/         # Splash screen
│       ├── onboarding/     # App introduction
│       ├── auth/           # Authentication
│       ├── home/           # Home dashboard
│       ├── appointments/   # Appointment booking
│       ├── pharmacy/       # Pharmacy services
│       ├── symptom_checker/ # Symptom analysis
│       ├── hospitals/      # Hospital directory
│       ├── health_records/ # Medical records
│       ├── video_call/     # Video consultation
│       └── profile/        # User profile
```

## 🎨 Design System

### Colors
- **Primary**: Green (#22C55E) - Healthcare/healing
- **Secondary**: Blue (#3B82F6) - Trust/reliability
- **Accent**: Purple (#8B5CF6) - Innovation
- **Success**: Green (#10B981)
- **Warning**: Orange (#F59E0B)
- **Error**: Red (#EF4444)

### Typography
- **Font Family**: Poppins
- **Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)

### Spacing
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **Extra Large**: 32px

## 🔧 Configuration

### Environment Setup
1. Configure API endpoints in `lib/src/core/constants/app_constants.dart`
2. Set up Firebase (if using)
3. Configure Agora credentials for video calling
4. Set up Google Maps API key

### API Integration
The app is designed to work with a REST API. Update the base URL and endpoints in the constants file.

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📦 Dependencies

### Main Dependencies
- `flutter_riverpod: ^2.4.7` - State management
- `google_fonts: ^6.1.0` - Typography
- `http: ^1.1.0` - HTTP requests
- `hive_flutter: ^1.1.0` - Local storage
- `agora_rtc_engine: ^6.3.0` - Video calling
- `geolocator: ^10.1.0` - Location services
- `image_picker: ^1.0.4` - Media access

### Dev Dependencies
- `flutter_lints: ^3.0.0` - Linting rules
- `build_runner: ^2.4.7` - Code generation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

- **Developer**: Sachin Kumar
- **Organization**: Nabha Healthcare

## 🆘 Support

For support and questions:
- Email: contact@nabhahealthcare.com
- GitHub Issues: [Create an issue](https://github.com/sachinkumar012/Nabha_Health_care/issues)

## 🔮 Roadmap

- [ ] AI-powered diagnosis
- [ ] Telemedicine integration
- [ ] Wearable device support
- [ ] Multi-language support
- [ ] Offline mode capabilities
- [ ] Advanced health analytics

---

Made with ❤️ for rural healthcare accessibility