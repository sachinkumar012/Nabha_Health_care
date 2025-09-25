import React, { useState, useRef, useEffect } from "react";
import { Mic, MicOff, Send, Volume2, VolumeX, Calendar, X, MessageCircle } from "lucide-react";

const API_KEY = "AIzaSyBEoyP49AjxnE6pTLhEivfNAylcGDaH_04"; // Replace with your key

const 
AppointmentChatBot = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState([
    { text: "Hello! I'm here to help you book an appointment with our doctors. What type of consultation do you need?", type: "bot" }
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [isListening, setIsListening] = useState(false);
  const [speechEnabled, setSpeechEnabled] = useState(false);
  const [recognition, setRecognition] = useState(null);
  const [speechSupported, setSpeechSupported] = useState(false);
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
  }, []);

  const addMessage = (text, type) => {
    setMessages((prev) => [...prev, { text, type, timestamp: new Date() }]);
    setTimeout(() => {
      if (chatBoxRef.current) {
        chatBoxRef.current.scrollTop = chatBoxRef.current.scrollHeight;
      }
    }, 50);
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
    if (!input.trim()) return;
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
      `}</style>

      {/* Chat Toggle Button */}
      <div className="chatbot-toggle" style={styles.chatToggle} onClick={toggleChat}>
        {isOpen ? <X size={24} /> : <MessageCircle size={24} />}
        {!isOpen && <div style={styles.notificationBadge}>💬</div>}
      </div>

      {/* Chat Window */}
      {isOpen && (
        <div className="chatbot-window appointment-chat-window" style={styles.chatWindow}>
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
                  <button onClick={toggleChat} style={styles.closeButton}>
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
                    placeholder="Type your appointment request..."
                    style={{
                      ...styles.textarea,
                      ...(loading ? styles.textareaDisabled : {})
                    }}
                    className="appointment-textarea"
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
                  disabled={loading || !input.trim()}
                  style={{
                    ...styles.sendButton,
                    ...(loading || !input.trim() ? styles.sendButtonDisabled : {})
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
                  <span style={styles.listeningText}>Listening...</span>
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
};

export default AppointmentChatBot;