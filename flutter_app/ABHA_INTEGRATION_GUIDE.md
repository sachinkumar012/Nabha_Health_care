# ABHA Integration Guide

## Overview
This guide explains how to integrate with ABDM (Ayushman Bharat Digital Mission) to enable real OTP generation for ABHA ID creation.

## Current Status
⚠️ **The app is currently using ABDM Sandbox URLs but needs valid credentials to work.**

## Steps to Get Real OTP Working

### 1. Register with ABDM

#### For Testing (Sandbox Access)
1. Visit the ABDM Sandbox Portal: https://sandbox.abdm.gov.in/
2. Register your organization/application
3. Complete the registration form with:
   - Organization details
   - Developer details
   - Application purpose
4. Wait for approval (usually 2-3 business days)
5. Once approved, you'll receive:
   - **Client ID** (e.g., SBX_002777)
   - **Client Secret** (secret key)

#### For Production
1. Visit: https://ndhm.gov.in/
2. Complete the Health ID Provider registration
3. Submit required documents and KYC
4. Get production credentials after approval

### 2. Update the App with Your Credentials

Open the file: `lib/src/features/abha/services/abha_service.dart`

Replace these lines (around line 13-14):
```dart
static const String clientId = 'SBX_002777';  // Replace with YOUR Client ID
static const String clientSecret = 'your_client_secret';  // Replace with YOUR Client Secret
```

### 3. API Endpoints Used

The app uses these ABDM Sandbox APIs:

- **Generate Aadhaar OTP**: `POST /v2/registration/aadhaar/generateOtp`
- **Verify Aadhaar OTP**: `POST /v2/registration/aadhaar/verifyOTP`
- **Generate Mobile OTP**: `POST /v2/registration/mobile/generateOtp`
- **Verify Mobile OTP**: `POST /v2/registration/mobile/verifyOTP`
- **Create ABHA ID**: `POST /v2/registration/abha/createAbhaId`
- **Link ABHA by Number**: `POST /v2/account/profile/link/aadhar`

### 4. Testing with Sandbox

ABDM provides test Aadhaar numbers for sandbox testing:

#### Test Aadhaar Numbers (Sandbox Only)
| Aadhaar Number | OTP (Fixed) |
|----------------|-------------|
| 999999999999   | 123456      |
| 888888888888   | 654321      |

**Note**: These work ONLY in sandbox environment after you get valid credentials.

### 5. How the OTP Flow Works

```
Step 1: User enters Aadhaar Number
   ↓
Step 2: App calls ABDM API → /generateOtp
   ↓
Step 3: ABDM sends OTP to Aadhaar-linked mobile
   ↓
Step 4: User enters OTP
   ↓
Step 5: App verifies OTP → /verifyOTP
   ↓
Step 6: Continue with ABHA creation
```

### 6. Backend Requirements (Optional)

For production apps, it's recommended to:

1. **Store credentials securely on backend server**
2. **Create proxy APIs** that call ABDM from your server
3. **Don't expose Client Secret in mobile app**

Example Backend Setup:
```javascript
// Node.js Express example
const express = require('express');
const axios = require('axios');

app.post('/api/abha/generate-aadhaar-otp', async (req, res) => {
  try {
    // Get access token from ABDM
    const tokenResponse = await axios.post(
      'https://healthidsbx.abdm.gov.in/api/v1/auth/generateToken',
      {
        clientId: process.env.ABDM_CLIENT_ID,
        clientSecret: process.env.ABDM_CLIENT_SECRET
      }
    );
    
    const accessToken = tokenResponse.data.accessToken;
    
    // Generate OTP
    const otpResponse = await axios.post(
      'https://healthidsbx.abdm.gov.in/api/v2/registration/aadhaar/generateOtp',
      { aadhaar: req.body.aadhaar },
      { headers: { 'Authorization': `Bearer ${accessToken}` } }
    );
    
    res.json(otpResponse.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### 7. Quick Start for Testing

**Option A: Use Backend Proxy (Recommended)**
1. Set up a backend server with ABDM credentials
2. Update `baseUrl` in `abha_service.dart` to your backend:
   ```dart
   static const String baseUrl = 'https://your-backend.com/api/abha';
   ```

**Option B: Direct Integration (For Testing Only)**
1. Get ABDM sandbox credentials
2. Update `clientId` and `clientSecret` in the code
3. Test with sandbox Aadhaar numbers

### 8. Error Handling

Common errors you might see:

| Error | Cause | Solution |
|-------|-------|----------|
| "Failed to authenticate with ABDM" | Invalid credentials | Check Client ID/Secret |
| "Invalid Aadhaar" | Wrong Aadhaar format | Must be 12 digits |
| "OTP generation failed" | Network/API issue | Check internet, retry |
| "Invalid OTP" | Wrong OTP entered | Re-enter correct OTP |

### 9. Production Checklist

Before going live:
- [ ] Get production ABDM credentials
- [ ] Update to production URLs
- [ ] Set up backend proxy server
- [ ] Store credentials in environment variables
- [ ] Implement proper error logging
- [ ] Add rate limiting
- [ ] Test with real Aadhaar numbers
- [ ] Comply with ABDM security guidelines

### 10. Resources

- **ABDM Developer Portal**: https://sandbox.abdm.gov.in/
- **ABDM Documentation**: https://sandbox.abdm.gov.in/docs
- **API Reference**: https://sandbox.abdm.gov.in/swagger/ndhm-hip.yaml
- **Support Email**: support@nha.gov.in

## Current Implementation

The app already has:
✅ Complete UI for ABHA creation (5-step process)
✅ Aadhaar OTP flow
✅ Mobile OTP verification
✅ ABHA ID creation
✅ Link existing ABHA ID
✅ ABHA card display

**What's Missing**: Valid ABDM API credentials

## Next Steps

1. **Immediate** (to fix the current error):
   - Set up a backend proxy server with ABDM credentials
   - Update `baseUrl` to point to your backend

2. **Short-term**:
   - Register for ABDM sandbox access
   - Test with sandbox credentials

3. **Long-term**:
   - Apply for production access
   - Complete security audit
   - Deploy to production

---

**Note**: For security reasons, never commit actual Client ID/Secret to version control. Use environment variables or secure storage.
