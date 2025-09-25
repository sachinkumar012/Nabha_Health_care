import React, { useState, useRef, useEffect } from "react";
import { Mic, MicOff, Send, Volume2, VolumeX, Calendar, X, MessageCircle } from "lucide-react";

const API_KEY = "AIzaSyBEoyP49AjxnE6pTLhEivfNAylcGDaH_04"; // Replace with your key

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

  useEffect(() => {
    // Initialize with language selection message
    if (isOpen && !languageSelected && messages.length === 0) {
      addMessage(LANGUAGES[currentLanguage].initialMessage, 'bot');
      // Add language selection buttons
      setTimeout(() => {
        addMessage(LANGUAGES[currentLanguage].selectLanguage, 'bot');
      }, 500);
    }
  }, [isOpen, languageSelected, messages.length]);

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
    
    // Clear previous messages and add confirmation
    setMessages([]);
    addMessage(`${LANGUAGES[langCode].flag} ${LANGUAGES[langCode].name} selected!`, 'user');
    
    setTimeout(() => {
      addMessage(LANGUAGES[langCode].languageSelected, 'bot');
    }, 500);
    
    // Update speech recognition language
    if (recognition) {
      recognition.lang = LANGUAGES[langCode].speechLang;
    }
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

    const typingMessage = { text: "Assistant is processing...", type: "bot", isTyping: true };
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
                  text: `You are a helpful AI assistant for Nabha Healthcare, specializing in appointment booking and scheduling. Help users book appointments, provide information about available doctors, suggest appointment times, and guide them through the booking process.

                  IMPORTANT: Respond in ${LANGUAGES[currentLanguage].name} language. Be culturally sensitive and use appropriate greetings and expressions for this language.

                  Available Doctors:
                  - Dr. Sachin Kumar – General Medicine – 15 years – Available: 9:00 AM - 6:00 PM
                  - Dr. Tarun Thakur – Pediatrics – 12 years – Available: 6:00 AM - 4:00 PM  
                  - Dr. Manish Sharma – Cardiology – 18 years – Available: 9:00 AM - 5:00 PM
                  - Dr. Fouziya Siddiqui – Gynecology – 20 years – Available: 11:00 AM - 7:00 PM
                  - Dr. Shashank – Orthopaedics – 18 years – Available: 9:00 AM - 5:00 PM
                  - Dr. Kamaljeet Kaur – Dermatology – 18 years – Available: 9:00 AM - 5:00 PM

                  Guidelines:
                  1. Ask about their preferred doctor or medical concern
                  2. Suggest suitable doctors based on their needs
                  3. Provide available time slots
                  4. Ask for patient details (name, phone, date preference)
                  5. Confirm appointment details
                  6. Provide WhatsApp contact for final confirmation

                  Always be helpful, professional, and guide them step by step through the booking process.
                  Use emojis and formatting to make responses clear and friendly.`,
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
          }
          
          .mobile-close-button:hover {
            background-color: rgba(0, 0, 0, 0.9) !important;
            transform: scale(1.05);
          }
          
          /* Desktop Close Button - Hide on mobile */
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

            {/* Language Selection - Show only when language not selected */}
            {!languageSelected && (
              <div style={styles.languageSelection} className="language-selection-mobile">
                <div style={styles.languageWelcome}>
                  <div style={styles.languageIcon} className="language-icon-mobile">🌐</div>
                  <div style={styles.languageWelcomeText}>
                    <h3 style={styles.languageWelcomeTitle} className="language-welcome-title-mobile">Welcome to Nabha Healthcare</h3>
                    <p style={styles.languageWelcomeSubtitle}>Please select your preferred language</p>
                  </div>
                </div>
                
                <div style={styles.languageGrid} className="language-grid-mobile">
                  {Object.entries(LANGUAGES).map(([langCode, lang]) => (
                    <div
                      key={langCode}
                      onClick={() => handleLanguageSelect(langCode)}
                      className="language-card language-card-mobile"
                      style={styles.languageCard}
                    >
                      <div style={styles.languageFlagLarge}>{lang.flag}</div>
                      <div style={styles.languageCardContent}>
                        <div style={styles.languageNameLarge} className="language-name-large-mobile">{lang.name}</div>
                        <div style={styles.languageSelectText}>Click to select</div>
                      </div>
                      <div className="language-arrow" style={styles.languageArrow}>→</div>
                    </div>
                  ))}
                </div>
                
                <div style={styles.languageFooter}>
                  <p style={styles.languageFooterText}>
                    <span style={styles.languageFooterIcon}>💬</span>
                    Chat with our AI assistant in your preferred language
                  </p>
                </div>
              </div>
            )}

            {/* Chat Messages */}
            <div ref={chatBoxRef} style={styles.chatBox}>
              {messages.map((msg, index) => (
                <div key={index} style={styles.messageContainer}>
                  <div style={{
                    ...styles.messageWrapper,
                    ...(msg.type === "user" ? styles.userMessageWrapper : styles.botMessageWrapper)
                  }}>
                    {msg.type === "bot" && !msg.isTyping && (
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
                        ) : (
                          <div style={styles.messageText}>{msg.text}</div>
                        )}
                      </div>
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
    top: '8px',
    left: '8px',
    zIndex: 10,
    background: 'rgba(0, 0, 0, 0.7)',
    border: 'none',
    color: 'white',
    cursor: 'pointer',
    padding: '6px',
    borderRadius: '50%',
    transition: 'background-color 0.2s',
    display: 'none', // Hidden by default, shown on mobile via CSS
    alignItems: 'center',
    justifyContent: 'center',
    width: '32px',
    height: '32px',
    boxShadow: '0 2px 8px rgba(0,0,0,0.3)',
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
};

export default AppointmentChatBot;