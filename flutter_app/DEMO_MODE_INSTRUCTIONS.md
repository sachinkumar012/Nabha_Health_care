# ABHA Demo Mode - Quick Start Guide

## 🎯 Demo Mode is Now Active!

The ABHA integration is currently running in **DEMO MODE**, which means you can test the complete UI flow without needing real ABDM API credentials.

## ✅ What Works in Demo Mode

You can now test the complete ABHA creation flow:

### Create ABHA ID Flow:
1. **Open the app** → Navigate to ABHA from menu
2. **Tap "Create ABHA ID"**
3. **Step 1 - Enter Aadhaar**: Enter any 12-digit number (e.g., `999544796286`)
4. **Tap "Send OTP"** → Wait 2 seconds (simulating network call)
5. **Step 2 - Enter OTP**: Type ANY 6-digit number (e.g., `123456`)
6. **Tap "Verify OTP"** → OTP will be accepted
7. **Step 3 - Mobile Number**: Enter any mobile number
8. **Tap "Send OTP"**
9. **Step 4 - Enter Mobile OTP**: Type ANY 6-digit number
10. **Tap "Verify OTP"**
11. **Step 5 - Create ABHA Address**: 
    - Enter username (e.g., `demouser123`)
    - Optional: Add email and password
12. **Tap "Create ABHA ID"**
13. **Success!** → View your demo ABHA card

### Link Existing ABHA Flow:
1. **Tap "Link Existing ABHA ID"**
2. **Option A - Using ABHA Address**:
   - Enter any ABHA address (e.g., `existing@abdm`)
   - Enter any password
   - Tap "Link ABHA"
   - Success! ABHA linked

3. **Option B - Using Aadhaar**:
   - Similar OTP flow as creation

## 📝 Demo Mode Behavior

| Feature | Demo Mode Behavior |
|---------|-------------------|
| **Aadhaar OTP** | Accepts ANY 6-digit OTP |
| **Mobile OTP** | Accepts ANY 6-digit OTP |
| **ABHA Address Check** | All addresses show as "available" |
| **ABHA Creation** | Returns mock ABHA card |
| **ABHA Linking** | Returns mock linked card |
| **Network Delays** | 1-2 second delays to simulate real API |

## 🔧 Switching to Real ABDM APIs

When you're ready to use real ABDM integration:

1. Open: `lib/src/features/abha/services/abha_service.dart`
2. Find line ~13: `static const bool demoMode = true;`
3. Change to: `static const bool demoMode = false;`
4. Add your ABDM credentials:
   ```dart
   static const String clientId = 'YOUR_ACTUAL_CLIENT_ID';
   static const String clientSecret = 'YOUR_ACTUAL_CLIENT_SECRET';
   ```

## 📚 Full Integration Guide

For complete ABDM integration steps, real credentials, and production setup:
👉 See: [`ABHA_INTEGRATION_GUIDE.md`](./ABHA_INTEGRATION_GUIDE.md)

## 🎨 UI Features Implemented

✅ Beautiful 5-step progress indicator  
✅ Aadhaar number input with validation  
✅ OTP input with auto-focus  
✅ Countdown timer for resend OTP  
✅ Mobile number input  
✅ ABHA address availability check  
✅ Email and password fields  
✅ ABHA card display with all details  
✅ Error handling and loading states  
✅ Success animations  

## 🚀 Next Steps

1. **Test the complete flow** in demo mode
2. **Register for ABDM sandbox** access
3. **Get your credentials** from ABDM portal
4. **Update the service** with real credentials
5. **Test with real Aadhaar** numbers
6. **Go to production!**

---

**Happy Testing! 🎉**

*Note: Demo mode logs all actions to console for debugging. Check the Flutter logs to see what's happening behind the scenes.*
