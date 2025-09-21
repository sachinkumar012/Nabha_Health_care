# Nabha Healthcare 🏥

A modern, multilingual healthcare platform designed specifically for rural and underserved communities. Built with React.js, this comprehensive healthcare solution provides easy access to medical services through video consultations, appointment booking, health records management, and AI-powered health assistance.

## 🌟 Features

### 🎯 Core Healthcare Services
- **Video Consultations**: Real-time video calls with qualified doctors using WebRTC technology
- **Multi-type Consultations**: Video calls, audio calls, and text-based consultations
- **Doctor Directory**: Browse and connect with specialized healthcare professionals
- **Health Records Management**: Secure digital health record storage and management
- **Symptom Checker**: AI-powered preliminary health assessment tool
- **Pharmacy Integration**: Connect with local pharmacies for prescription fulfillment

### 🤖 AI-Powered Features
- **Smart Chatbot**: AI appointment booking assistant with voice support
- **Symptom Analysis**: Intelligent symptom checker with medical guidance
- **Multilingual Support**: Full support for English, Hindi, and Punjabi languages

### 📱 Modern User Experience
- **Responsive Design**: Optimized for desktop, tablet, and mobile devices
- **Accessibility**: Screen reader support and keyboard navigation
- **Professional UI**: Healthcare-focused design with medical iconography
- **Real-time Updates**: Live availability status and instant notifications

## 🚀 Tech Stack

### Frontend
- **React.js 18** - Modern JavaScript framework
- **Vite** - Fast build tool and development server
- **Tailwind CSS** - Utility-first CSS framework
- **Framer Motion** - Smooth animations and transitions
- **Lucide React** - Beautiful icon library with medical icons

### Integration & APIs
- **Google Gemini AI** - Advanced AI for chatbot and symptom analysis
- **WebRTC** - Real-time video communication
- **WhatsApp Business API** - Direct messaging integration

### Development Tools
- **ESLint** - Code linting and quality assurance
- **PostCSS** - CSS processing and optimization
- **Git** - Version control system

## 📦 Installation

### Prerequisites
- Node.js 16.0 or higher
- npm or yarn package manager
- Git

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/nabha-healthcare.git
   cd nabha-healthcare
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

## 🏗️ Project Structure

```
nabha-healthcare/
├── public/                     # Static assets
│   ├── prescription_sample.pdf
│   └── vite.svg
├── src/                        # Source code
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
1. **Browse Doctors**: View available healthcare professionals
2. **Select Consultation Type**: Choose video, audio, or text consultation
3. **Book Appointment**: Select date, time, and provide patient information
4. **Join Video Call**: High-quality WebRTC video communication
5. **Integrated Chat**: Text messaging during video calls

### Health Records
- **Secure Storage**: Encrypted health data storage
- **Easy Access**: Quick retrieval of medical history
- **Multi-format Support**: PDF prescriptions and medical reports
- **Sharing Options**: Secure sharing with healthcare providers

### AI Chatbot
- **Natural Language**: Conversational appointment booking
- **Voice Support**: Speech-to-text and text-to-speech
- **Smart Scheduling**: Automatic availability checking
- **Multi-step Booking**: Guided appointment process

## 🛠️ Development

### Available Scripts

```bash
# Development
npm run dev          # Start development server
npm run build        # Build for production
npm run preview      # Preview production build

# Code Quality
npm run lint         # Run ESLint
npm run lint:fix     # Fix ESLint issues automatically

# Testing (if implemented)
npm run test         # Run test suite
npm run test:watch   # Run tests in watch mode
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

- **Version**: 1.0.0
- **Status**: Active Development
- **Last Updated**: September 2025
- **Next Release**: Q4 2025

### Recent Updates
- ✅ **Video Consultation System**: Complete WebRTC integration
- ✅ **AI Chatbot**: Google Gemini AI integration
- ✅ **Multilingual Support**: English, Hindi, and Punjabi
- ✅ **Responsive Design**: Mobile-first approach
- 🔄 **In Progress**: Backend API integration
- 📋 **Planned**: Mobile app development

---

**Made with ❤️ for accessible healthcare**

*Empowering rural communities with modern healthcare technology*
