import  { useState, useRef, useEffect } from "react";
import { Mic, MicOff, Send, Volume2, VolumeX, Stethoscope } from "lucide-react";

const API_KEY = "AIzaSyBEoyP49AjxnE6pTLhEivfNAylcGDaH_04"; // Replace with your key

const Chatbot = () => {
  const [messages, setMessages] = useState([
    { text: "Hello! I'm your AI Doctor assistant. How can I help you today?", type: "bot" }
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

    const typingMessage = { text: "Doctor is analyzing...", type: "bot", isTyping: true };
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
                  text: `You are a helpful, empathetic AI Doctor assistant. Provide clear, professional medical guidance while being warm and reassuring. Always remind users to consult with healthcare professionals for serious concerns. Keep responses concise but thorough.
                  📌 EXAMPLE RESPONSE (English):  

Most likely: You are experiencing a fever, which is often a sign of an infection.

Try These: 
🛌 Get plenty of rest. 
💧 Drink lots of fluids like water and juice. 
🔥 Keep a cool compress on your forehead. 
🍲 Eat light and easily digestible food. 

Pay Attention If: 
Your fever is very high (over 103°F or 39.4°C), doesn't come down with medication, or is accompanied by severe headache, stiff neck, or difficulty breathing. 

You may consult: Dr. Rajesh Sharma – General Physician – 15 years  

📌 EXAMPLE RESPONSE (Hindi):  

अधिक संभावना है: आपको बुखार है, जो अक्सर संक्रमण का लक्षण होता है।  

ध्यान रखें:  
🛌 पर्याप्त आराम करें।  
💧 खूब पानी और तरल पदार्थ पिएँ।  
🔥 माथे पर ठंडी पट्टी रखें।  
🍲 हल्का और सुपाच्य भोजन करें।  

डॉक्टर से मिलें यदि:  
बुखार बहुत तेज़ है (103°F से अधिक), दवा लेने के बाद भी नहीं उतर रहा है, या साथ में तेज़ सिरदर्द, गर्दन अकड़न, या साँस लेने में कठिनाई हो रही है।  

आप सलाह ले सकते हैं: डॉ. सचिन – सामान्य चिकित्सक – 15 वर्ष का अनुभव
👨‍⚕️ Doctor List (translate specialization + years into the user’s language when replying):  
- Dr. Sachin – General Physician – 15 years  
- Dr. Tarun Thakur – Pediatrician x – 12 years  
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
      setMessages((prev) => {
        const msgs = prev.filter((msg) => !msg.isTyping);
        const botReply =
          data.candidates?.[0]?.content?.parts?.[0]?.text ||
          "⚠️ I apologize, but I couldn't process your request. Please try again.";
        return [...msgs, { text: botReply, type: "bot", timestamp: new Date() }];
      });

      // Speak the response if speech is enabled
      const botReply = data.candidates?.[0]?.content?.parts?.[0]?.text;
      if (botReply && speechEnabled) {
        setTimeout(() => speakText(botReply), 500);
      }
    } catch (error) {
      setMessages((prev) => {
        const msgs = prev.filter((msg) => !msg.isTyping);
        return [
          ...msgs,
          { text: "⚠️ I'm having trouble connecting right now. Please check your internet connection and try again.", type: "bot" },
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
                <h1 style={styles.title}>AI Doctor Assistant</h1>
                <p style={styles.subtitle}>Your personal health companion</p>
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
                  {speechEnabled ? <Volume2 size={20} /> : <VolumeX size={20} />}
                </button>
              )}
              <div style={styles.onlineIndicator} title="Online"></div>
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
                  <div style={styles.botAvatar}>👨‍⚕️</div>
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
                        <span>Doctor is analyzing...</span>
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
    backgroundColor: '#ffffff',
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
  onlineIndicator: {
    width: '12px',
    height: '12px',
    backgroundColor: '#4caf50',
    borderRadius: '50%',
    animation: 'pulse 2s infinite'
  },
  chatBox: {
    flex: 1,
    padding: '24px',
    overflowY: 'auto',
    backgroundColor: '#fafafa',
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
    backgroundColor: '#ffffff',
    color: '#333333',
    border: '1px solid #e0e0e0',
    borderBottomLeftRadius: '4px'
  },
  typingMessage: {
    backgroundColor: '#f5f5f5',
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
    backgroundColor: '#999999',
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
  userAvatar: {
    width: '32px',
    height: '32px',
    backgroundColor: '#757575',
    borderRadius: '50%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '14px',
    flexShrink: 0
  },
  inputArea: {
    padding: '16px',
    backgroundColor: '#ffffff',
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
    backgroundColor: '#ffffff'
  },
  textareaDisabled: {
    backgroundColor: '#f5f5f5',
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
    backgroundColor: '#f5f5f5',
    color: '#666666',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center'
  },
  micButtonActive: {
    backgroundColor: '#f44336',
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
    backgroundColor: '#e0e0e0',
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
    backgroundColor: '#f44336',
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
  }
};

export default Chatbot;