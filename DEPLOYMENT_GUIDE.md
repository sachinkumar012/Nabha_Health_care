# WebRTC Video Call Production Deployment Guide

## Problem
Your video calls work locally but fail on Vercel because:
1. WebRTC requires a signaling server for peer connection
2. Production needs TURN servers for NAT traversal
3. HTTPS is required for WebRTC in production
4. The current code uses localhost which doesn't work in production

## Solution Steps

### Step 1: Deploy the Signaling Server

**Option A: Deploy to Heroku (Recommended)**
1. Install Heroku CLI: https://devcenter.heroku.com/articles/heroku-cli
2. Navigate to the server folder:
   ```bash
   cd server
   ```
3. Initialize Git and deploy:
   ```bash
   git init
   git add .
   git commit -m "Initial signaling server"
   heroku create nabha-healthcare-signaling
   git push heroku main
   ```

**Option B: Deploy to Railway**
1. Go to https://railway.app
2. Create new project from GitHub
3. Connect your repository
4. Select the `server` folder as root
5. Deploy automatically

**Option C: Deploy to Render**
1. Go to https://render.com
2. Create new Web Service
3. Connect your repository
4. Set root directory to `server`
5. Build command: `npm install`
6. Start command: `npm start`

### Step 2: Update Vercel Environment Variables

1. Go to your Vercel dashboard
2. Select your project: nabha-health-care-two
3. Go to Settings → Environment Variables
4. Add this variable:
   - Name: `REACT_APP_SOCKET_SERVER`
   - Value: `https://your-signaling-server-url.herokuapp.com` (replace with your actual server URL)
5. Redeploy your frontend

### Step 3: Test the Video Calls

1. Open your deployed website: https://nabha-health-care-two.vercel.app/
2. Navigate to Doctors page
3. Try starting a video call
4. The video calls should now work in production

## Technical Details

### What We Fixed:
1. **Environment-based server URLs**: The app now uses `REACT_APP_SOCKET_SERVER` environment variable
2. **TURN servers**: Added free TURN servers for NAT traversal
3. **Complete signaling server**: Created a full Socket.IO server with room management
4. **CORS configuration**: Properly configured for your Vercel domain

### Files Modified:
- `src/services/VideoCallService.js` - Updated with production-ready WebRTC config
- `server/index.js` - Complete signaling server implementation
- `server/package.json` - Server dependencies
- `.env` and `.env.production` - Environment configuration

### Server Features:
- Room management for video calls
- Doctor availability tracking
- WebRTC signaling (offer/answer/ICE candidates)
- CORS support for your frontend domain

## Troubleshooting

If video calls still don't work:
1. Check browser console for errors
2. Verify the signaling server is accessible
3. Make sure HTTPS is working (required for WebRTC)
4. Test with different browsers/devices

## Cost Considerations
- Heroku: Free tier available (with sleep after 30 min inactivity)
- Railway: Free tier with limited hours
- Render: Free tier available
- TURN servers: Using free openrelay.metered.ca (limited but should work for testing)

## Next Steps After Deployment
1. Monitor server logs for any issues
2. Consider upgrading to paid TURN servers for production use
3. Add error handling and reconnection logic
4. Implement user authentication for video calls