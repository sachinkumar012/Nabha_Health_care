# Deployment Instructions for Chat Storage

## Quick Deploy Options

### 1. 🚀 Vercel (Easiest - Recommended)

**Step 1:** Push backend to GitHub

```bash
git add backend-setup/
git commit -m "Add chat storage backend"
git push
```

**Step 2:** Deploy to Vercel

1. Go to [vercel.com](https://vercel.com)
2. Connect your GitHub repository
3. Set **Root Directory** to `backend-setup`
4. Deploy!

**Step 3:** Update Frontend
In `SymptomChecker.jsx`, replace:

```javascript
API_BASE_URL: process.env.NODE_ENV === 'production'
  ? 'https://your-vercel-url.vercel.app/api'  // ← Your Vercel URL
```

### 2. 🚄 Railway

**Step 1:** Connect Repository

1. Go to [railway.app](https://railway.app)
2. "New Project" → "Deploy from GitHub repo"
3. Select your repository

**Step 2:** Configure Service

- Set **Root Directory**: `backend-setup`
- Railway auto-detects Node.js
- Deploy automatically!

**Step 3:** Get URL and Update Frontend
Copy your Railway URL and update frontend config.

### 3. 🎯 Render

**Step 1:** Create Web Service

1. Go to [render.com](https://render.com)
2. "New" → "Web Service"
3. Connect GitHub repo

**Step 2:** Configure

- **Root Directory**: `backend-setup`
- **Build Command**: `npm install`
- **Start Command**: `npm start`

### 4. 💰 Free Alternatives

**Heroku** (if you have credits)
**PlanetScale** (database option)
**Supabase** (database + API)
**Firebase** (Google's platform)

## Testing Deployment

After deployment, test these URLs:

```bash
# Health check
https://your-deployed-url.com/api/health

# Test in browser
https://your-deployed-url.com/api/chat/sessions
```

## Update Frontend

Once backend is deployed, update this line in `SymptomChecker.jsx`:

```javascript
// Line ~8 in SymptomChecker.jsx
API_BASE_URL: process.env.NODE_ENV === 'production'
  ? 'https://YOUR-ACTUAL-BACKEND-URL.com/api'  // ← Replace this!
  : 'http://localhost:3001/api',
```

## Examples of URLs:

- **Vercel**: `https://your-app-name.vercel.app/api`
- **Railway**: `https://your-app-name.railway.app/api`
- **Render**: `https://your-app-name.onrender.com/api`

## Success Indicators ✅

**Backend Working:**

- Health check returns `{"status":"healthy"}`
- Chat save/load endpoints respond
- No CORS errors in browser

**Frontend Working:**

- Chat history persists after page refresh
- ☁️ icon shows in header (production)
- "Welcome back" message on return visits
- Chat survives navigation between pages

## Troubleshooting

**CORS Issues:**

- Make sure backend URL is correct
- Check browser developer console

**Chat Not Saving:**

- Check Network tab for API calls
- Verify backend health endpoint
- Ensure sessionId is generated

**Need Help?**

1. Check browser console for errors
2. Test backend endpoints individually
3. Verify environment detection (dev vs production)

---

**🎉 Once deployed, your AI Health Agent will have persistent cloud storage!**
