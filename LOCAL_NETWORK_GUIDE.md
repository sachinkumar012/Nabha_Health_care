# How to Test Video Calls on Local Network

## Steps to Allow Others to Join Your Video Call:

### 1. 🔍 Find Your Local IP Address

**On Windows:**

```cmd
ipconfig
```

Look for "IPv4 Address" under your WiFi adapter (e.g., 192.168.1.100)

**On Mac/Linux:**

```bash
ifconfig | grep inet
```

### 2. 🌐 Start Your App with Network Access

Instead of just `npm run dev`, use:

```bash
# For Vite (your current setup)
npm run dev -- --host

# Or manually specify your IP
npm run dev -- --host 0.0.0.0
```

This will show:

```
Local:   http://localhost:3000
Network: http://192.168.1.100:3000
```

### 3. 📱 Share the Network URL

Send the **Network URL** (e.g., `http://192.168.1.100:3000`) to others on the same WiFi network.

### 4. 🎯 Generate Video Call Links

When you click "Video Call" on a doctor, the generated link will be:

```
http://192.168.1.100:3000/video-call/instant-1-xyz123
```

Others can open this link on their devices if they're on the same network.

## ⚠️ Important Notes:

1. **Same Network Only**: Others must be on the same WiFi/network
2. **Firewall**: Windows/Mac firewall might block access
3. **HTTPS**: Some browser features need HTTPS (use ngrok for that)

## 🛠️ Troubleshooting:

### If others can't access:

1. **Disable Firewall** temporarily
2. **Check Router Settings** - some routers block inter-device communication
3. **Use Phone Hotspot** as a test network

### If video/audio doesn't work:

1. **Use HTTPS** (see ngrok solution below)
2. **Check Browser Permissions**
3. **Try Chrome** (best WebRTC support)
