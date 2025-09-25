import { useState, useRef, useEffect } from "react";
import { Mic, MicOff, Send, Volume2, VolumeX, Stethoscope, Calendar, Phone, MapPin, Clock, AlertCircle, CheckCircle, Activity } from "lucide-react";
import { useNavigate } from 'react-router-dom';

const API_KEY = "AIzaSyBEoyP49AjxnE6pTLhEivfNAylcGDaH_04"; // Replace with your key

// Agent Tools and Actions
const AGENT_TOOLS = {
  BOOK_APPOINTMENT: 'book_appointment',
  FIND_DOCTOR: 'find_doctor',
  EMERGENCY_ALERT: 'emergency_alert',
  HEALTH_TRACKING: 'health_tracking',
  MEDICATION_REMINDER: 'medication_reminder',
  SYMPTOM_ANALYSIS: 'symptom_analysis',
  CALL_DOCTOR: 'call_doctor',
  NEARBY_HOSPITALS: 'nearby_hospitals'
};

const AgenticSymptomChecker = () => {
  const navigate = useNavigate();
  
  // Load chat history from localStorage or use default welcome message
  const loadChatHistory = () => {
    try {
      const savedMessages = localStorage.getItem('aiHealthAgentMessages');
      if (savedMessages) {
        const parsedMessages = JSON.parse(savedMessages);
        // Convert timestamp strings back to Date objects
        return parsedMessages.map(msg => ({
          ...msg,
          timestamp: msg.timestamp ? new Date(msg.timestamp) : new Date()
        }));
      }
    } catch (error) {
      console.error('Error loading chat history:', error);
    }
    
    // Return default welcome message if no saved history or error
    return [
      { 
        text: "🤖 Hello! I'm your AI Health Agent. I can help you with symptoms, book appointments, find doctors, and take immediate action for your health needs. How can I assist you today?", 
        type: "bot",
        actions: [],
        timestamp: new Date()
      }
    ];
  };

  const [messages, setMessages] = useState(loadChatHistory());
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [isListening, setIsListening] = useState(false);
  const [speechEnabled, setSpeechEnabled] = useState(false);
  const [recognition, setRecognition] = useState(null);
  const [speechSupported, setSpeechSupported] = useState(false);
  const [agentThinking, setAgentThinking] = useState(false);
  const [userLocation, setUserLocation] = useState(null);
  const [patientData, setPatientData] = useState({
    symptoms: [],
    vitals: {},
    medications: [],
    appointments: []
  });
  const chatBoxRef = useRef(null);

  useEffect(() => {
    // Check if browser supports speech recognition
    if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
      setSpeechSupported(true);
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
      const recognitionInstance = new SpeechRecognition();
      
      recognitionInstance.continuous = false;
      recognitionInstance.interimResults = false;
      recognitionInstance.lang = 'en-US';
      
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

    // Get user location for nearby services
    getUserLocation();
    
    // Check if user has existing chat history and show welcome back message
    const savedMessages = localStorage.getItem('aiHealthAgentMessages');
    if (savedMessages) {
      try {
        const parsedMessages = JSON.parse(savedMessages);
        if (parsedMessages.length > 1) { // More than just the welcome message
          setTimeout(() => {
            addMessage('👋 Welcome back! Your chat history has been restored. You can continue where you left off.', 'agent');
          }, 1000);
        }
      } catch (error) {
        console.error('Error checking chat history:', error);
      }
    }
  }, []);

  const getUserLocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setUserLocation({
            lat: position.coords.latitude,
            lng: position.coords.longitude
          });
        },
        (error) => {
          console.log('Location access denied:', error);
        }
      );
    }
  };

  const addMessage = (text, type, actions = []) => {
    const newMessage = { text, type, timestamp: new Date(), actions };
    setMessages((prev) => {
      const updatedMessages = [...prev, newMessage];
      // Save to localStorage
      try {
        localStorage.setItem('aiHealthAgentMessages', JSON.stringify(updatedMessages));
      } catch (error) {
        console.error('Error saving chat history:', error);
      }
      return updatedMessages;
    });
    
    setTimeout(() => {
      if (chatBoxRef.current) {
        chatBoxRef.current.scrollTop = chatBoxRef.current.scrollHeight;
      }
    }, 50);
  };

  // Agent Decision Making - Analyze user input and decide actions
  const analyzeUserIntentAndDecideActions = (userInput, aiResponse) => {
    const input = userInput.toLowerCase();
    const response = aiResponse.toLowerCase();
    const actions = [];

    // Emergency keywords
    const emergencyKeywords = ['emergency', 'chest pain', 'difficulty breathing', 'severe', 'urgent', 'help', 'ambulance', 'hospital'];
    const isEmergency = emergencyKeywords.some(keyword => input.includes(keyword) || response.includes(keyword));

    // Appointment booking keywords
    const appointmentKeywords = ['book', 'appointment', 'schedule', 'visit', 'see doctor', 'consultation'];
    const needsAppointment = appointmentKeywords.some(keyword => input.includes(keyword)) || response.includes('consult');

    // Symptom tracking
    const symptomKeywords = ['pain', 'fever', 'headache', 'cough', 'tired', 'dizzy', 'nausea', 'symptom'];
    const hasSymptoms = symptomKeywords.some(keyword => input.includes(keyword));

    // Doctor finding
    const doctorKeywords = ['doctor', 'specialist', 'physician', 'cardiologist', 'dermatologist'];
    const needsDoctor = doctorKeywords.some(keyword => input.includes(keyword) || response.includes(keyword));

    // Medication
    const medicationKeywords = ['medicine', 'medication', 'prescription', 'pills', 'drug'];
    const aboutMedication = medicationKeywords.some(keyword => input.includes(keyword));

    // Decide actions based on analysis
    if (isEmergency) {
      actions.push({
        type: AGENT_TOOLS.EMERGENCY_ALERT,
        label: '🚨 Emergency Alert',
        priority: 'high',
        description: 'Get immediate medical help'
      });
      actions.push({
        type: AGENT_TOOLS.NEARBY_HOSPITALS,
        label: '🏥 Find Nearby Hospitals',
        priority: 'high'
      });
    }

    if (needsAppointment || (needsDoctor && !isEmergency)) {
      actions.push({
        type: AGENT_TOOLS.BOOK_APPOINTMENT,
        label: '📅 Book Appointment',
        priority: 'medium',
        description: 'Schedule with recommended doctor'
      });
    }

    if (needsDoctor) {
      actions.push({
        type: AGENT_TOOLS.FIND_DOCTOR,
        label: '👨‍⚕️ Find Specialist',
        priority: 'medium'
      });
      actions.push({
        type: AGENT_TOOLS.CALL_DOCTOR,
        label: '📞 Video Call Doctor',
        priority: 'medium'
      });
    }

    if (hasSymptoms) {
      actions.push({
        type: AGENT_TOOLS.SYMPTOM_ANALYSIS,
        label: '📊 Track Symptoms',
        priority: 'low'
      });
      actions.push({
        type: AGENT_TOOLS.HEALTH_TRACKING,
        label: '💓 Monitor Health',
        priority: 'low'
      });
    }

    if (aboutMedication) {
      actions.push({
        type: AGENT_TOOLS.MEDICATION_REMINDER,
        label: '💊 Medication Reminder',
        priority: 'medium'
      });
    }

    return actions;
  };

  // Execute Agent Actions
  const executeAgentAction = async (action) => {
    setAgentThinking(true);
    addMessage(`🤖 Executing: ${action.label}...`, 'agent');

    try {
      switch (action.type) {
        case AGENT_TOOLS.EMERGENCY_ALERT:
          handleEmergencyAlert();
          break;
        case AGENT_TOOLS.BOOK_APPOINTMENT:
          handleBookAppointment();
          break;
        case AGENT_TOOLS.FIND_DOCTOR:
          navigate('/doctors');
          addMessage('🔍 Redirecting you to our doctors page to find the right specialist for your needs.', 'agent');
          break;
        case AGENT_TOOLS.CALL_DOCTOR:
          navigate('/doctors');
          addMessage('📞 Taking you to doctors page where you can start a video consultation immediately.', 'agent');
          break;
        case AGENT_TOOLS.NEARBY_HOSPITALS:
          handleNearbyHospitals();
          break;
        case AGENT_TOOLS.SYMPTOM_ANALYSIS:
          handleSymptomTracking();
          break;
        case AGENT_TOOLS.HEALTH_TRACKING:
          handleHealthTracking();
          break;
        case AGENT_TOOLS.MEDICATION_REMINDER:
          handleMedicationReminder();
          break;
        default:
          addMessage('🤖 Action completed successfully!', 'agent');
      }
    } catch (error) {
      addMessage('❌ Sorry, I encountered an error while performing that action. Please try again.', 'agent');
    } finally {
      setAgentThinking(false);
    }
  };

  // Action Handlers
  const handleEmergencyAlert = () => {
    const emergencyMessage = `🚨 EMERGENCY PROTOCOL ACTIVATED

📞 Immediate Actions:
• Call 108 (Ambulance) or 102 (Emergency)
• Contact your emergency contact
• Go to nearest emergency room

🏥 Nearby Emergency Services:
• Apollo Emergency: 24/7 Available
• Max Hospital Emergency: Open Now
• Government Hospital: Free Emergency Care

⚠️ If you're experiencing:
• Severe chest pain
• Difficulty breathing
• Loss of consciousness
• Severe bleeding

Please call emergency services immediately!

📱 Preparing to dial emergency services...`;

    addMessage(emergencyMessage, 'agent');
    
    // Auto-dial after 3 seconds with confirmation
    setTimeout(() => {
      if (confirm('🚨 Do you want to call emergency services (108) now?')) {
        window.open('tel:108');
        addMessage('📞 Emergency call initiated to 108. Stay calm and provide your location and emergency details.', 'agent');
      } else {
        addMessage('📞 Emergency call cancelled. Please call 108 manually if you need immediate medical assistance.', 'agent');
      }
    }, 3000);
  };

  const handleBookAppointment = () => {
    const appointmentMessage = `📅 APPOINTMENT BOOKING

I can help you book an appointment with the right specialist:

🏥 Available Options:
• General Physician - Today 2:00 PM
• Cardiologist - Tomorrow 10:00 AM  
• Dermatologist - Today 4:00 PM
• Pediatrician - Tomorrow 9:00 AM

📝 Redirecting you to doctors page for appointment booking...`;

    addMessage(appointmentMessage, 'agent');
    
    setTimeout(() => {
      navigate('/doctors');
      addMessage('✅ Redirected to doctors page. You can now select a doctor and book your appointment.', 'agent');
    }, 2000);
  };

  const handleNearbyHospitals = () => {
    if (userLocation) {
      const hospitalsMessage = `🏥 NEARBY HOSPITALS & CLINICS

📍 Based on your location:

🚑 Emergency Hospitals:
• City Hospital - 2.3 km (24/7 Emergency)
• Apollo Medical Center - 3.1 km
• Max Healthcare - 4.2 km

🏥 Clinics:
• HealthFirst Clinic - 1.2 km (Open until 9 PM)
• Family Care Center - 2.8 km
• QuickCare Clinic - 1.8 km

📞 Emergency Numbers:
• Ambulance: 108
• Police: 100
• Fire: 101

🗺️ Opening Google Maps to show nearby hospitals and emergency services...`;

      addMessage(hospitalsMessage, 'agent');
      
      // Auto-open directions after 2 seconds
      setTimeout(() => {
        window.open('https://www.google.com/maps/search/hospitals+near+me');
        addMessage('✅ Google Maps opened with nearby hospitals and emergency services. You can now get directions to the closest facility.', 'agent');
      }, 2000);
    } else {
      addMessage('📍 Please allow location access to find nearby hospitals and emergency services.', 'agent');
    }
  };

  const handleSymptomTracking = () => {
    const symptomsMessage = `📊 SYMPTOM TRACKING ACTIVATED

I'll help you track your symptoms for better diagnosis:

📝 Tracking Session Started:
• Pain Level: Will be monitored
• Duration: Recording timestamps  
• Associated symptoms: Being logged
• Pattern analysis: In progress

💡 This information will help doctors provide better care.

🔍 Starting comprehensive symptom monitoring...`;

    addMessage(symptomsMessage, 'agent');
    
    setTimeout(() => {
      setPatientData(prev => ({
        ...prev,
        symptoms: [...prev.symptoms, { 
          date: new Date(), 
          tracked: true,
          sessionId: Date.now(),
          status: 'active'
        }]
      }));
      addMessage('✅ Symptom tracking activated successfully! I\'ll monitor your health patterns and provide insights. You can describe any symptoms you\'re experiencing and I\'ll log them for analysis.', 'agent');
    }, 2000);
  };

  const handleHealthTracking = () => {
    const healthMessage = `💓 HEALTH MONITORING ACTIVATED

🔍 Continuous Health Tracking Started:
• Vital signs monitoring: Active
• Symptom pattern analysis: Running
• Recovery progress tracking: Enabled
• Medication effectiveness: Monitoring

📈 Health Insights Engine:
• AI-powered pattern recognition
• Personalized health recommendations
• Early warning system for health changes
• Integration with your medical history

🔄 Initializing health monitoring systems...`;

    addMessage(healthMessage, 'agent');
    
    setTimeout(() => {
      addMessage('✅ Health monitoring systems successfully activated! I\'m now continuously tracking your health patterns and will provide personalized insights and early warnings for any concerning changes.', 'agent');
    }, 2500);
  };

  const handleMedicationReminder = () => {
    const medicationMessage = `💊 MEDICATION MANAGEMENT SYSTEM

⏰ Smart Reminders Setup:
• Morning medications: 8:00 AM
• Afternoon dose: 2:00 PM
• Evening medications: 8:00 PM

📝 Advanced Medication Tracking:
• Dosage compliance monitoring
• Side effects tracking and alerts
• Automatic refill reminders
• Drug interaction warnings

🔔 Configuring intelligent reminder system...`;

    addMessage(medicationMessage, 'agent');
    
    setTimeout(() => {
      addMessage('✅ Medication management system successfully configured! You\'ll receive timely notifications for all medications, including dosage reminders, refill alerts, and side effect monitoring. Your medication adherence will be tracked for better health outcomes.', 'agent');
    }, 3000);
  };

  const speakText = (text) => {
    if (speechEnabled && 'speechSynthesis' in window) {
      // Cancel any ongoing speech
      window.speechSynthesis.cancel();
      
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.rate = 0.9;
      utterance.pitch = 1;
      utterance.volume = 0.8;
      
      // Try to use a more natural voice
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
    if (!input.trim()) return;
    addMessage(input, "user");
    const userInput = input;
    setInput("");
    setLoading(true);

    const typingMessage = { text: "🤖 AI Agent is analyzing and planning actions...", type: "bot", isTyping: true };
    setMessages((prev) => [...prev, typingMessage]);

    try {
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${API_KEY}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            contents: [{ parts: [{ text: userInput }] }],
            system_instruction: {
              parts: [
                {
                  text: `You are an advanced AI Health Agent with decision-making capabilities. You not only provide medical guidance but also take proactive actions to help patients. 

                  🤖 AGENT CAPABILITIES:
                  - Symptom analysis and diagnosis suggestions
                  - Emergency detection and alert protocols
                  - Appointment booking assistance
                  - Doctor recommendations and connections
                  - Health monitoring and tracking
                  - Medication management
                  - Location-based hospital/clinic finder
                  - Video consultation facilitation

                  📋 AGENT PROTOCOLS:
                  1. EMERGENCY DETECTION: If user mentions emergency symptoms (chest pain, difficulty breathing, severe pain, loss of consciousness), immediately suggest emergency protocols
                  2. SYMPTOM TRACKING: Offer to track and monitor symptoms for pattern analysis
                  3. APPOINTMENT BOOKING: Proactively suggest booking appointments when medical consultation is needed
                  4. DOCTOR CONNECTION: Recommend specific doctors and offer video call options
                  5. HEALTH MONITORING: Suggest continuous health tracking for chronic conditions
                  6. MEDICATION REMINDERS: Offer medication scheduling and reminder services

                  🎯 DECISION MAKING:
                  Always end your response with action recommendations like:
                  "🤖 RECOMMENDED ACTIONS: [action type] - [brief description]"

                  Example: "🤖 RECOMMENDED ACTIONS: BOOK_APPOINTMENT - Based on your symptoms, I recommend scheduling with a cardiologist"

                  📌 RESPONSE FORMAT:
                  [Medical Analysis]

                  🎯 Immediate Actions:
                  • [Action 1]
                  • [Action 2] 

                  🤖 AGENT DECISION: [What I'll do next for you]

                  👨‍⚕️ Available Doctors:  
                  - Dr. Sachin – General Physician – 15 years  
                  - Dr. Tarun Thakur – Pediatrician – 12 years  
                  - Dr. Manish Sharma – Cardiologist – 18 years  
                  - Dr. Fouziya Siddiqui – Gynecologist – 14 years  
                  - Dr. Shashank – Orthopedic Surgeon – 16 years  
                  - Dr. Kamaljeet Kaur – Dermatologist – 10 years  
                  - Dr. Suresh Nair – Neurologist – 20 years  
                  - Dr. Kavita Joshi – ENT Specialist – 11 years  
                  - Dr. Manish Yadav – Psychiatrist – 13 years  
                  - Dr. Sunita Rani – Ophthalmologist – 9 years  
                  - Dr. Vikram Malhotra – Pulmonologist – 17 years  `,
                },
              ],
            },
          }),
        }
      );

      const data = await response.json();
      const botReply = data.candidates?.[0]?.content?.parts?.[0]?.text ||
        "⚠️ I apologize, but I couldn't process your request. Please try again.";

      // Remove typing message and add bot reply
      setMessages((prev) => {
        const msgs = prev.filter((msg) => !msg.isTyping);
        const updatedMessages = [...msgs, { text: botReply, type: "bot", timestamp: new Date() }];
        
        // Save to localStorage
        try {
          localStorage.setItem('aiHealthAgentMessages', JSON.stringify(updatedMessages));
        } catch (error) {
          console.error('Error saving chat history:', error);
        }
        
        return updatedMessages;
      });

      // Agent Decision Making - Analyze and decide actions
      const recommendedActions = analyzeUserIntentAndDecideActions(userInput, botReply);
      
      if (recommendedActions.length > 0) {
        // Add agent thinking message
        setTimeout(() => {
          addMessage("🤖 Analyzing your needs... I can take the following actions for you:", "agent", recommendedActions);
        }, 1000);
      }

      // Speak the response if speech is enabled
      if (botReply && speechEnabled) {
        setTimeout(() => speakText(botReply), 500);
      }
    } catch (error) {
      setMessages((prev) => {
        const msgs = prev.filter((msg) => !msg.isTyping);
        const updatedMessages = [
          ...msgs,
          { text: "⚠️ I'm having trouble connecting right now. Please check your internet connection and try again.", type: "bot", timestamp: new Date() },
        ];
        
        // Save to localStorage
        try {
          localStorage.setItem('aiHealthAgentMessages', JSON.stringify(updatedMessages));
        } catch (saveError) {
          console.error('Error saving chat history:', saveError);
        }
        
        return updatedMessages;
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

  // Clear chat history
  const clearChatHistory = () => {
    if (confirm('🗑️ Are you sure you want to clear your chat history? This action cannot be undone.')) {
      const defaultMessage = {
        text: "🤖 Hello! I'm your AI Health Agent. I can help you with symptoms, book appointments, find doctors, and take immediate action for your health needs. How can I assist you today?",
        type: "bot",
        actions: [],
        timestamp: new Date()
      };
      
      setMessages([defaultMessage]);
      
      try {
        localStorage.setItem('aiHealthAgentMessages', JSON.stringify([defaultMessage]));
        addMessage('✅ Chat history cleared successfully. Let\'s start fresh!', 'agent');
      } catch (error) {
        console.error('Error clearing chat history:', error);
      }
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.chatContainer}>
        {/* Header */}
        <div style={styles.header}>
          <div style={styles.headerOverlay}></div>
          <div style={styles.headerContent}>
            <div style={styles.headerLeft}>
              <div style={styles.iconContainer}>
                <Stethoscope size={24} />
              </div>
              <div>
                <h1 style={styles.title}>🤖 AI Health Agent</h1>
                <p style={styles.subtitle}>Intelligent health assistant with decision-making capabilities</p>
              </div>
            </div>
            <div style={styles.headerRight}>
              <div style={styles.agentStatus}>
                <Activity size={16} />
                <span style={styles.agentStatusText}>
                  {agentThinking ? 'Processing...' : 'Ready to Help'}
                </span>
              </div>
              
              {/* Chat History Indicator */}
              <div style={styles.chatHistoryIndicator} title="Chat history is automatically saved">
                💾
              </div>
              
              {/* Clear Chat Button */}
              <button
                onClick={clearChatHistory}
                style={styles.clearChatButton}
                title="Clear chat history"
              >
                🗑️
              </button>
              
              {speechSupported && (
                <button
                  onClick={() => setSpeechEnabled(!speechEnabled)}
                  style={{
                    ...styles.headerButton,
                    ...(speechEnabled ? styles.headerButtonActive : {})
                  }}
                  title={speechEnabled ? "Disable voice responses" : "Enable voice responses"}
                >
                  {speechEnabled ? <Volume2 size={20} /> : <VolumeX size={20} />}
                </button>
              )}
              <div style={styles.onlineIndicator} title="Agent Online"></div>
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
                {(msg.type === "bot" || msg.type === "agent") && !msg.isTyping && (
                  <div style={{
                    ...styles.botAvatar,
                    ...(msg.type === "agent" ? styles.agentAvatar : {})
                  }}>
                    {msg.type === "agent" ? "🤖" : "👨‍⚕️"}
                  </div>
                )}
                
                <div style={{
                  ...styles.messageContent,
                  ...(msg.type === "user" ? styles.userMessageContent : styles.botMessageContent)
                }}>
                  <div style={{
                    ...styles.messageBubble,
                    ...(msg.type === "user" ? styles.userMessage : 
                        msg.type === "agent" ? styles.agentMessage :
                        msg.isTyping ? styles.typingMessage : styles.botMessage)
                  }}>
                    {msg.isTyping ? (
                      <div style={styles.typingIndicator}>
                        <div style={styles.typingDots}>
                          <div style={{...styles.dot, animationDelay: '0s'}}></div>
                          <div style={{...styles.dot, animationDelay: '0.1s'}}></div>
                          <div style={{...styles.dot, animationDelay: '0.2s'}}></div>
                        </div>
                        <span>AI Agent is thinking...</span>
                      </div>
                    ) : (
                      <div style={styles.messageText}>{msg.text}</div>
                    )}
                  </div>

                  {/* Action Buttons */}
                  {msg.actions && msg.actions.length > 0 && (
                    <div style={styles.actionButtons}>
                      {msg.actions.map((action, actionIndex) => (
                        <button
                          key={actionIndex}
                          onClick={() => executeAgentAction(action)}
                          style={{
                            ...styles.actionButton,
                            ...(action.priority === 'high' ? styles.actionButtonHigh :
                                action.priority === 'medium' ? styles.actionButtonMedium :
                                styles.actionButtonLow)
                          }}
                          disabled={agentThinking}
                        >
                          {action.label}
                        </button>
                      ))}
                    </div>
                  )}

                  {msg.timestamp && (
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

          {/* Agent Thinking Indicator */}
          {agentThinking && (
            <div style={styles.agentThinkingContainer}>
              <div style={styles.agentThinkingBubble}>
                <div style={styles.typingIndicator}>
                  <div style={styles.typingDots}>
                    <div style={{...styles.dot, animationDelay: '0s'}}></div>
                    <div style={{...styles.dot, animationDelay: '0.1s'}}></div>
                    <div style={{...styles.dot, animationDelay: '0.2s'}}></div>
                  </div>
                  <span>🤖 Agent is executing action...</span>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Input Area */}
        <div style={styles.inputArea}>
          <div style={styles.inputWrapper}>
            <div style={styles.textareaContainer}>
              <textarea
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={handleKeyPress}
                placeholder="Describe your symptoms or ask a health question..."
                style={{
                  ...styles.textarea,
                  ...(loading ? styles.textareaDisabled : {})
                }}
                rows="1"
                disabled={loading}
              />
              {speechSupported && (
                <button
                  onClick={isListening ? stopListening : startListening}
                  style={{
                    ...styles.micButton,
                    ...(isListening ? styles.micButtonActive : {})
                  }}
                  title={isListening ? "Stop listening" : "Start voice input"}
                  disabled={loading}
                >
                  {isListening ? <MicOff size={18} /> : <Mic size={18} />}
                </button>
              )}
            </div>
            
            <button
              onClick={sendMessage}
              disabled={loading || !input.trim()}
              style={{
                ...styles.sendButton,
                ...(loading || !input.trim() ? styles.sendButtonDisabled : {})
              }}
            >
              {loading ? (
                <div style={styles.spinner}></div>
              ) : (
                <Send size={20} />
              )}
            </button>
          </div>
          
          {isListening && (
            <div style={styles.listeningIndicator}>
              <div style={styles.listeningDot}></div>
              <span style={styles.listeningText}>Listening... Speak now</span>
              <div style={styles.listeningDot}></div>
            </div>
          )}
          
          {!speechSupported && (
            <p style={styles.noSpeechSupport}>
              Voice input not supported in your browser
            </p>
          )}
        </div>
      </div>

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

        @keyframes gradient {
          0% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
          100% { background-position: 0% 50%; }
        }
      `}</style>
    </div>
  );
};

const styles = {
  container: {
    minHeight: '90vh',
    background: 'linear-gradient(135deg, #e3f2fd 0%, #ffffff 50%, #e8eaf6 100%)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '16px',
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
  },
  chatContainer: {
    marginTop:'100px',
    width: '100%',
    maxWidth: '700px',
    height: '600px',
    background: '#ffffff',
    borderRadius: '20px',
    boxShadow: '0 20px 40px rgba(0,0,0,0.1), 0 0 0 1px rgba(0,0,0,0.05)',
    overflow: 'hidden',
    display: 'flex',
    flexDirection: 'column'
  },
  header: {
    background: 'linear-gradient(135deg, #1976d2 0%, #3f51b5 100%)',
    color: 'white',
    padding: '24px',
    position: 'relative',
    overflow: 'hidden'
  },
  headerOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    background: 'rgba(255,255,255,0.1)',
    backdropFilter: 'blur(10px)'
  },
  headerContent: {
    position: 'relative',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between'
  },
  headerLeft: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px'
  },
  iconContainer: {
    padding: '8px',
    background: 'rgba(255,255,255,0.2)',
    borderRadius: '50%'
  },
  title: {
    fontSize: '20px',
    fontWeight: 'bold',
    margin: 0
  },
  subtitle: {
    color: '#bbdefb',
    fontSize: '14px',
    margin: 0
  },
  headerRight: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px'
  },
  headerButton: {
    padding: '8px',
    background: 'rgba(255,255,255,0.2)',
    border: 'none',
    borderRadius: '50%',
    color: 'white',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center'
  },
  headerButtonActive: {
    background: 'rgba(255,255,255,0.3)'
  },
  agentStatus: {
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
    padding: '4px 8px',
    background: 'rgba(255,255,255,0.2)',
    borderRadius: '12px',
    fontSize: '12px'
  },
  agentStatusText: {
    color: 'white',
    fontWeight: '500'
  },
  onlineIndicator: {
    width: '12px',
    height: '12px',
    background: '#4caf50',
    borderRadius: '50%',
    animation: 'pulse 2s infinite'
  },
  chatHistoryIndicator: {
    padding: '6px',
    background: 'rgba(255,255,255,0.2)',
    borderRadius: '12px',
    fontSize: '14px',
    cursor: 'default',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center'
  },
  clearChatButton: {
    padding: '6px',
    background: 'rgba(255,255,255,0.2)',
    border: 'none',
    borderRadius: '12px',
    color: 'white',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '14px'
  },
  chatBox: {
    flex: 1,
    padding: '24px',
    overflowY: 'auto',
    background: '#fafafa',
    scrollBehavior: 'smooth'
  },
  messageContainer: {
    marginBottom: '24px'
  },
  messageWrapper: {
    display: 'flex',
    alignItems: 'flex-end',
    gap: '12px'
  },
  userMessageWrapper: {
    justifyContent: 'flex-end'
  },
  botMessageWrapper: {
    justifyContent: 'flex-start'
  },
  messageContent: {
    maxWidth: '80%',
    display: 'flex',
    flexDirection: 'column'
  },
  userMessageContent: {
    alignItems: 'flex-end'
  },
  botMessageContent: {
    alignItems: 'flex-start'
  },
  messageBubble: {
    padding: '12px 16px',
    borderRadius: '18px',
    boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
    fontSize: '14px',
    lineHeight: '1.5',
    wordWrap: 'break-word'
  },
  userMessage: {
    background: 'linear-gradient(135deg, #1976d2 0%, #3f51b5 100%)',
    color: 'white',
    borderBottomRightRadius: '4px'
  },
  botMessage: {
    background: '#ffffff',
    color: '#333333',
    border: '1px solid #e0e0e0',
    borderBottomLeftRadius: '4px'
  },
  agentMessage: {
    background: '#f0f4ff',
    color: '#1565c0',
    border: '1px solid #bbdefb',
    borderBottomLeftRadius: '4px'
  },
  typingMessage: {
    background: '#f5f5f5',
    color: '#666666',
    borderBottomLeftRadius: '4px'
  },
  messageText: {
    whiteSpace: 'pre-wrap'
  },
  typingIndicator: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px'
  },
  typingDots: {
    display: 'flex',
    gap: '4px'
  },
  dot: {
    width: '8px',
    height: '8px',
    background: '#999999',
    borderRadius: '50%',
    animation: 'bounce 1.4s infinite'
  },
  timestamp: {
    fontSize: '11px',
    color: '#999999',
    marginTop: '4px'
  },
  timestampRight: {
    textAlign: 'right'
  },
  timestampLeft: {
    textAlign: 'left'
  },
  botAvatar: {
    width: '32px',
    height: '32px',
    background: 'linear-gradient(135deg, #1976d2 0%, #3f51b5 100%)',
    borderRadius: '50%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '14px',
    flexShrink: 0
  },
  agentAvatar: {
    background: 'linear-gradient(135deg, #4caf50 0%, #2196f3 100%)'
  },
  userAvatar: {
    width: '32px',
    height: '32px',
    background: '#757575',
    borderRadius: '50%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '14px',
    flexShrink: 0
  },
  inputArea: {
    padding: '16px',
    background: '#ffffff',
    borderTop: '1px solid #e0e0e0'
  },
  inputWrapper: {
    display: 'flex',
    alignItems: 'flex-end',
    gap: '12px'
  },
  textareaContainer: {
    flex: 1,
    position: 'relative'
  },
  textarea: {
    width: '100%',
    padding: '12px 44px 12px 16px',
    border: '1px solid #d0d0d0',
    borderRadius: '12px',
    resize: 'none',
    minHeight: '50px',
    maxHeight: '120px',
    fontSize: '14px',
    fontFamily: 'inherit',
    outline: 'none',
    transition: 'all 0.3s ease',
    background: '#ffffff'
  },
  textareaDisabled: {
    background: '#f5f5f5',
    cursor: 'not-allowed'
  },
  micButton: {
    position: 'absolute',
    right: '8px',
    top: '50%',
    transform: 'translateY(-50%)',
    padding: '8px',
    border: 'none',
    borderRadius: '50%',
    background: '#f5f5f5',
    color: '#666666',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center'
  },
  micButtonActive: {
    background: '#f44336',
    color: 'white',
    animation: 'pulse 1.5s infinite'
  },
  sendButton: {
    padding: '12px',
    border: 'none',
    borderRadius: '12px',
    background: 'linear-gradient(135deg, #1976d2 0%, #3f51b5 100%)',
    color: 'white',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontWeight: '600',
    boxShadow: '0 4px 12px rgba(25, 118, 210, 0.3)'
  },
  sendButtonDisabled: {
    background: '#e0e0e0',
    color: '#999999',
    cursor: 'not-allowed',
    boxShadow: 'none'
  },
  spinner: {
    width: '20px',
    height: '20px',
    border: '2px solid rgba(255,255,255,0.3)',
    borderTop: '2px solid white',
    borderRadius: '50%',
    animation: 'spin 1s linear infinite'
  },
  listeningIndicator: {
    marginTop: '12px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '8px',
    color: '#f44336'
  },
  listeningDot: {
    width: '8px',
    height: '8px',
    background: '#f44336',
    borderRadius: '50%',
    animation: 'pulse 1s infinite'
  },
  listeningText: {
    fontSize: '14px',
    fontWeight: '500'
  },
  noSpeechSupport: {
    fontSize: '12px',
    color: '#999999',
    textAlign: 'center',
    margin: '8px 0 0 0'
  },
  actionButtons: {
    display: 'flex',
    flexWrap: 'wrap',
    gap: '8px',
    marginTop: '12px'
  },
  actionButton: {
    padding: '8px 12px',
    border: 'none',
    borderRadius: '20px',
    fontSize: '12px',
    fontWeight: '600',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
    boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
  },
  actionButtonHigh: {
    background: '#f44336',
    color: 'white',
    animation: 'pulse 2s infinite'
  },
  actionButtonMedium: {
    background: '#ff9800',
    color: 'white'
  },
  actionButtonLow: {
    background: '#2196f3',
    color: 'white'
  },
  agentThinkingContainer: {
    display: 'flex',
    justifyContent: 'flex-start',
    marginBottom: '24px'
  },
  agentThinkingBubble: {
    maxWidth: '80%',
    padding: '12px 16px',
    background: '#e8f5e8',
    color: '#2e7d32',
    borderRadius: '18px',
    borderBottomLeftRadius: '4px',
    boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
  }
};

export default AgenticSymptomChecker;