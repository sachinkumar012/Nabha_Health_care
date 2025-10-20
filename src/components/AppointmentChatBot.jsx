import React, { useState, useRef, useEffect } from "react";
import { Mic, MicOff, Send, Volume2, VolumeX, Calendar, X, MessageCircle } from "lucide-react";

const API_KEY = "AIzaSyCAzGYeMcfLMCp1ghvQWBX2xdbLhbJS1Go"; // Updated with your new API key for appointment booking

// SMS API Configuration - Multiple Services Support
const SMS_CONFIG = {
  // Option 1: Fast2SMS (Indian service - Free tier available)
  FAST2SMS: {
    API_URL: 'https://www.fast2sms.com/dev/bulkV2',
    API_KEY: '0r1KFkTJiNeqUB4CDmEXQIAMhRV8OL7xlyd5wSsGp6Ybnfj3gPrtfEg1X9POeYDuznRxp7WdBIHy4obj', // Get from https://www.fast2sms.com/
    SENDER_ID: 'FSTSMS',
  },
  
  // Option 2: TextLocal (Free tier available)
  TEXTLOCAL: {
    API_URL: 'https://api.textlocal.in/send/',
    API_KEY: 'YOUR_TEXTLOCAL_API_KEY', // Get from https://www.textlocal.in/
    SENDER: 'NABHA',
  },
  
  // Option 3: MSG91 (Indian SMS service)
  MSG91: {
    API_URL: 'https://control.msg91.com/api/v5/flow/',
    API_KEY: 'YOUR_MSG91_API_KEY',
    TEMPLATE_ID: 'YOUR_TEMPLATE_ID',
    SENDER_ID: 'NABHA',
  },
  
  // Option 4: Twilio (International - Paid but reliable)
  TWILIO: {
    ACCOUNT_SID: 'YOUR_TWILIO_ACCOUNT_SID',
    AUTH_TOKEN: 'YOUR_TWILIO_AUTH_TOKEN',
    PHONE: 'YOUR_TWILIO_PHONE_NUMBER'
  },
  
  // Demo mode for testing
  DEMO_MODE: true // Set to false when you have real API keys
};

// Language configuration
const LANGUAGES = {
  en: {
    code: 'en',
    name: 'English',
    flag: '🇺🇸',
    speechLang: 'en-US',
    placeholder: 'Type your message...',
    initialMessage: 'Hello! I\'m here to help you book an appointment with our doctors. First, please select your preferred language for our conversation.',
    languageSelected: 'Great! Now, what type of consultation do you need?',
    listening: 'Listening...',
    selectLanguage: 'Please select your language:'
  },
  hi: {
    code: 'hi',
    name: 'हिंदी',
    flag: '🇮🇳',
    speechLang: 'hi-IN',
    placeholder: 'अपना संदेश लिखें...',
    initialMessage: 'नमस्ते! मैं आपको हमारे डॉक्टरों के साथ अपॉइंटमेंट बुक करने में मदद करने यहाँ हूँ। पहले, कृपया हमारी बातचीत के लिए अपनी पसंदीदा भाषा चुनें।',
    languageSelected: 'बहुत बढ़िया! अब आपको किस प्रकार की परामर्श की आवश्यकता है?',
    listening: 'सुन रहा हूँ...',
    selectLanguage: 'कृपया अपनी भाषा चुनें:'
  },
  pa: {
    code: 'pa',
    name: 'ਪੰਜਾਬੀ',
    flag: '🇮🇳',
    speechLang: 'pa-IN',
    placeholder: 'ਆਪਣਾ ਸੰਦੇਸ਼ ਲਿਖੋ...',
    initialMessage: 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ! ਮੈਂ ਤੁਹਾਨੂੰ ਸਾਡੇ ਡਾਕਟਰਾਂ ਨਾਲ ਮੁਲਾਕਾਤ ਦਾ ਸਮਾਂ ਬੁੱਕ ਕਰਨ ਵਿੱਚ ਮਦਦ ਕਰਨ ਲਈ ਇੱਥੇ ਹਾਂ। ਪਹਿਲਾਂ, ਕਿਰਪਾ ਕਰਕੇ ਸਾਡੀ ਗੱਲਬਾਤ ਲਈ ਆਪਣੀ ਪਸੰਦੀਦਾ ਭਾਸ਼ਾ ਚੁਣੋ।',
    languageSelected: 'ਬਹੁਤ ਵਧੀਆ! ਹੁਣ ਤੁਹਾਨੂੰ ਕਿਸ ਕਿਸਮ ਦੀ ਸਲਾਹ ਦੀ ਲੋੜ ਹੈ?',
    listening: 'ਸੁਣ ਰਿਹਾ ਹਾਂ...',
    selectLanguage: 'ਕਿਰਪਾ ਕਰਕੇ ਆਪਣੀ ਭਾਸ਼ਾ ਚੁਣੋ:'
  }
};

// Agentic AI Configuration
const DOCTORS_DATABASE = {
  'sachin-kumar': {
    id: 'sachin-kumar',
    name: 'Dr. Sachin Kumar',
    specialty: 'General Medicine',
    experience: 15,
    availability: { start: '09:00', end: '18:00' },
    rating: 4.8,
    languages: ['English', 'Hindi', 'Punjabi'],
    conditions: ['fever', 'cold', 'general checkup', 'diabetes', 'hypertension'],
    slots: ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00']
  },
  'tarun-thakur': {
    id: 'tarun-thakur',
    name: 'Dr. Tarun Thakur',
    specialty: 'Pediatrics',
    experience: 12,
    availability: { start: '06:00', end: '16:00' },
    rating: 4.9,
    languages: ['English', 'Hindi'],
    conditions: ['child fever', 'vaccination', 'growth issues', 'pediatric care'],
    slots: ['06:00', '07:00', '08:00', '09:00', '10:00', '14:00', '15:00']
  },
  'manish-sharma': {
    id: 'manish-sharma',
    name: 'Dr. Manish Sharma',
    specialty: 'Cardiology',
    experience: 18,
    availability: { start: '09:00', end: '17:00' },
    rating: 4.9,
    languages: ['English', 'Hindi'],
    conditions: ['heart problems', 'chest pain', 'blood pressure', 'cardiac checkup'],
    slots: ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00']
  },
  'fouziya-siddiqui': {
    id: 'fouziya-siddiqui',
    name: 'Dr. Fouziya Siddiqui',
    specialty: 'Gynecology',
    experience: 20,
    availability: { start: '11:00', end: '19:00' },
    rating: 4.8,
    languages: ['English', 'Hindi', 'Urdu'],
    conditions: ['womens health', 'pregnancy', 'gynecological issues'],
    slots: ['11:00', '12:00', '14:00', '15:00', '16:00', '17:00', '18:00']
  },
  'shashank': {
    id: 'shashank',
    name: 'Dr. Shashank',
    specialty: 'Orthopaedics',
    experience: 18,
    availability: { start: '09:00', end: '17:00' },
    rating: 4.7,
    languages: ['English', 'Hindi'],
    conditions: ['bone problems', 'joint pain', 'fracture', 'back pain', 'sports injury'],
    slots: ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00']
  },
  'kamaljeet-kaur': {
    id: 'kamaljeet-kaur',
    name: 'Dr. Kamaljeet Kaur',
    specialty: 'Dermatology',
    experience: 18,
    availability: { start: '09:00', end: '17:00' },
    rating: 4.8,
    languages: ['English', 'Hindi', 'Punjabi'],
    conditions: ['skin problems', 'acne', 'rash', 'hair loss', 'dermatological issues'],
    slots: ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00']
  }
};

const CONVERSATION_STATES = {
  LANGUAGE_SELECTION: 'language_selection',
  INITIAL_INQUIRY: 'initial_inquiry',
  SYMPTOM_ASSESSMENT: 'symptom_assessment',
  DOCTOR_RECOMMENDATION: 'doctor_recommendation',
  SLOT_SELECTION: 'slot_selection',
  PATIENT_DETAILS: 'patient_details',
  CONFIRMATION: 'confirmation',
  COMPLETED: 'completed'
};

const AGENT_ACTIONS = {
  RECOMMEND_DOCTOR: 'recommend_doctor',
  SUGGEST_SLOTS: 'suggest_slots',
  REQUEST_DETAILS: 'request_details',
  CONFIRM_BOOKING: 'confirm_booking',
  PROVIDE_ALTERNATIVES: 'provide_alternatives'
};

