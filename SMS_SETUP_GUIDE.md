# SMS Setup Guide for Nabha Healthcare 📱

Your appointment chatbot is currently running in **DEMO MODE** because no SMS API keys are configured. To receive real SMS messages instead of demo notifications, follow these steps:

## 🚀 Quick Setup Options

### Option 1: Fast2SMS (Recommended for India) 🇮🇳

1. **Sign up**: Visit https://www.fast2sms.com/
2. **Free Credits**: Get ₹100 free credits (about 1000 SMS)
3. **Get API Key**: 
   - Go to Developer API section
   - Copy your API key

**Configuration:**
```javascript
// In AppointmentChatBot.jsx, update SMS_CONFIG:
FAST2SMS: {
  API_KEY: 'your_actual_fast2sms_api_key_here',  // Replace this!
  API_URL: 'https://www.fast2sms.com/dev/bulkV2',
  SENDER_ID: 'FSTSMS'
}
```

### Option 2: TextLocal (Global) 🌍

1. **Sign up**: Visit https://www.textlocal.in/
2. **Free Trial**: Get free trial credits
3. **Get API Key**: 
   - Dashboard → Settings → API Keys
   - Create new API key

**Configuration:**
```javascript
// In AppointmentChatBot.jsx, update SMS_CONFIG:
TEXTLOCAL: {
  API_KEY: 'your_actual_textlocal_api_key_here',  // Replace this!
  API_URL: 'https://api.textlocal.in/send/',
  SENDER: 'TXTLCL'
}
```

### Option 3: MSG91 (India) 🇮🇳

1. **Sign up**: Visit https://msg91.com/
2. **Get API Key**: Dashboard → API Keys
3. **Create Template**: Required for transactional SMS

**Configuration:**
```javascript
// In AppointmentChatBot.jsx, update SMS_CONFIG:
MSG91: {
  API_KEY: 'your_actual_msg91_api_key_here',  // Replace this!
  API_URL: 'https://api.msg91.com/api/v5/flow/',
  SENDER_ID: 'MSG91',
  TEMPLATE_ID: 'your_template_id_here'  // Required for MSG91
}
```

## 🔧 How to Enable Real SMS

1. **Choose a service** from the options above
2. **Sign up and get your API key**
3. **Open your project** in VS Code
4. **Edit the file**: `src/components/AppointmentChatBot.jsx`
5. **Find the SMS_CONFIG section** (around line 20-60)
6. **Replace the placeholder API key** with your real API key
7. **Set DEMO_MODE to false**:

```javascript
const SMS_CONFIG = {
  DEMO_MODE: false,  // Change this to false!
  // ... rest of your config
};
```

8. **Save the file** and test your appointment booking

## 📞 Testing Your Setup

1. **Book an appointment** using your chatbot
2. **Use your real phone number**
3. **Check that you receive the SMS** within 1-2 minutes
4. **Verify the message content** is properly formatted

## 🆘 Troubleshooting

### Still Getting Demo Messages?
- ✅ Check that `DEMO_MODE: false`
- ✅ Verify your API key is correct (no extra spaces)
- ✅ Make sure you have sufficient credits in your SMS account
- ✅ Check browser console for error messages

### SMS Not Received?
- ✅ Verify phone number format (should be with country code: +91XXXXXXXXXX for India)
- ✅ Check if the SMS service is working (test in their dashboard)
- ✅ Ensure your account is verified with the SMS provider
- ✅ Check spam/junk folder on your phone

### Error Messages?
- ✅ Check the browser console (F12) for detailed error logs
- ✅ Verify API endpoints are correct
- ✅ Check if your SMS service requires additional parameters

## 💡 Recommendations

**For Indian Users**: Fast2SMS or MSG91
**For Global Users**: TextLocal or Twilio
**For High Volume**: MSG91 or Twilio (paid but reliable)

## 🔒 Security Note

- Never commit real API keys to public repositories
- Consider using environment variables for production
- Regularly rotate your API keys

---

**Need Help?** Check the browser console (F12) when testing - it will show detailed logs of the SMS sending process!

## Current Status: 
✅ Multi-language support (English, Hindi, Punjabi)
✅ Agentic AI conversation flow  
✅ Mobile-responsive design
✅ SMS integration architecture ready
⏳ **Waiting for real SMS API keys to activate live messaging**