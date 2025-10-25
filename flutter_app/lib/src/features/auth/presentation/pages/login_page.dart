import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/user_provider.dart';
import '../../../../services/google_auth_service.dart';
import 'phone_login_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largeSpacing),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.extraLargeSpacing),

                // Logo and Title
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        size: 40,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),
                    Text(
                      'Welcome Back',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.grey900,
                              ),
                    ),
                    const SizedBox(height: AppConstants.smallSpacing),
                    Text(
                      'Sign in to access your healthcare account',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.grey600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.extraLargeSpacing),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: _validateEmail,
                ),

                const SizedBox(height: AppConstants.mediumSpacing),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword,
                ),

                const SizedBox(height: AppConstants.smallSpacing),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: AppConstants.largeSpacing),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : const Text('Sign In'),
                ),

                const SizedBox(height: AppConstants.largeSpacing),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.mediumSpacing),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppColors.grey500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: AppConstants.largeSpacing),

                // Phone Sign-In Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signInWithPhone,
                    icon: const Icon(Icons.phone_android,
                        size: 20, color: AppColors.primary),
                    label: const Text(
                      'Continue with Phone',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side:
                          const BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.mediumSpacing),

                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: Container(
                      width: 20,
                      height: 20,
                      child: const Icon(Icons.g_mobiledata,
                          size: 20, color: AppColors.primary),
                    ),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side:
                          const BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.largeSpacing),

                // Quick Login as Patient/Doctor
                const Text(
                  'Quick Demo Login',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.grey600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.mediumSpacing),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _quickLogin('patient'),
                        icon: const Icon(Icons.person, size: 16),
                        label: const Text('Patient',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallSpacing),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _quickLogin('doctor'),
                        icon: const Icon(Icons.local_hospital, size: 16),
                        label: const Text('Doctor',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.extraLargeSpacing),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppColors.grey600),
                    ),
                    TextButton(
                      onPressed: _navigateToRegister,
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the actual user provider login method
      await ref.read(userProvider.notifier).loginUser(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to home
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _quickLogin(String userType) async {
    // Quick login for demo purposes
    try {
      await ref.read(userProvider.notifier).registerUser(
            name: userType == 'patient' ? 'Demo Patient' : 'Demo Doctor',
            email: '$userType@demo.com',
            phone: '1234567890',
            password: 'demo123',
            userType: userType,
          );

      if (mounted) {
        // Navigate to home
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      // If registration fails (user already exists), try to login
      try {
        await ref.read(userProvider.notifier).loginUser(
              email: '$userType@demo.com',
              password: 'demo123',
            );

        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        }
      } catch (loginError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Demo login failed: $loginError'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _signInWithPhone() {
    // Navigate to phone login page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PhoneLoginPage(),
      ),
    );
  }

  void _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('� Starting Optimized Google Sign-In...');

      // Use the optimized Google Auth Service
      final userData = await GoogleAuthService.signInWithGoogleDirect();

      if (userData == null) {
        print('❌ Google Sign-In cancelled by user');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign-In was cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      print('✅ Google authentication successful, proceeding to app...');
      print('� User: ${userData['name']}');
      print('📧 Email: ${userData['email']}');

      // Handle successful authentication
      await _handleSuccessfulAuth(null, userData['name'], userData['email']);
    } catch (e) {
      print('❌ Google Sign-In error: $e');

      if (mounted) {
        String errorMessage = 'Google Sign-In failed';

        if (e.toString().contains('network') ||
            e.toString().contains('Network')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else if (e.toString().contains('cancelled')) {
          errorMessage = 'Sign-in was cancelled';
        } else if (e.toString().contains('PlatformException')) {
          errorMessage =
              'Google Sign-In configuration error. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to handle successful authentication
  Future<void> _handleSuccessfulAuth(dynamic firebaseUser, String? displayName,
      [String? email]) async {
    print('✅ Authentication process completed successfully');
    print('👤 User: ${displayName ?? 'Google User'}');
    print('📧 Email: ${email ?? 'No email provided'}');

    // Update the user provider state with Google user information
    try {
      await ref.read(userProvider.notifier).registerUser(
            name: displayName ?? 'Google User',
            email: email ??
                'google.user@example.com', // Use actual Google email or fallback
            phone: '1234567890', // Default phone number
            password: 'google_auth_temp', // Temporary password for Google users
            userType: 'patient',
          );
      print('✅ User state updated successfully');
    } catch (userUpdateError) {
      print('⚠️ User state update failed, but continuing: $userUpdateError');
      // Continue anyway since Google authentication was successful
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Welcome ${displayName ?? 'Google User'}!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate directly to home
      print('🏠 Navigating to home screen...');
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Text(
            'Password reset functionality will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed(AppRoutes.register);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