const 
AppointmentChatBot = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [currentLanguage, setCurrentLanguage] = useState('en');
  const [languageSelected, setLanguageSelected] = useState(false);
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [isListening, setIsListening] = useState(false);
  const [speechEnabled, setSpeechEnabled] = useState(false);
  const [recognition, setRecognition] = useState(null);
  const [speechSupported, setSpeechSupported] = useState(false);
  const chatBoxRef = useRef(null);

  // Agentic AI State Management
  const [conversationState, setConversationState] = useState(CONVERSATION_STATES.LANGUAGE_SELECTION);
  const [patientData, setPatientData] = useState({
    symptoms: [],
    preferredDoctor: null,
    selectedSlot: null,
    name: '',
    phone: '',
    preferredDate: '',
    medicalHistory: []
  });
  const [recommendedDoctors, setRecommendedDoctors] = useState([]);
  const [conversationContext, setConversationContext] = useState({
    userIntents: [],
    extractedInfo: {},
    suggestedActions: []
  });

  useEffect(() => {
    // Initialize with welcome message when chat opens
    if (isOpen && messages.length === 0) {
      addMessage("Hello! Welcome to Nabha Healthcare! 🏥", 'bot');
      setTimeout(() => {
        addMessage("I'm your AI assistant here to help you book appointments with our doctors.", 'bot');
      }, 1000);
      setTimeout(() => {
        addMessage("First, please select your preferred language for our conversation:", 'bot');
        // Add language selection as a special message
        addLanguageOptionsMessage();
      }, 2000);
    }
  }, [isOpen, messages.length]);

  const addLanguageOptionsMessage = () => {
    setTimeout(() => {
      setMessages((prev) => [...prev, { 
        text: '', 
        type: 'bot', 
        timestamp: new Date(),
        isLanguageSelection: true 
      }]);
    }, 500);
  };

  useEffect(() => {
    // Check if browser supports speech recognition
    if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
      setSpeechSupported(true);
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
      const recognitionInstance = new SpeechRecognition();
      
      recognitionInstance.continuous = false;
      recognitionInstance.interimResults = false;
      recognitionInstance.lang = LANGUAGES[currentLanguage].speechLang;
      
      recognitionInstance.onresult = (event) => {
        const transcript = event.results[0][0].transcript;
        setInput(transcript);
        setIsListening(false);
      };
      
      recognitionInstance.onerror = (event) => {
        console.error('Speech recognition error:', event.error);
        setIsListening(false);
      };
      
      recognitionInstance.onend = () => {
        setIsListening(false);
      };
      
      setRecognition(recognitionInstance);
    }
  }, [currentLanguage]);

  const addMessage = (text, type) => {
    setMessages((prev) => [...prev, { text, type, timestamp: new Date() }]);
    setTimeout(() => {
      if (chatBoxRef.current) {
        chatBoxRef.current.scrollTop = chatBoxRef.current.scrollHeight;
      }
    }, 50);
  };

  const handleLanguageSelect = (langCode) => {
    setCurrentLanguage(langCode);
    setLanguageSelected(true);
    setConversationState(CONVERSATION_STATES.INITIAL_INQUIRY);
    
    // Add user selection message
    addMessage(`${LANGUAGES[langCode].flag} ${LANGUAGES[langCode].name}`, 'user');
    
    // Remove language selection message and add confirmation
    setMessages((prev) => prev.filter(msg => !msg.isLanguageSelection));
    
    setTimeout(() => {
      addMessage(`Great! I'll communicate with you in ${LANGUAGES[langCode].name}. 😊`, 'bot');
      setTimeout(() => {
        addMessage("Now, what brings you here today? You can tell me about your symptoms or the type of consultation you need.", 'bot');
        // Proactive agent suggestion
        setTimeout(() => {
          addAgenticSuggestion();
        }, 1500);
      }, 1000);
    }, 500);
    
    // Update speech recognition language
    if (recognition) {
      recognition.lang = LANGUAGES[langCode].speechLang;
    }
  };

  // Agentic AI Functions
  const analyzeUserIntent = (userMessage) => {
    const message = userMessage.toLowerCase();
    const intents = [];
    
    // Symptom detection
    const symptoms = ['headache', 'fever', 'cough', 'pain', 'cold', 'flu', 'stomach', 'chest', 'back', 'joint', 'skin', 'rash', 'dizzy', 'nausea'];
    const detectedSymptoms = symptoms.filter(symptom => message.includes(symptom));
    if (detectedSymptoms.length > 0) {
      intents.push({ type: 'SYMPTOM_REPORTED', data: detectedSymptoms });
    }

    // Doctor preference detection
    const doctorNames = Object.values(DOCTORS_DATABASE).map(doc => doc.name.toLowerCase());
    const mentionedDoctor = doctorNames.find(name => message.includes(name.split(' ')[1])); // Check last name
    if (mentionedDoctor) {
      intents.push({ type: 'DOCTOR_PREFERENCE', data: mentionedDoctor });
    }

    // Time preference detection
    const timePatterns = /(\d{1,2}):?(\d{2})?\s*(am|pm)?|morning|afternoon|evening|today|tomorrow/gi;
    if (timePatterns.test(message)) {
      intents.push({ type: 'TIME_PREFERENCE', data: message.match(timePatterns) });
    }

    // Urgency detection
    if (message.includes('urgent') || message.includes('emergency') || message.includes('asap')) {
      intents.push({ type: 'URGENT_REQUEST', data: true });
    }

    return intents;
  };

  const recommendDoctors = (symptoms, urgency = false) => {
    let recommendations = [];
    
    // Smart doctor matching based on symptoms
    Object.values(DOCTORS_DATABASE).forEach(doctor => {
      let score = 0;
      
      // Check if doctor handles reported symptoms
      symptoms.forEach(symptom => {
        if (doctor.conditions.some(condition => condition.includes(symptom))) {
          score += 3;
        }
      });
      
      // Bonus for experience and rating
      score += doctor.experience * 0.1;
      score += doctor.rating * 0.5;
      
      // Language preference bonus
      if (doctor.languages.includes(LANGUAGES[currentLanguage].name)) {
        score += 1;
      }

      if (score > 0) {
        recommendations.push({ ...doctor, matchScore: score });
      }
    });

    // Sort by match score and return top 3
    recommendations.sort((a, b) => b.matchScore - a.matchScore);
    return recommendations.slice(0, 3);
  };

  const generateAgenticResponse = (userMessage, intents) => {
    const context = conversationContext;
    let agenticActions = [];
    let response = '';

    // Determine next actions based on conversation state and intents
    switch (conversationState) {
      case CONVERSATION_STATES.INITIAL_INQUIRY:
        if (intents.some(i => i.type === 'SYMPTOM_REPORTED')) {
          setConversationState(CONVERSATION_STATES.SYMPTOM_ASSESSMENT);
          const symptoms = intents.find(i => i.type === 'SYMPTOM_REPORTED').data;
          const recommended = recommendDoctors(symptoms);
          setRecommendedDoctors(recommended);
          agenticActions.push(AGENT_ACTIONS.RECOMMEND_DOCTOR);
        }
        break;
        
      case CONVERSATION_STATES.SYMPTOM_ASSESSMENT:
        agenticActions.push(AGENT_ACTIONS.RECOMMEND_DOCTOR);
        setConversationState(CONVERSATION_STATES.DOCTOR_RECOMMENDATION);
        break;
        
      case CONVERSATION_STATES.DOCTOR_RECOMMENDATION:
        if (intents.some(i => i.type === 'DOCTOR_PREFERENCE' || i.type === 'TIME_PREFERENCE')) {
          agenticActions.push(AGENT_ACTIONS.SUGGEST_SLOTS);
          setConversationState(CONVERSATION_STATES.SLOT_SELECTION);
        }
        break;
        
      case CONVERSATION_STATES.SLOT_SELECTION:
        agenticActions.push(AGENT_ACTIONS.REQUEST_DETAILS);
        setConversationState(CONVERSATION_STATES.PATIENT_DETAILS);
        break;
        
      case CONVERSATION_STATES.PATIENT_DETAILS:
        agenticActions.push(AGENT_ACTIONS.CONFIRM_BOOKING);
        setConversationState(CONVERSATION_STATES.CONFIRMATION);
        break;
    }

    return { agenticActions, suggestedResponse: response };
  };

  const executeAgenticAction = async (action, context) => {
    switch (action) {
      case AGENT_ACTIONS.RECOMMEND_DOCTOR:
        if (recommendedDoctors.length > 0) {
          const doctorList = recommendedDoctors.map((doc, index) => 
            `${index + 1}. **${doc.name}** (${doc.specialty}) - ${doc.experience} years experience ⭐${doc.rating}`
          ).join('\n');
          
          setTimeout(() => {
            addMessage(`Based on your symptoms, I recommend these doctors:\n\n${doctorList}\n\nWhich doctor would you prefer to consult with?`, 'bot');
          }, 1000);
        }
        break;
        
      case AGENT_ACTIONS.SUGGEST_SLOTS:
        const doctor = recommendedDoctors[0]; // Assume first recommended
        if (doctor) {
          const slots = doctor.slots.slice(0, 5).join(', ');
          setTimeout(() => {
            addMessage(`Great choice! **${doctor.name}** has these available slots:\n\n⏰ ${slots}\n\nWhich time works best for you?`, 'bot');
          }, 1000);
        }
        break;
        
      case AGENT_ACTIONS.REQUEST_DETAILS:
        setTimeout(() => {
          addMessage(`Perfect! Now I need a few details to book your appointment:\n\n📋 **Please provide:**\n• Your full name\n• Phone number\n• Preferred date\n\nYou can share all details in one message.`, 'bot');
        }, 1000);
        break;
        
      case AGENT_ACTIONS.CONFIRM_BOOKING:
        // Extract appointment details from conversation
        const appointmentDetails = extractPatientDetails(messages.map(m => m.text));
        
        // Set default values if missing
        appointmentDetails.doctorName = appointmentDetails.doctorName || 'Dr. Sachin Kumar';
        appointmentDetails.appointmentTime = appointmentDetails.appointmentTime || '10:00 AM';
        appointmentDetails.appointmentDate = appointmentDetails.appointmentDate || 'Today';
        appointmentDetails.hospitalName = 'Nabha Healthcare';
        appointmentDetails.patientName = appointmentDetails.patientName || 'Patient';

        setTimeout(() => {
          addMessage(`🎉 **Appointment Confirmed!**\n\n📅 **Details:**\n• Doctor: ${appointmentDetails.doctorName}\n• Time: ${appointmentDetails.appointmentTime}\n• Date: ${appointmentDetails.appointmentDate}\n• Patient: ${appointmentDetails.patientName}\n\n📱 Sending confirmation SMS...`, 'bot');
          
          // Send SMS after showing confirmation
          if (appointmentDetails.phoneNumber) {
            sendAppointmentSMS(appointmentDetails);
          } else {
            // Request phone number if missing
            setTimeout(() => {
              addMessage(`📱 **Phone number needed for SMS confirmation**\n\nPlease share your mobile number to receive appointment details via SMS.`, 'bot');
            }, 2000);
          }
        }, 1000);
        break;
    }
  };

  const sendAppointmentSMS = async (appointmentDetails) => {
    try {
      // Show sending status
      setTimeout(() => {
        addMessage(`📤 Sending SMS confirmation to ${appointmentDetails.phoneNumber}...`, 'bot');
      }, 1500);

      // Send the SMS
      const smsResult = await sendSMSConfirmation(appointmentDetails.phoneNumber, appointmentDetails);
      
      setTimeout(() => {
        if (smsResult.success) {
          addMessage(`✅ **SMS Sent Successfully!**\n\n📱 Confirmation message sent to: ${appointmentDetails.phoneNumber}\n🆔 Message ID: ${smsResult.messageId}\n\n**What's Next:**\n• Check your phone for appointment details\n• Save our contact: +91-XXXXXXXXXX\n• Arrive 15 minutes early\n\n� **WhatsApp Support:** +91-XXXXXXXXXX\n\nThank you for choosing Nabha Healthcare! 🏥`, 'bot');
        } else {
          addMessage(`❌ **SMS Failed to Send**\n\nDon't worry! Here are your appointment details:\n\n📋 **Appointment Summary:**\n👤 Patient: ${appointmentDetails.patientName}\n👨‍⚕️ Doctor: ${appointmentDetails.doctorName}\n📅 Date: ${appointmentDetails.appointmentDate}\n🕐 Time: ${appointmentDetails.appointmentTime}\n🏥 Venue: Nabha Healthcare\n\n� **Contact Us:**\nPhone: +91-XXXXXXXXXX\nWhatsApp: +91-XXXXXXXXXX\n\nPlease save these details or take a screenshot!`, 'bot');
        }
      }, 3000);
      
    } catch (error) {
      setTimeout(() => {
        addMessage(`⚠️ **SMS Service Temporarily Unavailable**\n\nYour appointment is confirmed! Please note these details:\n\n📋 **Appointment Details:**\n👤 ${appointmentDetails.patientName}\n👨‍⚕️ ${appointmentDetails.doctorName}\n📅 ${appointmentDetails.appointmentDate}\n🕐 ${appointmentDetails.appointmentTime}\n\n📞 **Contact:** +91-XXXXXXXXXX for confirmation`, 'bot');
      }, 2000);
    }
  };

  const addAgenticSuggestion = () => {
    const suggestions = [
      "💡 I can help you with:\n• Book appointments with specialists\n• Check doctor availability\n• Get medical advice\n\nWhat brings you here today?",
      "🔍 Tell me your symptoms and I'll recommend the best doctor for you!",
      "⚡ Need urgent consultation? I can find the earliest available slot for you."
    ];
    
    const randomSuggestion = suggestions[Math.floor(Math.random() * suggestions.length)];
    setTimeout(() => {
      addMessage(randomSuggestion, 'bot');
    }, 500);
  };

  // SMS Functionality
  const sendSMSConfirmation = async (phoneNumber, appointmentDetails) => {
    try {
      // Clean and validate phone number
      const cleanedPhone = phoneNumber.replace(/\D/g, ''); // Remove non-digits
      
      if (cleanedPhone.length < 10) {
        throw new Error('Invalid phone number');
      }

      // Format phone number (assuming Indian numbers)
      const formattedPhone = cleanedPhone.startsWith('91') 
        ? cleanedPhone 
        : `91${cleanedPhone.slice(-10)}`;

      // Create SMS message
      const smsMessage = generateSMSMessage(appointmentDetails);
      
      // Try different SMS services in order of preference
      let smsResult;
      
      if (SMS_CONFIG.DEMO_MODE) {
        smsResult = await sendDemoSMS(formattedPhone, smsMessage, appointmentDetails);
      } else {
        // Try Fast2SMS first (free tier available)
        try {
          smsResult = await sendViaFast2SMS(formattedPhone, smsMessage, appointmentDetails);
        } catch (error) {
          console.log('Fast2SMS failed, trying TextLocal...');
          try {
            smsResult = await sendViaTextLocal(formattedPhone, smsMessage, appointmentDetails);
          } catch (error2) {
            console.log('TextLocal failed, trying MSG91...');
            smsResult = await sendViaMSG91(formattedPhone, smsMessage, appointmentDetails);
          }
        }
      }
      
      return {
        success: true,
        messageId: smsResult.messageId,
        phone: formattedPhone,
        provider: smsResult.provider
      };
      
    } catch (error) {
      console.error('SMS sending failed:', error);
      return {
        success: false,
        error: error.message
      };
    }
  };

  const sendViaFast2SMS = async (phoneNumber, message, appointmentDetails) => {
    const response = await fetch(SMS_CONFIG.FAST2SMS.API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'authorization': SMS_CONFIG.FAST2SMS.API_KEY
      },
      body: JSON.stringify({
        route: 'q',
        message: message,
        language: 'english',
        flash: 0,
        numbers: phoneNumber.replace('91', '') // Remove country code for Fast2SMS
      })
    });

    const result = await response.json();
    
    if (result.return && result.return === true) {
      return {
        success: true,
        messageId: result.request_id || 'FAST2SMS_' + Date.now(),
        provider: 'Fast2SMS'
      };
    } else {
      throw new Error(result.message || 'Fast2SMS sending failed');
    }
  };

  const sendViaTextLocal = async (phoneNumber, message, appointmentDetails) => {
    const params = new URLSearchParams({
      apikey: SMS_CONFIG.TEXTLOCAL.API_KEY,
      numbers: phoneNumber.replace('91', ''), // Remove country code
      message: message,
      sender: SMS_CONFIG.TEXTLOCAL.SENDER
    });

    const response = await fetch(SMS_CONFIG.TEXTLOCAL.API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: params
    });

    const result = await response.json();
    
    if (result.status === 'success') {
      return {
        success: true,
        messageId: result.messageid || 'TEXTLOCAL_' + Date.now(),
        provider: 'TextLocal'
      };
    } else {
      throw new Error(result.errors?.[0]?.message || 'TextLocal sending failed');
    }
  };

  const sendViaMSG91 = async (phoneNumber, message, appointmentDetails) => {
    try {
      const response = await fetch(SMS_CONFIG.MSG91.API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'authkey': SMS_CONFIG.MSG91.API_KEY
        },
        body: JSON.stringify({
          template_id: SMS_CONFIG.MSG91.TEMPLATE_ID,
          sender: SMS_CONFIG.MSG91.SENDER_ID,
          mobiles: phoneNumber,
          // Template variables for personalized SMS
          var1: appointmentDetails.patientName || 'Patient',
          var2: appointmentDetails.doctorName || 'Doctor',
          var3: appointmentDetails.appointmentDate || 'Today',
          var4: appointmentDetails.appointmentTime || '10:00 AM',
          var5: appointmentDetails.hospitalName || 'Nabha Healthcare'
        })
      });

      const result = await response.json();
      
      if (result.type === 'success') {
        return {
          success: true,
          messageId: result.message_id || 'MSG91_' + Date.now(),
          provider: 'MSG91'
        };
      } else {
        throw new Error(result.message || 'MSG91 sending failed');
      }
    } catch (error) {
      throw new Error('MSG91 service unavailable');
    }
  };

  const sendDemoSMS = async (phoneNumber, message, appointmentDetails) => {
    // Enhanced demo SMS with better simulation
    return new Promise((resolve) => {
      setTimeout(() => {
        console.log('🚀 === SMS DEMO MODE ===');
        console.log(`📱 To: ${phoneNumber}`);
        console.log(`📄 Message:`);
        console.log(message);
        console.log(`👤 Patient: ${appointmentDetails.patientName}`);
        console.log(`👨‍⚕️ Doctor: ${appointmentDetails.doctorName}`);
        console.log(`📅 Date: ${appointmentDetails.appointmentDate}`);
        console.log(`🕐 Time: ${appointmentDetails.appointmentTime}`);
        console.log('========================');
        
        // Show in UI that it's demo mode
        setTimeout(() => {
          addMessage(`📱 **DEMO MODE ACTIVE**\n\nSMS would be sent to: ${phoneNumber}\n\n⚠️ **To receive real SMS messages:**\n1. Sign up for a free SMS service:\n   • Fast2SMS (India): https://www.fast2sms.com/\n   • TextLocal (Global): https://www.textlocal.in/\n\n2. Update SMS_CONFIG with your API key\n3. Set DEMO_MODE to false\n\n📋 **Your Appointment Details:**\n👤 ${appointmentDetails.patientName}\n👨‍⚕️ ${appointmentDetails.doctorName}\n📅 ${appointmentDetails.appointmentDate}\n🕐 ${appointmentDetails.appointmentTime}`, 'bot');
        }, 2000);
        
        resolve({
          success: true,
          messageId: 'DEMO_' + Math.random().toString(36).substr(2, 9),
          provider: 'Demo Mode'
        });
      }, 1000);
    });
  };

  const sendFallbackSMS = async (phoneNumber, message, appointmentDetails) => {
    // Simulate SMS sending for demo purposes
    // In production, implement alternative SMS service like Twilio
    
    return new Promise((resolve) => {
      setTimeout(() => {
        console.log(`📱 SMS sent to ${phoneNumber}:`);
        console.log(message);
        
        resolve({
          success: true,
          messageId: 'DEMO_' + Math.random().toString(36).substr(2, 9),
          provider: 'demo'
        });
      }, 1000);
    });
  };

  const generateSMSMessage = (appointmentDetails) => {
    const { patientName, doctorName, appointmentDate, appointmentTime, hospitalName } = appointmentDetails;
    
    return `🏥 APPOINTMENT CONFIRMED
    
Hi ${patientName}!

Your appointment has been booked:
👨‍⚕️ Doctor: ${doctorName}
📅 Date: ${appointmentDate}
🕐 Time: ${appointmentTime}
🏥 Venue: ${hospitalName}

For any changes, call: +91-XXXXXXXXXX
Or WhatsApp: +91-XXXXXXXXXX

Thank you for choosing Nabha Healthcare!`;
  };

  const extractPatientDetails = (conversationHistory) => {
    // Extract patient details from conversation
    const details = {
      patientName: '',
      phoneNumber: '',
      appointmentDate: '',
      appointmentTime: '',
      doctorName: '',
      symptoms: []
    };

    // Simple extraction logic - can be enhanced with NLP
    const messages = conversationHistory.join(' ').toLowerCase();
    
    // Extract phone number
    const phoneMatch = messages.match(/\b(\+?91[-.\s]?)?[6-9]\d{9}\b/);
    if (phoneMatch) {
      details.phoneNumber = phoneMatch[0];
    }

    // Extract name (look for "my name is" or "i am")
    const nameMatch = messages.match(/(?:my name is|i am|i'm)\s+([a-zA-Z\s]{2,30})/i);
    if (nameMatch) {
      details.patientName = nameMatch[1].trim();
    }

    // Extract date preferences
    if (messages.includes('today')) {
      details.appointmentDate = new Date().toLocaleDateString();
    } else if (messages.includes('tomorrow')) {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      details.appointmentDate = tomorrow.toLocaleDateString();
    }

    // Use patient data state if available
    if (patientData.name) details.patientName = patientData.name;
    if (patientData.phone) details.phoneNumber = patientData.phone;
    if (patientData.preferredDate) details.appointmentDate = patientData.preferredDate;
    if (patientData.selectedSlot) details.appointmentTime = patientData.selectedSlot;
    if (patientData.preferredDoctor) {
      const doctor = Object.values(DOCTORS_DATABASE).find(d => d.id === patientData.preferredDoctor);
      details.doctorName = doctor ? doctor.name : '';
    }

    return details;
  };

  const speakText = (text) => {
    if (speechEnabled && 'speechSynthesis' in window) {
      window.speechSynthesis.cancel();
      
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.rate = 0.9;
      utterance.pitch = 1;
      utterance.volume = 0.8;
      
      const voices = window.speechSynthesis.getVoices();
      const preferredVoice = voices.find(voice => 
        voice.lang.includes('en') && (voice.name.includes('Google') || voice.name.includes('Microsoft'))
      );
      if (preferredVoice) {
        utterance.voice = preferredVoice;
      }
      
      window.speechSynthesis.speak(utterance);
    }
  };

  const startListening = () => {
    if (recognition && !isListening) {
      setIsListening(true);
      recognition.start();
    }
  };

  const stopListening = () => {
    if (recognition && isListening) {
      recognition.stop();
      setIsListening(false);
    }
  };

  const sendMessage = async () => {
    if (!input.trim() || !languageSelected) return;
    addMessage(input, "user");
    const userInput = input;
    setInput("");
    setLoading(true);

    // Check for doctor selection by number in DOCTOR_RECOMMENDATION state
    if (conversationState === CONVERSATION_STATES.DOCTOR_RECOMMENDATION) {
      const numberMatch = userInput.match(/^[1-3]$/);
      if (numberMatch) {
        const selectedIndex = parseInt(userInput) - 1;
        if (recommendedDoctors[selectedIndex]) {
          const selectedDoctor = recommendedDoctors[selectedIndex];
          
          // Update patient data with selected doctor
          setPatientData(prev => ({
            ...prev,
            preferredDoctor: selectedDoctor.id
          }));
          
          // Show doctor selection confirmation and available slots
          const confirmationMessage = `Okay! You've selected **${selectedDoctor.name}**. 😊 ${selectedDoctor.name} specializes in ${selectedDoctor.specialty} and has a rating of ${selectedDoctor.rating} stars. 

Here are the available slots for ${selectedDoctor.name}:
${selectedDoctor.slots.map(slot => `- ${slot}`).join('\n')}

Please select your preferred time. ⏰`;
          
          addMessage(confirmationMessage, "bot");
          setConversationState(CONVERSATION_STATES.SLOT_SELECTION);
          setLoading(false);
          return;
        }
      }
    }

    // Check for time slot selection in SLOT_SELECTION state
    if (conversationState === CONVERSATION_STATES.SLOT_SELECTION) {
      const selectedDoctor = Object.values(DOCTORS_DATABASE).find(d => d.id === patientData.preferredDoctor);
      if (selectedDoctor && selectedDoctor.slots.includes(userInput.trim())) {
        setPatientData(prev => ({
          ...prev,
          selectedSlot: userInput.trim()
        }));
        
        const slotConfirmation = `Perfect! I've scheduled your appointment with **${selectedDoctor.name}** for **${userInput.trim()}**. 

To complete your booking, please provide:
👤 Your full name
📞 Your phone number (for SMS confirmation)

You can share these details now.`;
        
        addMessage(slotConfirmation, "bot");
        setConversationState(CONVERSATION_STATES.PATIENT_DETAILS);
        setLoading(false);
        return;
      }
    }

    // Check for patient details in PATIENT_DETAILS state
    if (conversationState === CONVERSATION_STATES.PATIENT_DETAILS) {
      const nameMatch = userInput.match(/\b([A-Z][a-z]+ [A-Z][a-z]+)\b/i);
      const phoneMatch = userInput.match(/\b(\+?91[-.\s]?)?[6-9]\d{9}\b/);
      
      if (nameMatch) {
        setPatientData(prev => ({
          ...prev,
          name: nameMatch[0]
        }));
      }
      
      if (phoneMatch) {
        setPatientData(prev => ({
          ...prev,
          phone: phoneMatch[0]
        }));
      }
      
      // If we have both name and phone, confirm the appointment
      const updatedData = { ...patientData };
      if (nameMatch) updatedData.name = nameMatch[0];
      if (phoneMatch) updatedData.phone = phoneMatch[0];
      
      if (updatedData.name && updatedData.phone && updatedData.preferredDoctor && updatedData.selectedSlot) {
        const selectedDoctor = Object.values(DOCTORS_DATABASE).find(d => d.id === updatedData.preferredDoctor);
        
        const confirmationMessage = `✅ **Appointment Confirmed!**

📋 **Appointment Details:**
👤 **Patient:** ${updatedData.name}
👨‍⚕️ **Doctor:** ${selectedDoctor?.name}
🕐 **Time:** ${updatedData.selectedSlot}
📅 **Date:** ${new Date().toLocaleDateString()}
🏥 **Location:** Nabha Healthcare
📞 **Contact:** ${updatedData.phone}

📱 You'll receive an SMS confirmation shortly at ${updatedData.phone}.

Thank you for choosing Nabha Healthcare! 🏥✨`;
        
        addMessage(confirmationMessage, "bot");
        setConversationState(CONVERSATION_STATES.CONFIRMATION);
        
        // Send SMS immediately
        setTimeout(() => {
          const appointmentDetails = {
            patientName: updatedData.name,
            doctorName: selectedDoctor?.name,
            appointmentTime: updatedData.selectedSlot,
            appointmentDate: new Date().toLocaleDateString(),
            phoneNumber: updatedData.phone,
            hospitalName: 'Nabha Healthcare'
          };
          sendAppointmentSMS(appointmentDetails);
        }, 1000);
        
        setLoading(false);
        return;
      } else {
        // Still need more information
        const missingInfo = [];
        if (!updatedData.name) missingInfo.push("👤 Full name");
        if (!updatedData.phone) missingInfo.push("📞 Phone number");
        
        if (missingInfo.length > 0) {
          addMessage(`I still need the following information to complete your booking:\n${missingInfo.join('\n')}\n\nPlease provide the missing details.`, "bot");
          setLoading(false);
          return;
        }
      }
    }

    // Check if user provided phone number for SMS
    const phoneMatch = userInput.match(/\b(\+?91[-.\s]?)?[6-9]\d{9}\b/);
    if (phoneMatch && conversationState === CONVERSATION_STATES.CONFIRMATION) {
      // User provided phone number after appointment confirmation
      const phoneNumber = phoneMatch[0];
      const appointmentDetails = extractPatientDetails([...messages.map(m => m.text), userInput]);
      appointmentDetails.phoneNumber = phoneNumber;
      
      // Use the selected doctor from patientData, not hardcoded
      if (patientData.preferredDoctor) {
        const selectedDoctor = Object.values(DOCTORS_DATABASE).find(d => d.id === patientData.preferredDoctor);
        appointmentDetails.doctorName = selectedDoctor ? selectedDoctor.name : 'Doctor';
      } else {
        appointmentDetails.doctorName = appointmentDetails.doctorName || 'Doctor';
      }
      
      appointmentDetails.appointmentTime = appointmentDetails.appointmentTime || '10:00 AM';
      appointmentDetails.appointmentDate = appointmentDetails.appointmentDate || new Date().toLocaleDateString();
      appointmentDetails.hospitalName = 'Nabha Healthcare';
      
      // Send SMS immediately
      setTimeout(() => {
        sendAppointmentSMS(appointmentDetails);
      }, 1000);
      
      setLoading(false);
      return;
    }

    // Agentic AI Processing
    const userIntents = analyzeUserIntent(userInput);
    const agenticResult = generateAgenticResponse(userInput, userIntents);
    
    // Update conversation context
    setConversationContext(prev => ({
      ...prev,
      userIntents: [...prev.userIntents, ...userIntents],
      suggestedActions: agenticResult.agenticActions
    }));

    const typingMessage = { text: "Assistant is analyzing...", type: "bot", isTyping: true };
    setMessages((prev) => [...prev, typingMessage]);

    try {
      // Enhanced system instruction with agentic context
      const conversationHistory = messages.slice(-6).map(msg => 
        `${msg.type === 'user' ? 'Patient' : 'Assistant'}: ${msg.text}`
      ).join('\n');
      
      const agenticContext = `
      Current Conversation State: ${conversationState}
      Detected Intents: ${userIntents.map(i => i.type).join(', ')}
      Recommended Doctors: ${recommendedDoctors.map(d => d.name).join(', ')}
      Patient Data: ${JSON.stringify(patientData)}
      
      Recent Conversation:
      ${conversationHistory}
      `;

      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${API_KEY}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            contents: [{ parts: [{ text: `Context: ${agenticContext}\n\nUser Message: ${userInput}` }] }],
            system_instruction: {
              parts: [
                {
                  text: `You are an advanced agentic AI assistant for Nabha Healthcare, specializing in intelligent appointment booking and medical consultation guidance. You have autonomous decision-making capabilities and can take proactive actions.

                  IMPORTANT: Respond in ${LANGUAGES[currentLanguage].name} language. Be culturally sensitive and use appropriate greetings and expressions for this language.

                  AGENTIC CAPABILITIES:
                  - Autonomously analyze symptoms and recommend appropriate doctors
                  - Proactively suggest optimal appointment times based on urgency and availability
                  - Extract patient information from natural conversation
                  - Make intelligent decisions about next steps in the booking process
                  - Provide personalized medical guidance within scope
                  - Send real-time SMS confirmations to patients after booking

                  AVAILABLE DOCTORS & EXPERTISE:
                  ${Object.values(DOCTORS_DATABASE).map(doc => 
                    `- ${doc.name} (${doc.specialty}) - ${doc.experience}yr exp, Rating: ${doc.rating}/5
                      Specializes in: ${doc.conditions.join(', ')}
                      Available: ${doc.availability.start}-${doc.availability.end}
                      Slots: ${doc.slots.join(', ')}`
                  ).join('\n')}

                  AGENTIC BEHAVIOR GUIDELINES:
                  1. **Proactive Analysis**: Automatically identify symptoms, urgency, and suitable specialists
                  2. **Smart Recommendations**: Suggest the best-matched doctors based on symptoms and ratings
                  3. **Autonomous Scheduling**: Intelligently propose optimal time slots
                  4. **Context Awareness**: Remember all conversation details and build on previous interactions
                  5. **Decision Making**: Make informed choices about next steps without always asking
                  6. **Empathetic Intelligence**: Show understanding and provide reassurance
                  7. **Efficient Processing**: Move conversations forward efficiently while being thorough
                  8. **SMS Integration**: Automatically send appointment confirmations via SMS after booking

                  CURRENT CONTEXT: ${agenticContext}

                  Your response should be intelligent, contextual, and take autonomous action when appropriate. Use the conversation state to determine if you should recommend doctors, suggest times, request details, or confirm bookings without being explicitly asked.

                  Use emojis, formatting, and maintain a professional yet friendly tone.`,
                },
              ],
            },
          }),
        }
      );

      const data = await response.json();
      setMessages((prev) => {
        const msgs = prev.filter((msg) => !msg.isTyping);
        const botReply =
          data.candidates?.[0]?.content?.parts?.[0]?.text ||
          "I apologize, but I couldn't process your request. Please try again.";
        return [...msgs, { text: botReply, type: "bot", timestamp: new Date() }];
      });

      const botReply = data.candidates?.[0]?.content?.parts?.[0]?.text;
      
      // Execute agentic actions
      if (agenticResult.agenticActions.length > 0) {
        agenticResult.agenticActions.forEach(action => {
          executeAgenticAction(action, conversationContext);
        });
      }

      if (botReply && speechEnabled) {
        setTimeout(() => speakText(botReply), 500);
      }
    } catch (error) {
      setMessages((prev) => {
        const msgs = prev.filter((msg) => !msg.isTyping);
        return [
          ...msgs,
          { text: "I'm having trouble connecting right now. Please check your internet connection and try again.", type: "bot" },
        ];
      });
    } finally {
      setLoading(false);
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  const formatTime = (timestamp) => {
    return timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  const toggleChat = () => {
    setIsOpen(!isOpen);
  };

  return (
    <>
      {/* CSS for Mobile Responsiveness */}
      <style>{`
        @media (max-width: 768px) {
          .appointment-chat-window {
            position: fixed !important;
            bottom: 0 !important;
            right: 0 !important;
            left: 0 !important;
            width: 100% !important;
            height: 70vh !important;
            max-height: 500px !important;
            border-radius: 16px 16px 0 0 !important;
            padding-top: 60px !important; /* Add space for close button */
          }
          .appointment-input-area {
            padding: 12px !important;
          }
          .appointment-input-wrapper {
            gap: 6px !important;
          }
          .appointment-textarea {
            padding: 10px 36px 10px 12px !important;
            font-size: 16px !important;
            min-height: 42px !important;
          }
          .appointment-mic-button {
            right: 6px !important;
            width: 28px !important;
            height: 28px !important;
            padding: 6px !important;
          }
          .appointment-send-button {
            width: 42px !important;
            height: 42px !important;
            min-width: 42px !important;
            flex-shrink: 0 !important;
          }
          /* Mobile Close Button - Show on mobile */
          .mobile-close-button {
            display: flex !important;
            position: absolute !important;
            top: 12px !important;
            right: 12px !important;
            left: auto !important;
            width: 44px !important;
            height: 44px !important;
            background: #059669 !important;
            color: #fff !important;
            box-shadow: 0 4px 16px rgba(5,150,105,0.15) !important;
            z-index: 100 !important;
            align-items: center;
            justify-content: center;
          }
          .mobile-close-button:hover {
            background-color: #047857 !important;
            transform: scale(1.08);
          }
          
          .desktop-close-button {
            display: none !important;
          }
          
          /* Mobile Language Selection */
          .language-selection-mobile {
            padding: 20px 15px !important;
            min-height: 350px !important;
          }
          
          .language-welcome-title-mobile {
            font-size: 18px !important;
          }
          
          .language-icon-mobile {
            width: 60px !important;
            height: 60px !important;
            font-size: 36px !important;
          }
          
          .language-grid-mobile {
            max-width: 100% !important;
            gap: 10px !important;
          }
          
          .language-card-mobile {
            padding: 14px 16px !important;
          }
          
          .language-name-large-mobile {
            font-size: 15px !important;
          }
        }
        
        /* Desktop - Hide mobile close button, show desktop close button */
        @media (min-width: 769px) {
          .mobile-close-button {
            display: none !important;
          }
          
          .desktop-close-button {
            display: flex !important;
          }
        }
        
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        
        @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.5; }
        }
        
        @keyframes bounce {
          0%, 80%, 100% { transform: translateY(0); }
          40% { transform: translateY(-10px); }
        }
        
        /* Language Card Hover Effects */
        .language-card:hover .language-arrow {
          transform: translateX(3px);
        }
        
        .language-card:hover {
          border-color: #059669 !important;
          box-shadow: 0 8px 25px rgba(5, 150, 105, 0.15) !important;
          transform: translateY(-2px) !important;
        }
        
        .language-card::before {
          content: '';
          position: absolute;
          top: 0;
          left: -100%;
          width: 100%;
          height: 100%;
          background: linear-gradient(90deg, transparent, rgba(5, 150, 105, 0.1), transparent);
          transition: left 0.5s ease;
        }
        
        .language-card:hover::before {
          left: 100%;
        }
        
        /* Inline Language Button Hover Effects */
        .language-button-inline:hover {
          background-color: #059669 !important;
          color: white !important;
          border-color: #059669 !important;
          transform: translateY(-1px);
          box-shadow: 0 4px 8px rgba(5, 150, 105, 0.3) !important;
        }
      `}</style>

      {/* Chat Toggle Button */}
      <div className="chatbot-toggle" style={styles.chatToggle} onClick={toggleChat}>
        {isOpen ? <X size={24} /> : <MessageCircle size={24} />}
        {!isOpen && <div style={styles.notificationBadge}>💬</div>}
      </div>

      {/* Chat Window */}
      {isOpen && (
        <div className="chatbot-window appointment-chat-window" style={styles.chatWindow}>
          {/* Mobile Close Button - Positioned absolute on top-left */}
          <button 
            onClick={toggleChat} 
            style={styles.mobileCloseButton}
            className="mobile-close-button"
          >
            <X size={16} />
          </button>
          
          <div style={styles.chatContainer}>
            {/* Header */}
            <div style={styles.header}>
              <div style={styles.headerContent}>
                <div style={styles.headerLeft}>
                  <div style={styles.iconContainer}>
                    <Calendar size={24} />
                  </div>
                  <div>
                    <h3 style={styles.title}>Appointment Assistant</h3>
                    <p style={styles.subtitle}>Book your appointment easily</p>
                  </div>
                </div>
                <div style={styles.headerRight}>
                  {speechSupported && (
                    <button
                      onClick={() => setSpeechEnabled(!speechEnabled)}
                      style={{
                        ...styles.headerButton,
                        ...(speechEnabled ? styles.headerButtonActive : {})
                      }}
                      title={speechEnabled ? "Disable voice responses" : "Enable voice responses"}
                    >
                      {speechEnabled ? <Volume2 size={18} /> : <VolumeX size={18} />}
                    </button>
                  )}
                  {/* Desktop Close Button */}
                  <button 
                    onClick={toggleChat} 
                    style={styles.closeButton}
                    className="desktop-close-button"
                  >
                    <X size={18} />
                  </button>
                </div>
              </div>
            </div>

            {/* Chat Messages */}
            <div ref={chatBoxRef} style={styles.chatBox}>
              {messages.map((msg, index) => (
                <div key={index} style={styles.messageContainer}>
                  <div style={{
                    ...styles.messageWrapper,
                    ...(msg.type === "user" ? styles.userMessageWrapper : styles.botMessageWrapper)
                  }}>
                    {msg.type === "bot" && !msg.isTyping && !msg.isLanguageSelection && (
                      <div style={styles.botAvatar}>🤖</div>
                    )}
                    
                    <div style={{
                      ...styles.messageContent,
                      ...(msg.type === "user" ? styles.userMessageContent : styles.botMessageContent)
                    }}>
                      <div style={{
                        ...styles.messageBubble,
                        ...(msg.type === "user" ? styles.userMessage : 
                            msg.isTyping ? styles.typingMessage : styles.botMessage)
                      }}>
                        {msg.isTyping ? (
                          <div style={styles.typingIndicator}>
                            <div style={styles.typingDots}>
                              <div style={{...styles.dot, animationDelay: '0s'}}></div>
                              <div style={{...styles.dot, animationDelay: '0.1s'}}></div>
                              <div style={{...styles.dot, animationDelay: '0.2s'}}></div>
                            </div>
                            <span>Processing...</span>
                          </div>
                        ) : msg.isLanguageSelection ? (
                          <div style={styles.languageSelectionInChat}>
                            <div style={styles.languageTitle}>Choose your language:</div>
                            <div style={styles.languageButtonsInline}>
                              {Object.entries(LANGUAGES).map(([langCode, lang]) => (
                                <button
                                  key={langCode}
                                  onClick={() => handleLanguageSelect(langCode)}
                                  style={styles.languageButtonInline}
                                  className="language-button-inline"
                                >
                                  <span style={styles.languageFlag}>{lang.flag}</span>
                                  <span>{lang.name}</span>
                                </button>
                              ))}
                            </div>
                          </div>
                        ) : (
                          <div style={styles.messageText}>{msg.text}</div>
                        )}
                      </div>
                      {msg.timestamp && !msg.isLanguageSelection && (
                        <div style={{
                          ...styles.timestamp,
                          ...(msg.type === "user" ? styles.timestampRight : styles.timestampLeft)
                        }}>
                          {formatTime(msg.timestamp)}
                        </div>
                      )}
                    </div>

                    {msg.type === "user" && (
                      <div style={styles.userAvatar}>👤</div>
                    )}
                  </div>
                </div>
              ))}
            </div>

            {/* Input Area */}
            <div style={styles.inputArea} className="appointment-input-area">
              <div style={styles.inputWrapper} className="appointment-input-wrapper">
                <div style={styles.textareaContainer}>
                  <textarea
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    onKeyDown={handleKeyPress}
                    placeholder={languageSelected ? LANGUAGES[currentLanguage].placeholder : "Please select a language first..."}
                    style={{
                      ...styles.textarea,
                      ...(loading ? styles.textareaDisabled : {})
                    }}
                    className="appointment-textarea"
                    rows="1"
                    disabled={loading || !languageSelected}
                  />
                  {speechSupported && (
                    <button
                      onClick={isListening ? stopListening : startListening}
                      style={{
                        ...styles.micButton,
                        ...(isListening ? styles.micButtonActive : {})
                      }}
                      className="appointment-mic-button"
                      title={isListening ? "Stop listening" : "Start voice input"}
                      disabled={loading}
                    >
                      {isListening ? <MicOff size={16} /> : <Mic size={16} />}
                    </button>
                  )}
                </div>
                
                <button
                  onClick={sendMessage}
                  disabled={loading || !input.trim() || !languageSelected}
                  style={{
                    ...styles.sendButton,
                    ...(loading || !input.trim() || !languageSelected ? styles.sendButtonDisabled : {})
                  }}
                  className="appointment-send-button"
                >
                  {loading ? (
                    <div style={styles.spinner}></div>
                  ) : (
                    <Send size={18} />
                  )}
                </button>
              </div>
              
              {isListening && (
                <div style={styles.listeningIndicator}>
                  <div style={styles.listeningDot}></div>
                  <span style={styles.listeningText}>{LANGUAGES[currentLanguage].listening}</span>
                  <div style={styles.listeningDot}></div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* CSS Keyframes */}
      <style>{`
        @keyframes bounce {
          0%, 80%, 100% { transform: translateY(0); }
          40% { transform: translateY(-10px); }
        }
        
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        
        @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.5; }
        }

        @keyframes chatPulse {
          0%, 100% { transform: scale(1); }
          50% { transform: scale(1.05); }
        }
      `}</style>
    </>
  );
};

const styles = {
  // Chat Toggle Button
  chatToggle: {
    position: 'fixed',
    bottom: '24px',
    right: '24px',
    width: '60px',
    height: '60px',
    backgroundColor: '#059669',
    borderRadius: '50%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    cursor: 'pointer',
    boxShadow: '0 8px 32px rgba(5, 150, 105, 0.3)',
    color: 'white',
    zIndex: 1000,
    transition: 'all 0.3s ease',
    animation: 'chatPulse 2s infinite',
    border: 'none',
  },
  
  notificationBadge: {
    position: 'absolute',
    top: '-8px',
    right: '-8px',
    width: '24px',
    height: '24px',
    backgroundColor: '#ef4444',
    borderRadius: '50%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '12px',
    fontWeight: 'bold',
    animation: 'bounce 1s infinite',
  },

  // Chat Window
  chatWindow: {
    position: 'fixed',
    bottom: '100px',
    right: '24px',
    width: '400px',
    height: '500px',
    zIndex: 999,
    boxShadow: '0 20px 40px rgba(0,0,0,0.15)',
    borderRadius: '16px',
    overflow: 'hidden',
    backgroundColor: '#ffffff',
    '@media (max-width: 768px)': {
      position: 'fixed',
      bottom: '0',
      right: '0',
      left: '0',
      width: '100%',
      height: '70vh',
      maxHeight: '500px',
      borderRadius: '16px 16px 0 0',
      paddingTop: '60px', /* Prevents overlap with close button */
    },
  },

  chatContainer: {
    width: '100%',
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
  },

  // Header
  header: {
    background: 'linear-gradient(135deg, #059669 0%, #047857 100%)',
    padding: '16px',
    color: 'white',
  },

  headerContent: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
  },

  headerLeft: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
  },

  iconContainer: {
    width: '40px',
    height: '40px',
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    borderRadius: '50%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  title: {
    margin: 0,
    fontSize: '16px',
    fontWeight: '600',
    lineHeight: '1.2',
  },

  subtitle: {
    margin: 0,
    fontSize: '12px',
    opacity: 0.9,
    lineHeight: '1.2',
  },

  headerRight: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
  },

  headerButton: {
    background: 'none',
    border: 'none',
    color: 'white',
    cursor: 'pointer',
    padding: '8px',
    borderRadius: '50%',
    transition: 'background-color 0.2s',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  headerButtonActive: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
  },

  closeButton: {
    background: 'none',
    border: 'none',
    color: 'white',
    cursor: 'pointer',
    padding: '8px',
    borderRadius: '50%',
    transition: 'background-color 0.2s',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  mobileCloseButton: {
    position: 'absolute',
    top: '12px',
    right: '12px',
    zIndex: 100,
    background: '#059669',
    border: 'none',
    color: 'white',
    cursor: 'pointer',
    padding: '0',
    borderRadius: '50%',
    transition: 'background-color 0.2s, box-shadow 0.2s',
    display: 'none', // Hidden by default, shown on mobile via CSS
    alignItems: 'center',
    justifyContent: 'center',
    width: '44px',
    height: '44px',
    boxShadow: '0 4px 16px rgba(5,150,105,0.15)',
    fontSize: '22px',
  },

  // Chat Messages
  chatBox: {
    flex: 1,
    overflowY: 'auto',
    padding: '16px',
    backgroundColor: '#f9fafb',
  },

  messageContainer: {
    marginBottom: '16px',
  },

  messageWrapper: {
    display: 'flex',
    alignItems: 'flex-end',
    gap: '8px',
  },

  userMessageWrapper: {
    flexDirection: 'row-reverse',
  },

  botMessageWrapper: {
    flexDirection: 'row',
  },

  messageContent: {
    maxWidth: '80%',
  },

  userMessageContent: {
    alignItems: 'flex-end',
  },

  botMessageContent: {
    alignItems: 'flex-start',
  },

  messageBubble: {
    padding: '12px 16px',
    borderRadius: '18px',
    fontSize: '14px',
    lineHeight: '1.4',
    wordWrap: 'break-word',
  },

  userMessage: {
    backgroundColor: '#059669',
    color: 'white',
    borderBottomRightRadius: '4px',
  },

  botMessage: {
    backgroundColor: 'white',
    color: '#1f2937',
    border: '1px solid #e5e7eb',
    borderBottomLeftRadius: '4px',
  },

  typingMessage: {
    backgroundColor: 'white',
    color: '#6b7280',
    border: '1px solid #e5e7eb',
    borderBottomLeftRadius: '4px',
  },

  messageText: {
    whiteSpace: 'pre-wrap',
  },

  timestamp: {
    fontSize: '11px',
    color: '#9ca3af',
    marginTop: '4px',
  },

  timestampRight: {
    textAlign: 'right',
  },

  timestampLeft: {
    textAlign: 'left',
  },

  botAvatar: {
    width: '32px',
    height: '32px',
    borderRadius: '50%',
    backgroundColor: '#e5e7eb',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '16px',
    flexShrink: 0,
  },

  userAvatar: {
    width: '32px',
    height: '32px',
    borderRadius: '50%',
    backgroundColor: '#059669',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '16px',
    flexShrink: 0,
  },

  // Typing Indicator
  typingIndicator: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
  },

  typingDots: {
    display: 'flex',
    gap: '4px',
  },

  dot: {
    width: '8px',
    height: '8px',
    borderRadius: '50%',
    backgroundColor: '#9ca3af',
    animation: 'bounce 1.4s infinite',
  },

  // Input Area
  inputArea: {
    padding: '16px',
    backgroundColor: 'white',
    borderTop: '1px solid #e5e7eb',
    '@media (max-width: 768px)': {
      padding: '12px'
    }
  },

  inputWrapper: {
    display: 'flex',
    gap: '8px',
    alignItems: 'flex-end',
    '@media (max-width: 768px)': {
      gap: '6px'
    }
  },

  textareaContainer: {
    flex: 1,
    position: 'relative',
    minWidth: 0, // Prevents flex item from overflowing
  },

  textarea: {
    width: '100%',
    minHeight: '40px',
    maxHeight: '100px',
    padding: '12px 40px 12px 16px',
    border: '1px solid #d1d5db',
    borderRadius: '20px',
    fontSize: '14px',
    fontFamily: 'inherit',
    resize: 'none',
    outline: 'none',
    transition: 'border-color 0.2s',
    boxSizing: 'border-box',
    '@media (max-width: 768px)': {
      padding: '10px 36px 10px 12px',
      fontSize: '16px', // Prevents zoom on iOS
      minHeight: '42px'
    }
  },

  textareaDisabled: {
    backgroundColor: '#f3f4f6',
    cursor: 'not-allowed',
  },

  micButton: {
    position: 'absolute',
    right: '8px',
    top: '50%',
    transform: 'translateY(-50%)',
    background: 'none',
    border: 'none',
    cursor: 'pointer',
    padding: '8px',
    borderRadius: '50%',
    transition: 'background-color 0.2s',
    color: '#6b7280',
    width: '32px',
    height: '32px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    '@media (max-width: 768px)': {
      right: '6px',
      width: '28px',
      height: '28px',
      padding: '6px'
    }
  },

  micButtonActive: {
    backgroundColor: '#fee2e2',
    color: '#dc2626',
  },

  sendButton: {
    width: '40px',
    height: '40px',
    backgroundColor: '#059669',
    border: 'none',
    borderRadius: '50%',
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    color: 'white',
    transition: 'background-color 0.2s',
    flexShrink: 0,
    minWidth: '40px',
    '@media (max-width: 768px)': {
      width: '42px',
      height: '42px',
      minWidth: '42px'
    }
  },

  sendButtonDisabled: {
    backgroundColor: '#d1d5db',
    cursor: 'not-allowed',
  },

  spinner: {
    width: '18px',
    height: '18px',
    border: '2px solid #ffffff',
    borderTop: '2px solid transparent',
    borderRadius: '50%',
    animation: 'spin 1s linear infinite',
  },

  // Listening Indicator
  listeningIndicator: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '8px',
    marginTop: '8px',
    fontSize: '12px',
    color: '#dc2626',
  },

  listeningDot: {
    width: '8px',
    height: '8px',
    borderRadius: '50%',
    backgroundColor: '#dc2626',
    animation: 'pulse 1s infinite',
  },

  listeningText: {
    fontWeight: '500',
  },

  // Language Selection Styles
  languageSelection: {
    padding: '30px 25px',
    background: 'linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%)',
    minHeight: '400px',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    gap: '25px',
  },

  languageWelcome: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: '15px',
    textAlign: 'center',
  },

  languageIcon: {
    fontSize: '48px',
    background: 'linear-gradient(135deg, #059669 0%, #047857 100%)',
    borderRadius: '50%',
    width: '80px',
    height: '80px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    boxShadow: '0 8px 25px rgba(5, 150, 105, 0.3)',
    animation: 'bounce 2s infinite',
  },

  languageWelcomeText: {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px',
  },

  languageWelcomeTitle: {
    margin: 0,
    fontSize: '20px',
    fontWeight: '700',
    color: '#1f2937',
    background: 'linear-gradient(135deg, #059669 0%, #047857 100%)',
    WebkitBackgroundClip: 'text',
    WebkitTextFillColor: 'transparent',
    backgroundClip: 'text',
  },

  languageWelcomeSubtitle: {
    margin: 0,
    fontSize: '14px',
    color: '#64748b',
    fontWeight: '500',
  },

  languageGrid: {
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
    width: '100%',
    maxWidth: '280px',
  },

  languageCard: {
    display: 'flex',
    alignItems: 'center',
    gap: '15px',
    padding: '18px 20px',
    backgroundColor: '#ffffff',
    border: '2px solid #e2e8f0',
    borderRadius: '12px',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
    boxShadow: '0 2px 8px rgba(0, 0, 0, 0.08)',
    position: 'relative',
    overflow: 'hidden',
  },

  languageCardHover: {
    transform: 'translateY(-2px)',
    boxShadow: '0 8px 25px rgba(5, 150, 105, 0.15)',
    borderColor: '#059669',
  },

  languageFlagLarge: {
    fontSize: '32px',
    minWidth: '40px',
    textAlign: 'center',
  },

  languageCardContent: {
    flex: 1,
    display: 'flex',
    flexDirection: 'column',
    gap: '4px',
  },

  languageNameLarge: {
    fontSize: '16px',
    fontWeight: '600',
    color: '#1f2937',
  },

  languageSelectText: {
    fontSize: '12px',
    color: '#64748b',
    fontWeight: '500',
  },

  languageArrow: {
    fontSize: '18px',
    color: '#059669',
    fontWeight: '600',
    transition: 'transform 0.3s ease',
  },

  languageFooter: {
    textAlign: 'center',
    marginTop: '10px',
  },

  languageFooterText: {
    margin: 0,
    fontSize: '12px',
    color: '#64748b',
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
    justifyContent: 'center',
  },

  languageFooterIcon: {
    fontSize: '16px',
  },

  // Old styles (keeping for backward compatibility)
  languageTitle: {
    fontSize: '14px',
    fontWeight: '600',
    color: '#1f2937',
    textAlign: 'center',
    marginBottom: '8px',
  },

  languageButtons: {
    display: 'flex',
    gap: '8px',
    justifyContent: 'center',
    flexWrap: 'wrap',
  },

  languageButton: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    padding: '8px 12px',
    backgroundColor: '#ffffff',
    border: '2px solid #e2e8f0',
    borderRadius: '8px',
    cursor: 'pointer',
    transition: 'all 0.2s ease',
    fontSize: '13px',
    fontWeight: '500',
    color: '#374151',
    minWidth: '85px',
    justifyContent: 'center',
  },

  languageButtonActive: {
    backgroundColor: '#059669',
    borderColor: '#059669',
    color: 'white',
    transform: 'translateY(-1px)',
    boxShadow: '0 4px 8px rgba(5, 150, 105, 0.3)',
  },

  languageFlag: {
    fontSize: '16px',
  },

  languageName: {
    fontSize: '12px',
    fontWeight: '600',
  },

  // Inline Language Selection Styles (in chat)
  languageSelectionInChat: {
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
    padding: '16px',
    backgroundColor: '#f8fafc',
    borderRadius: '12px',
    border: '2px solid #e2e8f0',
  },

  languageTitle: {
    fontSize: '14px',
    fontWeight: '600',
    color: '#1f2937',
    textAlign: 'center',
    marginBottom: '8px',
  },

  languageButtonsInline: {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px',
  },

  languageButtonInline: {
    display: 'flex',
    alignItems: 'center',
    gap: '10px',
    padding: '12px 16px',
    backgroundColor: '#ffffff',
    border: '2px solid #e2e8f0',
    borderRadius: '8px',
    cursor: 'pointer',
    transition: 'all 0.2s ease',
    fontSize: '14px',
    fontWeight: '500',
    color: '#374151',
    justifyContent: 'center',
    boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
  },
};

export default AppointmentChatBot;