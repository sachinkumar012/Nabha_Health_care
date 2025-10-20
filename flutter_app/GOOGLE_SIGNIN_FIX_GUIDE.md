# 🔧 Google Sign-In Error Fix Guide

## ❌ Problem Identified
The Google Sign-In is failing because of incomplete Firebase and Google Console configuration. The error "Google Sign-In failed. Please try again." typically indicates:

1. **Missing or incorrect SHA-1 fingerprints**
2. **Incorrect package name configuration**
3. **Incomplete OAuth consent screen setup**
4. **Wrong Firebase project configuration**

## ✅ Step-by-Step Fix

### Step 1: Get Your App's SHA-1 Fingerprint

**For Debug Build (Development):**
```bash
cd android
./gradlew signingReport
```

Look for the SHA-1 fingerprint under `Variant: debug` and `Config: debug`. It will look like:
```
SHA1: A1:B2:C3:D4:E5:F6:...
```

**Alternative method (if above doesn't work):**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Step 2: Configure Firebase Console

1. **Go to [Firebase Console](https://console.firebase.google.com/)**
2. **Select your project: `nabha-healthcare-c5c80`**
3. **Go to Project Settings** (gear icon)
4. **Select "Your Apps" tab**
5. **Find your Android app** or create one if it doesn't exist
6. **Add SHA-1 fingerprint:**
   - Click "Add fingerprint"
   - Paste your SHA-1 from Step 1
   - Save

### Step 3: Configure Google Cloud Console

1. **Go to [Google Cloud Console](https://console.cloud.google.com/)**
2. **Select your project**
3. **Go to APIs & Services → Credentials**
4. **Create OAuth 2.0 Client ID** (if not exists):
   - Application type: Android
   - Package name: `com.example.nabha_healthcare`
   - SHA-1 certificate fingerprint: (from Step 1)

### Step 4: Update OAuth Consent Screen

1. **In Google Cloud Console**
2. **Go to APIs & Services → OAuth consent screen**
3. **Configure the consent screen:**
   - App name: Nabha Healthcare
   - User support email: your email
   - Developer contact: your email
4. **Add scopes:** email, profile
5. **Add test users** (your Gmail accounts for testing)

### Step 5: Download Updated config files

1. **In Firebase Console → Project Settings**
2. **Download `google-services.json`**
3. **Replace the file at:**
   ```
   android/app/google-services.json
   ```

### Step 6: Verify Package Name

**Check `android/app/build.gradle.kts`:**
```kotlin
android {
    namespace = "com.example.nabha_healthcare"
    defaultConfig {
        applicationId = "com.example.nabha_healthcare"
        // ...
    }
}
```

### Step 7: Test the Setup

1. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Check debug output** when testing Google Sign-In
3. **Look for detailed error messages** in the new error reporting

## 🔍 Enhanced Error Reporting

I've updated the Google Sign-In code to provide detailed error information:

- ✅ **Better error categorization**
- ✅ **Technical details for debugging**
- ✅ **Specific guidance for common issues**
- ✅ **Error dialog with full error details**

## 🚨 Common Issues & Solutions

### Issue 1: "sign_in_failed" Error
**Solution:** SHA-1 fingerprint not added or incorrect
- Verify SHA-1 in Firebase Console
- Make sure you're using the debug keystore SHA-1

### Issue 2: "developer_error" 
**Solution:** OAuth consent screen not configured
- Complete OAuth consent screen setup
- Add your Gmail as test user

### Issue 3: "network_error"
**Solution:** Check internet connection and Firebase reachability

### Issue 4: Firebase not initialized
**Solution:** Check main.dart has proper Firebase initialization

## 📋 Verification Checklist

- [ ] SHA-1 fingerprint added to Firebase
- [ ] OAuth consent screen configured
- [ ] Test users added to OAuth consent
- [ ] Package name matches in all configs
- [ ] google-services.json downloaded and placed correctly
- [ ] App rebuilt after configuration changes

## 🎯 Next Steps

1. **Follow the steps above** to configure Firebase and Google Console
2. **Test with your actual Gmail account**
3. **Check the enhanced error messages** for specific issues
4. **Contact me if you need help** with any specific step

The enhanced error reporting will now tell you exactly what's wrong so we can fix it quickly! 🚀