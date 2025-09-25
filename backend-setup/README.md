# Nabha Healthcare - Chat Storage Backend

This backend service provides persistent chat storage for the AI Health Agent.

## Features

✅ **Persistent Chat Storage** - Stores chat history in JSON files  
✅ **Session Management** - Each user gets a unique session ID  
✅ **CORS Enabled** - Ready for frontend integration  
✅ **Cloud Deploy Ready** - Works on Vercel, Railway, Render, etc.  
✅ **Fallback Support** - Frontend falls back to localStorage if backend fails

## API Endpoints

### `POST /api/chat/save`

Save chat messages for a session

```json
{
  "sessionId": "user_12345_abc",
  "messages": [...],
  "timestamp": "2025-01-01T00:00:00Z"
}
```

### `GET /api/chat/load?sessionId=user_12345_abc`

Load chat messages for a session

### `POST /api/chat/clear`

Clear chat history for a session

```json
{
  "sessionId": "user_12345_abc"
}
```

### `GET /api/health`

Health check endpoint

## Local Development

```bash
cd backend-setup
npm install
npm run dev
```

Backend will run on `http://localhost:3001`

## Production Deployment

### Option 1: Vercel (Recommended)

1. Push your backend code to GitHub
2. Connect to Vercel
3. Deploy automatically
4. Update `BACKEND_CONFIG.API_BASE_URL` in frontend

### Option 2: Railway

1. Connect GitHub repo to Railway
2. Deploy with one click
3. Get your production URL
4. Update frontend config

### Option 3: Render

1. Connect GitHub repo
2. Set up web service
3. Deploy and get URL
4. Update frontend config

### Option 4: Traditional VPS

```bash
# On your server
git clone your-repo
cd backend-setup
npm install
npm start
```

## Environment Variables

For production, set these in your deployment platform:

```bash
NODE_ENV=production
PORT=3001
```

## Security Notes

⚠️ **For Production Use:**

- Add authentication if needed
- Rate limiting for API calls
- Data encryption for sensitive health data
- Regular backups of chat data
- GDPR compliance for user data

## File Structure

```
backend-setup/
├── server.js         # Main server file
├── package.json      # Dependencies
├── chat-data/        # Auto-created storage folder
└── README.md         # This file
```

## Integration with Frontend

The frontend automatically detects production environment and uses backend API. In development, it falls back to localStorage.

**Frontend Config in SymptomChecker.jsx:**

```javascript
const BACKEND_CONFIG = {
  API_BASE_URL:
    process.env.NODE_ENV === "production"
      ? "https://your-backend-url.com/api" // ← Update this!
      : "http://localhost:3001/api",
};
```

## Testing

Test your deployed backend:

```bash
# Health check
curl https://your-backend-url.com/api/health

# Save test chat
curl -X POST https://your-backend-url.com/api/chat/save \
  -H "Content-Type: application/json" \
  -d '{"sessionId":"test_123","messages":[{"text":"Hello","type":"user"}]}'

# Load test chat
curl "https://your-backend-url.com/api/chat/load?sessionId=test_123"
```

## Success! 🎉

Once deployed, your AI Health Agent will:

- Save chats to cloud storage in production
- Maintain chat history across browser sessions
- Work offline with localStorage fallback
- Sync data when backend is available
