import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current verification ID
  String? _verificationId;
  int? _resendToken;

  String? get verificationId => _verificationId;

  /// Verify phone number and send OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
    Function(PhoneAuthCredential credential)? onVerificationCompleted,
    Function(String verificationId)? onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        
        // Called when verification is done automatically (Android auto-retrieval)
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            print('✅ Phone verification completed automatically');
          }
          if (onVerificationCompleted != null) {
            onVerificationCompleted(credential);
          } else {
            // Auto sign-in if no custom handler provided
            await signInWithCredential(credential);
          }
        },
        
        // Called when verification fails
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('❌ Phone verification failed: ${e.code} - ${e.message}');
          }
          
          String errorMessage = 'Verification failed. Please try again.';
          
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'The phone number format is invalid.';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later.';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later.';
              break;
            case 'user-disabled':
              errorMessage = 'This phone number has been disabled.';
              break;
            default:
              errorMessage = e.message ?? errorMessage;
          }
          
          onVerificationFailed(errorMessage);
        },
        
        // Called when OTP is sent successfully
        codeSent: (String verificationId, int? resendToken) {
          if (kDebugMode) {
            print('✅ OTP sent successfully. Verification ID: $verificationId');
          }
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        
        // Called when auto-retrieval times out
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) {
            print('⏱️ Code auto-retrieval timeout');
          }
          _verificationId = verificationId;
          if (onCodeAutoRetrievalTimeout != null) {
            onCodeAutoRetrievalTimeout(verificationId);
          }
        },
        
        // Use resend token for subsequent requests
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verifying phone number: $e');
      }
      onVerificationFailed('An error occurred. Please try again.');
    }
  }

  /// Sign in with phone credential using OTP
  Future<UserCredential?> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      return await signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Sign-in failed: ${e.code} - ${e.message}');
      }
      
      switch (e.code) {
        case 'invalid-verification-code':
          throw 'Invalid OTP. Please check and try again.';
        case 'session-expired':
          throw 'OTP has expired. Please request a new one.';
        case 'invalid-verification-id':
          throw 'Invalid session. Please restart the process.';
        default:
          throw e.message ?? 'Sign-in failed. Please try again.';
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error during sign-in: $e');
      }
      rethrow;
    }
  }

  /// Sign in with credential (used internally)
  Future<UserCredential?> signInWithCredential(
      PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      if (kDebugMode) {
        print('✅ Successfully signed in: ${userCredential.user?.phoneNumber}');
      }
      return userCredential;
    } on TypeError catch (e) {
      // Handle Pigeon type casting error from Google Sign-In conflict
      if (kDebugMode) {
        print('⚠️ Type error during sign-in (likely Pigeon conflict): $e');
        print('⚠️ Checking if user is actually signed in...');
      }
      
      // Wait a moment for Firebase to update
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if user is actually signed in despite the error
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.phoneNumber != null) {
        if (kDebugMode) {
          print('✅ User is signed in despite type error: ${currentUser.phoneNumber}');
        }
        // Return null but the user is authenticated
        return null;
      }
      
      throw 'Authentication completed but verification failed. Please try logging in again.';
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign-in with credential failed: $e');
      }
      rethrow;
    }
  }

  /// Link phone credential to existing user
  Future<UserCredential?> linkPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'No user is currently signed in.';
      }

      return await currentUser.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Link phone number failed: ${e.code} - ${e.message}');
      }
      
      switch (e.code) {
        case 'provider-already-linked':
          throw 'This phone number is already linked to your account.';
        case 'credential-already-in-use':
          throw 'This phone number is already used by another account.';
        default:
          throw e.message ?? 'Failed to link phone number.';
      }
    }
  }

  /// Resend OTP (use the same verifyPhoneNumber method)
  Future<void> resendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onVerificationFailed,
  }) async {
    await verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: onVerificationFailed,
    );
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _resendToken = null;
  }

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if phone number is valid format
  bool isValidPhoneNumber(String phoneNumber) {
    // Basic validation: starts with + and has 10-15 digits
    final regex = RegExp(r'^\+[1-9]\d{9,14}$');
    return regex.hasMatch(phoneNumber);
  }

  /// Format phone number with country code
  String formatPhoneNumber(String phoneNumber, String countryCode) {
    // Remove any non-digit characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Add country code if not present
    if (!cleaned.startsWith(countryCode.replaceAll('+', ''))) {
      return '+$countryCode$cleaned';
    }
    
    return '+$cleaned';
  }
}
