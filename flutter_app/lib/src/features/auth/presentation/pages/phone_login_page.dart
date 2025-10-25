import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/phone_auth_service.dart';
import '../../../home/presentation/pages/home_page.dart';

class PhoneLoginPage extends ConsumerStatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  ConsumerState<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends ConsumerState<PhoneLoginPage> {
  final _phoneAuthService = PhoneAuthService();
  final _phoneController = TextEditingController(text: '+91');
  final _otpController = TextEditingController();
  
  String? _verificationId;
  bool _codeSent = false;
  bool _isLoading = false;
  int _resendTimer = 0;
  Timer? _timer;

  // Country codes for dropdown
  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
    {'code': '+1', 'name': 'USA', 'flag': '🇺🇸'},
    {'code': '+44', 'name': 'UK', 'flag': '🇬🇧'},
    {'code': '+971', 'name': 'UAE', 'flag': '🇦🇪'},
  ];
  
  String _selectedCountryCode = '+91';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startResendTimer() {
    setState(() => _resendTimer = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    
    if (phone.length < 10) {
      _showSnack('Please enter a valid phone number', isError: true);
      return;
    }

    // Format phone number with country code
    final fullPhone = _phoneAuthService.formatPhoneNumber(phone, _selectedCountryCode);
    
    if (!_phoneAuthService.isValidPhoneNumber(fullPhone)) {
      _showSnack('Invalid phone number format', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    await _phoneAuthService.verifyPhoneNumber(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
          _startResendTimer();
          _showSnack('OTP sent successfully!');
        }
      },
      onVerificationFailed: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnack(error, isError: true);
        }
      },
      onVerificationCompleted: (credential) async {
        // Auto-verification (Android only)
        if (mounted) {
          setState(() => _isLoading = true);
          try {
            final userCredential = await _phoneAuthService.signInWithCredential(credential);
            // Check if user is signed in (even if userCredential is null due to type error)
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              await _handleSuccessfulLogin(currentUser);
            } else if (userCredential != null) {
              await _handleSuccessfulLogin(userCredential.user!);
            } else {
              _showSnack('Auto sign-in failed', isError: true);
              setState(() => _isLoading = false);
            }
          } catch (e) {
            _showSnack('Auto sign-in failed: $e', isError: true);
            setState(() => _isLoading = false);
          }
        }
      },
    );
  }

  Future<void> _verifyOTP() async {
    final code = _otpController.text.trim();
    
    if (code.length != 6) {
      _showSnack('Please enter a valid 6-digit OTP', isError: true);
      return;
    }

    if (_verificationId == null) {
      _showSnack('Please request OTP first', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _phoneAuthService.signInWithOTP(
        verificationId: _verificationId!,
        smsCode: code,
      );
      
      // Check if user is signed in (even if userCredential is null due to type error)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _handleSuccessfulLogin(currentUser);
      } else if (userCredential != null && userCredential.user != null) {
        await _handleSuccessfulLogin(userCredential.user!);
      } else {
        throw 'Verification failed. Please try again.';
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack(e.toString(), isError: true);
      }
    }
  }

  Future<void> _handleSuccessfulLogin(User user) async {
    if (user.phoneNumber == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Show success message
    if (mounted) {
      _showSnack('Signed in successfully! Phone: ${user.phoneNumber}');
      setState(() => _isLoading = false);
    }

    // Wait a moment to show success message
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      // Simply pop back to previous screen (login page)
      // The Firebase auth state will automatically handle the logged-in state
      Navigator.of(context).pop();
      
      // Then navigate to home
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        try {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } catch (e) {
          // If navigation fails, just pop back
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_resendTimer > 0) return;
    
    final phone = _phoneController.text.trim();
    final fullPhone = _phoneAuthService.formatPhoneNumber(phone, _selectedCountryCode);
    
    setState(() => _isLoading = true);

    await _phoneAuthService.resendOTP(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
          _startResendTimer();
          _showSnack('OTP resent successfully!');
        }
      },
      onVerificationFailed: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnack(error, isError: true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largeSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.mediumSpacing),

              // Logo and Title
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.phone_android,
                      size: 40,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  Text(
                    'Phone Login',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey900,
                        ),
                  ),
                  const SizedBox(height: AppConstants.smallSpacing),
                  Text(
                    _codeSent
                        ? 'Enter the OTP sent to your phone'
                        : 'Sign in securely using your phone number',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.grey600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.extraLargeSpacing),

              if (!_codeSent) ...[
                // Phone Number Input
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country Code Dropdown
                    Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryCode,
                          isExpanded: true,
                          items: _countryCodes.map((country) {
                            return DropdownMenuItem<String>(
                              value: country['code'],
                              child: Text(
                                '${country['flag']} ${country['code']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCountryCode = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Phone Number Field
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '9876543210',
                          prefixIcon: const Icon(Icons.phone),
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.mediumSpacing),

                // Info Text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'We\'ll send you a 6-digit verification code',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.largeSpacing),

                // Send OTP Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendOTP,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isLoading ? 'Sending...' : 'Send OTP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ] else ...[
                // OTP Input
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    hintText: '000000',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.mediumSpacing),

                // Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Didn\'t receive OTP? ',
                      style: TextStyle(color: AppColors.grey600),
                    ),
                    if (_resendTimer > 0)
                      Text(
                        'Resend in ${_resendTimer}s',
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _resendOTP,
                        child: const Text('Resend OTP'),
                      ),
                  ],
                ),

                const SizedBox(height: AppConstants.largeSpacing),

                // Verify OTP Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _verifyOTP,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                          ),
                        )
                      : const Icon(Icons.verified_user),
                  label: Text(_isLoading ? 'Verifying...' : 'Verify & Sign In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.mediumSpacing),

                // Change Number
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _codeSent = false;
                      _otpController.clear();
                      _timer?.cancel();
                      _resendTimer = 0;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Change Phone Number'),
                ),
              ],

              const SizedBox(height: AppConstants.extraLargeSpacing),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: AppConstants.largeSpacing),

              // Back to Email Login
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.email_outlined),
                label: const Text('Sign in with Email'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
