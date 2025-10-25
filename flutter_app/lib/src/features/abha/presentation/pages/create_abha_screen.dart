import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/abha_service.dart';
import '../../data/models/abha_models.dart';
import 'abha_card_display_screen.dart';

class CreateAbhaScreen extends ConsumerStatefulWidget {
  const CreateAbhaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateAbhaScreen> createState() => _CreateAbhaScreenState();
}

class _CreateAbhaScreenState extends ConsumerState<CreateAbhaScreen> {
  final AbhaService _abhaService = AbhaService();
  final PageController _pageController = PageController();

  // Step controllers
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _aadhaarOtpController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _mobileOtpController = TextEditingController();
  final TextEditingController _abhaAddressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String? _txnId;
  List<String> _suggestedAddresses = [];

  final List<String> _steps = [
    'Aadhaar',
    'Verify OTP',
    'Mobile',
    'Mobile OTP',
    'Create ID',
  ];

  @override
  void dispose() {
    _aadhaarController.dispose();
    _aadhaarOtpController.dispose();
    _mobileController.dispose();
    _mobileOtpController.dispose();
    _abhaAddressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _errorMessage = null;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _errorMessage = null;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _generateAadhaarOtp() async {
    final aadhaar = _aadhaarController.text.trim();

    if (!_abhaService.isValidAadhaar(aadhaar)) {
      setState(() {
        _errorMessage = 'Please enter a valid 12-digit Aadhaar number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _txnId = await _abhaService.generateAadhaarOtp(aadhaar);
      _nextStep();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyAadhaarOtp() async {
    final otp = _aadhaarOtpController.text.trim();

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _txnId = await _abhaService.verifyAadhaarOtp(otp, _txnId!);
      _nextStep();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateMobileOtp() async {
    final mobile = _mobileController.text.trim();

    if (mobile.length != 10) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _txnId = await _abhaService.generateMobileOtp(mobile, _txnId!);
      _nextStep();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyMobileOtp() async {
    final otp = _mobileOtpController.text.trim();

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _txnId = await _abhaService.verifyMobileOtp(otp, _txnId!);

      // Get suggested ABHA addresses
      final suggestions = await _abhaService.getSuggestedAbhaAddresses(_txnId!);
      setState(() {
        _suggestedAddresses = suggestions;
      });

      _nextStep();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createAbhaId() async {
    final abhaAddress = _abhaAddressController.text.trim();

    if (!_abhaService.isValidAbhaAddress(abhaAddress)) {
      setState(() {
        _errorMessage =
            'ABHA address must be 4-18 characters (letters, numbers, dots, underscores)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check availability
      final isAvailable =
          await _abhaService.checkAbhaAddressAvailability(abhaAddress);

      if (!isAvailable) {
        setState(() {
          _errorMessage =
              'This ABHA address is already taken. Please choose another.';
          _isLoading = false;
        });
        return;
      }

      // Create ABHA ID
      final abhaCard = await _abhaService.createAbhaId(
        txnId: _txnId!,
        abhaAddress: abhaAddress,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        password: _passwordController.text.trim().isEmpty
            ? null
            : _passwordController.text.trim(),
      );

      // Navigate to success screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AbhaCardDisplayScreen(abhaCard: abhaCard),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Create ABHA ID',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00BCD4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAadhaarStep(),
                _buildAadhaarOtpStep(),
                _buildMobileStep(),
                _buildMobileOtpStep(),
                _buildCreateIdStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.white,
      child: Row(
        children: List.generate(_steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted || isActive
                              ? const Color(0xFF00BCD4)
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _steps[index],
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive
                              ? const Color(0xFF00BCD4)
                              : Colors.grey[600],
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (index < _steps.length - 1)
                  Container(
                    width: 8,
                    height: 2,
                    color: isCompleted
                        ? const Color(0xFF00BCD4)
                        : Colors.grey[300],
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAadhaarStep() {
    return _buildStepContainer(
      title: 'Enter Aadhaar Number',
      subtitle: 'We will send an OTP to your Aadhaar-linked mobile',
      child: Column(
        children: [
          TextField(
            controller: _aadhaarController,
            keyboardType: TextInputType.number,
            maxLength: 12,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Aadhaar Number',
              hintText: 'Enter 12-digit Aadhaar',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _generateAadhaarOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Send OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAadhaarOtpStep() {
    return _buildStepContainer(
      title: 'Verify Aadhaar OTP',
      subtitle: 'Enter the 6-digit OTP sent to your Aadhaar-linked mobile',
      child: Column(
        children: [
          TextField(
            controller: _aadhaarOtpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'OTP',
              hintText: 'Enter 6-digit OTP',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading ? null : _generateAadhaarOtp,
            child: const Text('Resend OTP'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyAadhaarOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStep() {
    return _buildStepContainer(
      title: 'Enter Mobile Number',
      subtitle: 'We will send an OTP to verify your mobile number',
      child: Column(
        children: [
          TextField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              hintText: 'Enter 10-digit mobile',
              prefixIcon: const Icon(Icons.phone),
              prefix: const Text('+91 '),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _generateMobileOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Send OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileOtpStep() {
    return _buildStepContainer(
      title: 'Verify Mobile OTP',
      subtitle: 'Enter the 6-digit OTP sent to your mobile',
      child: Column(
        children: [
          TextField(
            controller: _mobileOtpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'OTP',
              hintText: 'Enter 6-digit OTP',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading ? null : _generateMobileOtp,
            child: const Text('Resend OTP'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyMobileOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateIdStep() {
    return _buildStepContainer(
      title: 'Create Your ABHA Address',
      subtitle: 'Choose a unique ABHA address (Health ID)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_suggestedAddresses.isNotEmpty) ...[
            const Text(
              'Suggested ABHA Addresses:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestedAddresses.map((address) {
                return InkWell(
                  onTap: () {
                    _abhaAddressController.text = address;
                  },
                  child: Chip(
                    label: Text(address),
                    backgroundColor: const Color(0xFF00BCD4).withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: Color(0xFF00BCD4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _abhaAddressController,
            decoration: InputDecoration(
              labelText: 'ABHA Address',
              hintText: 'e.g., yourname@abdm',
              prefixIcon: const Icon(Icons.account_circle),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText:
                  '4-18 characters (letters, numbers, dots, underscores)',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email (Optional)',
              hintText: 'your@email.com',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password (Optional)',
              hintText: 'Create a password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText: 'Use this to login to your ABHA account later',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createAbhaId,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Create ABHA ID',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red[900],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}
