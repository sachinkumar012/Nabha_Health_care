import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Using the Web Client ID from your google-services.json for better compatibility
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '4692045271-1j2k5i3salcqvpccjrvve78nlcv6hcu1.apps.googleusercontent.com',
  );

  /// Direct Google Sign-In (bypassing Firebase for compatibility)
  static Future<Map<String, String>?> signInWithGoogleDirect() async {
    try {
      print('🔐 Starting Direct Google Sign-In...');

      // Sign out first to ensure clean sign-in
      try{
        await _googleSignIn.signOut();
      } catch (signOutError) {
        print('🔄 Sign out skipped: $signOutError');
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ Google Sign-In cancelled by user');
        return null;
      }

      print('✅ Google account selected: ${googleUser.email}');
      print('👤 Display name: ${googleUser.displayName}');
      print('🆔 User ID: ${googleUser.id}');

      // Return user data directly without Firebase
      return {
        'id': googleUser.id,
        'name': googleUser.displayName ?? 'Unknown User',
        'email': googleUser.email,
        'photoUrl': googleUser.photoUrl ?? '',
      };
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Sign out from Google and Firebase
  static Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('✅ Google Sign-Out successful');
    } catch (e) {
      print('❌ Google Sign-Out error: $e');
      rethrow;
    }
  }

  /// Get current Firebase user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if user is signed in
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }

  /// Get user stream for listening to auth state changes
  static Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }
}
