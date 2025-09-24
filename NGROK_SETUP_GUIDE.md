# Using ngrok to Share Your Local Video Call App

## 🚀 What is ngrok?
ngrok creates a secure tunnel from the internet to your localhost, allowing anyone to access your local app via a public URL.

## 📦 Installation & Setup:

### 1. Install ngrok
**Download from:** https://ngrok.com/download

**Or install via npm:**
```bash
npm install -g ngrok
```

### 2. Sign up for ngrok account
- Go to https://ngrok.com/signup
- Get your auth token from the dashboard

### 3. Setup Auth Token
```bash
ngrok authtoken YOUR_AUTH_TOKEN
```

## 🎯 Running Your App with ngrok:

### Step 1: Start Your React App
```bash
cd "e:\PROJECTS\Nabha_Health_care"
npm run dev
```
Your app runs on `http://localhost:3000`

### Step 2: Start ngrok Tunnel (New Terminal)
```bash
ngrok http 3000
```

### Step 3: Get Public URLs
ngrok will show:
```
Session Status    online
Web Interface     http://127.0.0.1:4040
Forwarding        https://abc123.ngrok.io -> http://localhost:3000
Forwarding        http://abc123.ngrok.io -> http://localhost:3000
```

### Step 4: Share the HTTPS URL
Share `https://abc123.ngrok.io` with others - they can access your app from anywhere!

## 🎮 Testing Video Calls:

1. **You**: Open `https://abc123.ngrok.io`
2. **Friend**: Open the same `https://abc123.ngrok.io`
3. **Start Call**: You click "Video Call" on any doctor
4. **Join Call**: Share the generated video call link with your friend
5. **Both Connect**: Both users can now video chat!

## 🌟 Benefits of ngrok:
- ✅ **Internet Access**: Anyone can join from anywhere
- ✅ **HTTPS**: Works with all browser features
- ✅ **Easy Setup**: Just one command
- ✅ **Free Tier**: Available for testing

## ⚠️ Important for Video Calls:

### Update Your Environment Variable:
When using ngrok, update your `.env` file:

```env
# Use your ngrok HTTPS URL as the base
REACT_APP_SOCKET_SERVER=https://abc123.ngrok.io

# Comment out production server
# REACT_APP_SOCKET_SERVER=https://your-socket-server.herokuapp.com
```

### Start Local Signaling Server:
You also need to run your signaling server locally:

```bash
# Terminal 1: React App
npm run dev

# Terminal 2: Signaling Server  
cd server
npm install
npm start

# Terminal 3: ngrok for React App
ngrok http 3000

# Terminal 4: ngrok for Signaling Server (if needed)
ngrok http 3001
```

## 🎯 Complete Test Flow:

1. Start React app: `npm run dev`
2. Start ngrok: `ngrok http 3000` 
3. Share ngrok URL with friend
4. Both open the ngrok URL
5. You: Go to Doctors → Click "Video Call"
6. Copy the generated video call link
7. Send link to friend
8. Both users should connect and see each other!

## 🆓 Free vs Paid ngrok:

**Free Tier:**
- Random URLs (changes each restart)
- 1 tunnel at a time
- Limited bandwidth

**Paid Tier:**
- Custom domains
- Multiple tunnels
- Better performance