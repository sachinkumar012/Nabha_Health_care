# 🎥 Complete Video Call Testing Setup

## 🎯 Quick Start Guide

### Prerequisites:

1. **Two devices/browsers** (your computer + friend's computer/phone)
2. **Same WiFi network** OR **Internet access via ngrok**
3. **Webcam & microphone** on both devices

## 🌐 Option 1: Internet Access with ngrok (RECOMMENDED)

### Step 1: Install ngrok

```powershell
# Download from: https://ngrok.com/download
# Or install via npm:
npm install -g ngrok
```

### Step 2: Get ngrok Auth Token

1. Sign up at https://ngrok.com/signup
2. Copy your auth token from dashboard
3. Run: `ngrok authtoken YOUR_TOKEN`

### Step 3: Start Your Apps

#### Terminal 1 - Start React App

```powershell
cd "e:\PROJECTS\Nabha_Health_care"
npm run dev
```

#### Terminal 2 - Start Signaling Server

```powershell
cd "e:\PROJECTS\Nabha_Health_care\server"
npm install
npm start
```

#### Terminal 3 - Expose React App

```powershell
ngrok http 3000
```

#### Terminal 4 - Expose Signaling Server

```powershell
ngrok http 3001
```

### Step 4: Configure Environment

Update your `.env` file:

```env
# Use your ngrok signaling server URL
REACT_APP_SOCKET_SERVER=https://YOUR-NGROK-SIGNALING-URL.ngrok.io
```

### Step 5: Share & Test

1. Share your React app ngrok URL: `https://YOUR-REACT-URL.ngrok.io`
2. Both users open the same URL
3. Navigate to **Doctors** page
4. Click **Video Call** on any doctor
5. Share the generated video call link with the other person
6. Both should connect and see each other!

---

## 🏠 Option 2: Local Network (Same WiFi)

### Step 1: Find Your IP Address

```powershell
ipconfig
```

Look for `IPv4 Address` (usually 192.168.x.x)

### Step 2: Start Your Apps with Network Access

```powershell
# Terminal 1 - React App
npm run dev -- --host 0.0.0.0

# Terminal 2 - Signaling Server
cd server
npm start
```

### Step 3: Update Environment

```env
# Use your local IP
REACT_APP_SOCKET_SERVER=http://192.168.1.X:3001
```

### Step 4: Test

1. **You**: Open `http://192.168.1.X:3000`
2. **Friend**: Open the same URL on their device (same WiFi)
3. Test the video calls!

---

## 🎮 Testing the Video Call Flow

### For Patient (Call Initiator):

1. Go to **Doctors** page: `/doctors`
2. Click **Video Call** button on any doctor card
3. **VideoCallLink modal** opens with call link
4. Copy the call link: `http://localhost:3000/video-call/call-abc123`
5. Send link to your friend (the "doctor")

### For Doctor (Call Receiver):

1. Open the video call link sent by patient
2. You'll join as the doctor in the call
3. Both should see video streams and can chat

### Expected Flow:

```
Patient clicks "Video Call"
   ↓
VideoCallLink modal opens
   ↓
Generates unique call room ID
   ↓
Patient shares link with Doctor
   ↓
Doctor opens link
   ↓
VideoCallRoom component loads
   ↓
Both users connect via WebRTC
   ↓
Video call starts! 🎉
```

---

## 🐛 Troubleshooting

### Issue: "Cannot connect to socket server"

**Solution:** Make sure signaling server is running on port 3001

### Issue: "Camera not working"

**Solution:** Grant camera/microphone permissions in browser

### Issue: "Other person can't connect"

**Solution:** Check if you're using the same network or ngrok URLs

### Issue: "No video/audio"

**Solution:**

- Check browser permissions
- Try in Chrome/Firefox (Safari has issues)
- Make sure both users have camera/mic

### Issue: "Call room not found"

**Solution:** Make sure both users are using the exact same call link

---

## 🔧 Technical Architecture

Your video call system uses:

- **Frontend**: React with VideoCallRoom component
- **Signaling**: Socket.IO server for WebRTC coordination
- **WebRTC**: For peer-to-peer video/audio streams
- **TURN Servers**: For NAT traversal (already configured)

The flow:

1. Patient creates call → generates room ID
2. Socket.IO coordinates connection setup
3. WebRTC establishes direct peer-to-peer connection
4. Video/audio streams directly between users

---

## ⚡ Next Steps:

1. Try ngrok method first (easiest for testing)
2. Test with a friend on different networks
3. Deploy signaling server to production for live testing
4. Consider adding call notifications for better UX
