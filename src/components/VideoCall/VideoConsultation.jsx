import React, { useState, useEffect, useRef } from 'react';
import { 
  Video, 
  VideoOff, 
  Mic, 
  MicOff, 
  PhoneOff, 
  Settings, 
  MessageSquare, 
  FileText, 
  Clock,
  User,
  Phone,
  Monitor,
  Camera,
  Volume2
} from 'lucide-react';
import { useLanguage } from '../../context/LanguageContext';

const VideoConsultation = ({ doctor, onEndCall, isCallActive }) => {
  const { t } = useLanguage();
  const [isVideoEnabled, setIsVideoEnabled] = useState(true);
  const [isAudioEnabled, setIsAudioEnabled] = useState(true);
  const [isScreenSharing, setIsScreenSharing] = useState(false);
  const [showChat, setShowChat] = useState(false);
  const [chatMessages, setChatMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [callDuration, setCallDuration] = useState(0);
  const [connectionStatus, setConnectionStatus] = useState('connecting');
  
  const localVideoRef = useRef(null);
  const remoteVideoRef = useRef(null);
  const localStreamRef = useRef(null);
  const chatRef = useRef(null);

  // Timer for call duration
  useEffect(() => {
    let interval;
    if (isCallActive && connectionStatus === 'connected') {
      interval = setInterval(() => {
        setCallDuration(prev => prev + 1);
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [isCallActive, connectionStatus]);

  // Initialize video stream
  useEffect(() => {
    if (isCallActive) {
      initializeVideoCall();
      // Simulate connection establishment
      setTimeout(() => setConnectionStatus('connected'), 2000);
    }
    return () => {
      if (localStreamRef.current) {
        localStreamRef.current.getTracks().forEach(track => track.stop());
      }
    };
  }, [isCallActive]);

  const initializeVideoCall = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: true,
        audio: true
      });
      
      localStreamRef.current = stream;
      if (localVideoRef.current) {
        localVideoRef.current.srcObject = stream;
      }
    } catch (error) {
      console.error('Error accessing media devices:', error);
      setConnectionStatus('error');
    }
  };

  const toggleVideo = () => {
    if (localStreamRef.current) {
      const videoTrack = localStreamRef.current.getVideoTracks()[0];
      if (videoTrack) {
        videoTrack.enabled = !isVideoEnabled;
        setIsVideoEnabled(!isVideoEnabled);
      }
    }
  };

  const toggleAudio = () => {
    if (localStreamRef.current) {
      const audioTrack = localStreamRef.current.getAudioTracks()[0];
      if (audioTrack) {
        audioTrack.enabled = !isAudioEnabled;
        setIsAudioEnabled(!isAudioEnabled);
      }
    }
  };

  const toggleScreenShare = async () => {
    try {
      if (!isScreenSharing) {
        const screenStream = await navigator.mediaDevices.getDisplayMedia({
          video: true,
          audio: true
        });
        if (localVideoRef.current) {
          localVideoRef.current.srcObject = screenStream;
        }
        setIsScreenSharing(true);
        
        screenStream.getVideoTracks()[0].onended = () => {
          setIsScreenSharing(false);
          initializeVideoCall();
        };
      } else {
        initializeVideoCall();
        setIsScreenSharing(false);
      }
    } catch (error) {
      console.error('Error sharing screen:', error);
    }
  };

  const sendMessage = () => {
    if (newMessage.trim()) {
      const message = {
        id: Date.now(),
        text: newMessage,
        sender: 'patient',
        timestamp: new Date()
      };
      setChatMessages(prev => [...prev, message]);
      setNewMessage('');
      
      // Simulate doctor response
      setTimeout(() => {
        const doctorMessage = {
          id: Date.now() + 1,
          text: "Thank you for your message. I'll address this during our consultation.",
          sender: 'doctor',
          timestamp: new Date()
        };
        setChatMessages(prev => [...prev, doctorMessage]);
      }, 2000);
    }
  };

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleEndCall = () => {
    if (localStreamRef.current) {
      localStreamRef.current.getTracks().forEach(track => track.stop());
    }
    onEndCall();
  };

  if (!isCallActive) return null;

  return (
    <div style={styles.container}>
      {/* Header */}
      <div style={styles.header}>
        <div style={styles.doctorInfo}>
          <img 
            src={doctor?.image || 'https://via.placeholder.com/40'} 
            alt={doctor?.name} 
            style={styles.doctorAvatar}
          />
          <div>
            <h3 style={styles.doctorName}>{doctor?.name}</h3>
            <p style={styles.doctorSpecialty}>{doctor?.specialization}</p>
          </div>
        </div>
        
        <div style={styles.callInfo}>
          <div style={styles.callStatus}>
            <div style={{
              ...styles.statusDot,
              backgroundColor: connectionStatus === 'connected' ? '#10b981' : '#f59e0b'
            }}></div>
            <span style={styles.statusText}>
              {connectionStatus === 'connected' ? 'Connected' : 'Connecting...'}
            </span>
          </div>
          {connectionStatus === 'connected' && (
            <div style={styles.callDuration}>
              <Clock size={16} />
              <span>{formatTime(callDuration)}</span>
            </div>
          )}
        </div>
      </div>

      {/* Video Area */}
      <div style={styles.videoContainer}>
        {/* Remote Video (Doctor) */}
        <div style={styles.remoteVideo}>
          <video
            ref={remoteVideoRef}
            style={styles.video}
            autoPlay
            playsInline
            poster="https://via.placeholder.com/800x600/059669/ffffff?text=Dr.+Video"
          />
          <div style={styles.remoteVideoOverlay}>
            <div style={styles.remoteVideoInfo}>
              <span style={styles.remoteVideoLabel}>Dr. {doctor?.name}</span>
              <div style={styles.remoteVideoControls}>
                <Volume2 size={16} color="white" />
                <Video size={16} color="white" />
              </div>
            </div>
          </div>
        </div>

        {/* Local Video (Patient) */}
        <div style={styles.localVideo}>
          <video
            ref={localVideoRef}
            style={styles.video}
            autoPlay
            playsInline
            muted
          />
          {!isVideoEnabled && (
            <div style={styles.videoDisabledOverlay}>
              <User size={24} color="white" />
            </div>
          )}
          <div style={styles.localVideoLabel}>You</div>
        </div>

        {/* Connection Status Overlay */}
        {connectionStatus !== 'connected' && (
          <div style={styles.connectionOverlay}>
            <div style={styles.connectionLoader}></div>
            <p style={styles.connectionText}>
              {connectionStatus === 'connecting' ? 'Connecting to doctor...' : 'Connection failed'}
            </p>
          </div>
        )}
      </div>

      {/* Controls */}
      <div style={styles.controls}>
        <button
          onClick={toggleAudio}
          style={{
            ...styles.controlButton,
            backgroundColor: isAudioEnabled ? '#374151' : '#ef4444'
          }}
          title={isAudioEnabled ? 'Mute microphone' : 'Unmute microphone'}
        >
          {isAudioEnabled ? <Mic size={20} /> : <MicOff size={20} />}
        </button>

        <button
          onClick={toggleVideo}
          style={{
            ...styles.controlButton,
            backgroundColor: isVideoEnabled ? '#374151' : '#ef4444'
          }}
          title={isVideoEnabled ? 'Turn off camera' : 'Turn on camera'}
        >
          {isVideoEnabled ? <Video size={20} /> : <VideoOff size={20} />}
        </button>

        <button
          onClick={toggleScreenShare}
          style={{
            ...styles.controlButton,
            backgroundColor: isScreenSharing ? '#059669' : '#374151'
          }}
          title={isScreenSharing ? 'Stop sharing' : 'Share screen'}
        >
          <Monitor size={20} />
        </button>

        <button
          onClick={() => setShowChat(!showChat)}
          style={{
            ...styles.controlButton,
            backgroundColor: showChat ? '#059669' : '#374151'
          }}
          title="Toggle chat"
        >
          <MessageSquare size={20} />
        </button>

        <button
          onClick={handleEndCall}
          style={{
            ...styles.controlButton,
            backgroundColor: '#ef4444'
          }}
          title="End call"
        >
          <PhoneOff size={20} />
        </button>
      </div>

      {/* Chat Panel */}
      {showChat && (
        <div style={styles.chatPanel}>
          <div style={styles.chatHeader}>
            <h4 style={styles.chatTitle}>Consultation Chat</h4>
            <button
              onClick={() => setShowChat(false)}
              style={styles.chatCloseButton}
            >
              ×
            </button>
          </div>
          
          <div style={styles.chatMessages} ref={chatRef}>
            {chatMessages.map(message => (
              <div
                key={message.id}
                style={{
                  ...styles.chatMessage,
                  ...(message.sender === 'patient' ? styles.patientMessage : styles.doctorMessage)
                }}
              >
                <div style={styles.messageText}>{message.text}</div>
                <div style={styles.messageTime}>
                  {message.timestamp.toLocaleTimeString([], { 
                    hour: '2-digit', 
                    minute: '2-digit' 
                  })}
                </div>
              </div>
            ))}
          </div>
          
          <div style={styles.chatInput}>
            <input
              type="text"
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
              placeholder="Type a message..."
              style={styles.messageInput}
            />
            <button onClick={sendMessage} style={styles.sendButton}>
              Send
            </button>
          </div>
        </div>
      )}

      {/* Call Quality Indicator */}
      <div style={styles.qualityIndicator}>
        <div style={styles.qualityBars}>
          <div style={{...styles.qualityBar, backgroundColor: '#10b981'}}></div>
          <div style={{...styles.qualityBar, backgroundColor: '#10b981'}}></div>
          <div style={{...styles.qualityBar, backgroundColor: '#10b981'}}></div>
          <div style={{...styles.qualityBar, backgroundColor: '#d1d5db'}}></div>
        </div>
        <span style={styles.qualityText}>Good</span>
      </div>
    </div>
  );
};

const styles = {
  container: {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#1f2937',
    zIndex: 9999,
    display: 'flex',
    flexDirection: 'column',
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
  },

  header: {
    padding: '16px 24px',
    backgroundColor: '#111827',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderBottom: '1px solid #374151',
  },

  doctorInfo: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
  },

  doctorAvatar: {
    width: '48px',
    height: '48px',
    borderRadius: '50%',
    objectFit: 'cover',
  },

  doctorName: {
    color: 'white',
    fontSize: '18px',
    fontWeight: '600',
    margin: 0,
  },

  doctorSpecialty: {
    color: '#9ca3af',
    fontSize: '14px',
    margin: 0,
  },

  callInfo: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
  },

  callStatus: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
  },

  statusDot: {
    width: '8px',
    height: '8px',
    borderRadius: '50%',
  },

  statusText: {
    color: 'white',
    fontSize: '14px',
  },

  callDuration: {
    display: 'flex',
    alignItems: 'center',
    gap: '4px',
    color: '#10b981',
    fontSize: '14px',
    fontWeight: '600',
  },

  videoContainer: {
    flex: 1,
    position: 'relative',
    backgroundColor: '#000',
  },

  remoteVideo: {
    width: '100%',
    height: '100%',
    position: 'relative',
  },

  localVideo: {
    position: 'absolute',
    top: '20px',
    right: '20px',
    width: '200px',
    height: '150px',
    borderRadius: '8px',
    overflow: 'hidden',
    border: '2px solid #059669',
    backgroundColor: '#374151',
  },

  video: {
    width: '100%',
    height: '100%',
    objectFit: 'cover',
  },

  remoteVideoOverlay: {
    position: 'absolute',
    bottom: '16px',
    left: '16px',
    right: '16px',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  remoteVideoInfo: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
  },

  remoteVideoLabel: {
    color: 'white',
    fontSize: '16px',
    fontWeight: '600',
    textShadow: '0 2px 4px rgba(0,0,0,0.5)',
  },

  remoteVideoControls: {
    display: 'flex',
    gap: '8px',
  },

  localVideoLabel: {
    position: 'absolute',
    bottom: '8px',
    left: '8px',
    color: 'white',
    fontSize: '12px',
    fontWeight: '600',
    textShadow: '0 1px 2px rgba(0,0,0,0.5)',
  },

  videoDisabledOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#374151',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  connectionOverlay: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    textAlign: 'center',
  },

  connectionLoader: {
    width: '40px',
    height: '40px',
    border: '4px solid #374151',
    borderTop: '4px solid #059669',
    borderRadius: '50%',
    animation: 'spin 1s linear infinite',
    margin: '0 auto 16px',
  },

  connectionText: {
    color: 'white',
    fontSize: '16px',
  },

  controls: {
    padding: '20px',
    backgroundColor: '#111827',
    display: 'flex',
    justifyContent: 'center',
    gap: '16px',
    borderTop: '1px solid #374151',
  },

  controlButton: {
    width: '52px',
    height: '52px',
    borderRadius: '50%',
    border: 'none',
    color: 'white',
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    transition: 'all 0.2s ease',
  },

  chatPanel: {
    position: 'absolute',
    top: '80px',
    right: '20px',
    width: '300px',
    height: '400px',
    backgroundColor: 'white',
    borderRadius: '8px',
    boxShadow: '0 10px 25px rgba(0,0,0,0.2)',
    display: 'flex',
    flexDirection: 'column',
    overflow: 'hidden',
  },

  chatHeader: {
    padding: '16px',
    backgroundColor: '#059669',
    color: 'white',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  chatTitle: {
    margin: 0,
    fontSize: '16px',
    fontWeight: '600',
  },

  chatCloseButton: {
    background: 'none',
    border: 'none',
    color: 'white',
    fontSize: '20px',
    cursor: 'pointer',
    padding: '0',
    width: '24px',
    height: '24px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  chatMessages: {
    flex: 1,
    padding: '16px',
    overflowY: 'auto',
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
  },

  chatMessage: {
    maxWidth: '80%',
    padding: '8px 12px',
    borderRadius: '16px',
    fontSize: '14px',
  },

  patientMessage: {
    alignSelf: 'flex-end',
    backgroundColor: '#059669',
    color: 'white',
  },

  doctorMessage: {
    alignSelf: 'flex-start',
    backgroundColor: '#f3f4f6',
    color: '#1f2937',
  },

  messageText: {
    marginBottom: '4px',
  },

  messageTime: {
    fontSize: '11px',
    opacity: 0.7,
  },

  chatInput: {
    padding: '16px',
    borderTop: '1px solid #e5e7eb',
    display: 'flex',
    gap: '8px',
  },

  messageInput: {
    flex: 1,
    padding: '8px 12px',
    border: '1px solid #d1d5db',
    borderRadius: '20px',
    fontSize: '14px',
    outline: 'none',
  },

  sendButton: {
    padding: '8px 16px',
    backgroundColor: '#059669',
    color: 'white',
    border: 'none',
    borderRadius: '20px',
    cursor: 'pointer',
    fontSize: '14px',
    fontWeight: '600',
  },

  qualityIndicator: {
    position: 'absolute',
    top: '20px',
    left: '20px',
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    backgroundColor: 'rgba(0,0,0,0.7)',
    padding: '8px 12px',
    borderRadius: '16px',
    color: 'white',
    fontSize: '12px',
  },

  qualityBars: {
    display: 'flex',
    gap: '2px',
  },

  qualityBar: {
    width: '3px',
    height: '12px',
    borderRadius: '2px',
  },

  qualityText: {
    fontWeight: '600',
  },
};

export default VideoConsultation;