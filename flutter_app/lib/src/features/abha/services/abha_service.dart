import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../data/models/abha_models.dart';

class AbhaService {
  // ABDM (Ayushman Bharat Digital Mission) Sandbox URLs
  // For production, use production URLs
  static const String baseUrl = 'https://healthidsbx.abdm.gov.in/api/v2';
  static const String publicUrl = 'https://healthidsbx.abdm.gov.in/api/v1';

  // Client ID and Secret (Replace with your ABDM credentials)
  // Get these from: https://sandbox.abdm.gov.in/
  static const String clientId = 'SBX_002777';
  static const String clientSecret = 'your_client_secret';

  // Demo mode for testing UI without ABDM credentials
  static const bool demoMode =
      true; // Set to false when you have real credentials

  String? _accessToken;
  DateTime? _tokenExpiry;

  // Store transaction ID for demo mode
  String? _demoTransactionId;

  // Get access token for ABDM API
  Future<String> _getAccessToken() async {
    // Check if token is still valid
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    try {
      final response = await http.post(
        Uri.parse('$publicUrl/auth/generateToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'clientId': clientId,
          'clientSecret': clientSecret,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['accessToken'];
        _tokenExpiry = DateTime.now().add(Duration(minutes: 15));
        return _accessToken!;
      } else {
        throw Exception('Failed to get access token: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting access token: $e');
      throw Exception('Failed to authenticate with ABDM');
    }
  }

  // Step 1: Generate Aadhaar OTP
  Future<String> generateAadhaarOtp(String aadhaarNumber) async {
    // Demo mode - simulate OTP generation without API call
    if (demoMode) {
      await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      _demoTransactionId = 'DEMO_TXN_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint(
          'DEMO MODE: OTP sent to Aadhaar-linked mobile. Use any 6-digit OTP.');
      return _demoTransactionId!;
    }

    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$baseUrl/registration/aadhaar/generateOtp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'aadhaar': aadhaarNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['txnId']; // Transaction ID for OTP verification
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to generate OTP');
      }
    } catch (e) {
      debugPrint('Error generating Aadhaar OTP: $e');
      throw Exception('Failed to generate OTP. Please try again.');
    }
  }

  // Step 2: Verify Aadhaar OTP
  Future<String> verifyAadhaarOtp(String otp, String txnId) async {
    // Demo mode - accept any 6-digit OTP
    if (demoMode) {
      await Future.delayed(Duration(seconds: 1));
      if (otp.length == 6) {
        debugPrint('DEMO MODE: OTP verified successfully');
        return txnId; // Return same transaction ID
      } else {
        throw Exception('OTP must be 6 digits');
      }
    }

    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$baseUrl/registration/aadhaar/verifyOTP'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'otp': otp,
          'txnId': txnId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['txnId']; // New transaction ID for mobile OTP
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      debugPrint('Error verifying Aadhaar OTP: $e');
      throw Exception('Invalid OTP. Please try again.');
    }
  }

  // Step 3: Generate Mobile OTP
  Future<String> generateMobileOtp(String mobileNumber, String txnId) async {
    // Demo mode
    if (demoMode) {
      await Future.delayed(Duration(seconds: 2));
      debugPrint(
          'DEMO MODE: Mobile OTP sent to $mobileNumber. Use any 6-digit OTP.');
      return txnId;
    }

    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$baseUrl/registration/mobile/generateOtp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'mobile': mobileNumber,
          'txnId': txnId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['txnId'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send mobile OTP');
      }
    } catch (e) {
      debugPrint('Error generating mobile OTP: $e');
      throw Exception('Failed to send mobile OTP. Please try again.');
    }
  }

  // Step 4: Verify Mobile OTP
  Future<String> verifyMobileOtp(String otp, String txnId) async {
    // Demo mode
    if (demoMode) {
      await Future.delayed(Duration(seconds: 1));
      if (otp.length == 6) {
        debugPrint('DEMO MODE: Mobile OTP verified successfully');
        return txnId;
      } else {
        throw Exception('OTP must be 6 digits');
      }
    }

    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$baseUrl/registration/mobile/verifyOtp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'otp': otp,
          'txnId': txnId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['txnId'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Invalid mobile OTP');
      }
    } catch (e) {
      debugPrint('Error verifying mobile OTP: $e');
      throw Exception('Invalid mobile OTP. Please try again.');
    }
  }

  // Step 5: Check if ABHA address is available
  Future<bool> checkAbhaAddressAvailability(String abhaAddress) async {
    // Demo mode - always available
    if (demoMode) {
      await Future.delayed(Duration(seconds: 1));
      debugPrint('DEMO MODE: ABHA address $abhaAddress is available');
      return true;
    }

    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$baseUrl/registration/beneficiary/checkAvailability'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'healthId': abhaAddress,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'available';
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error checking ABHA address: $e');
      return false;
    }
  }

  // Step 6: Create ABHA ID
  Future<AbhaCard> createAbhaId({
    required String txnId,
    required String abhaAddress,
    String? email,
    String? password,
  }) async {
    // Demo mode - return mock ABHA card
    if (demoMode) {
      await Future.delayed(Duration(seconds: 2));
      debugPrint('DEMO MODE: ABHA ID created successfully');
      return AbhaCard(
        abhaNumber: '12-3456-7890-1234',
        abhaAddress: abhaAddress,
        name: 'Demo User',
        dateOfBirth: '01-01-1990',
        gender: 'M',
        mobileNumber: '+91-9876543210',
        email: email,
        address: 'Demo Address, Demo City, Demo State - 123456',
        districtName: 'Demo District',
        stateName: 'Demo State',
        profilePhoto: null,
        createdDate: DateTime.now(),
      );
    }

    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$baseUrl/registration/beneficiary/createHealthId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'txnId': txnId,
          'healthId': abhaAddress,
          if (email != null) 'email': email,
          if (password != null) 'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AbhaCard.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create ABHA ID');
      }
    } catch (e) {
      debugPrint('Error creating ABHA ID: $e');
      throw Exception('Failed to create ABHA ID. Please try again.');
    }
  }

  // Link existing ABHA ID using Health ID and password
  Future<AbhaCard> linkAbhaWithPassword({
    required String abhaAddress,
    required String password,
  }) async {
    // Demo mode
    if (demoMode) {
      await Future.delayed(Duration(seconds: 2));
      debugPrint('DEMO MODE: ABHA ID linked successfully');
      return AbhaCard(
        abhaNumber: '12-3456-7890-1234',
        abhaAddress: abhaAddress,
        name: 'Demo Linked User',
        dateOfBirth: '15-05-1985',
        gender: 'F',
        mobileNumber: '+91-9876543210',
        email: 'demo@example.com',
        address: 'Linked Address, Demo City, Demo State - 123456',
        districtName: 'Demo District',
        stateName: 'Demo State',
        profilePhoto: null,
        createdDate: DateTime.now(),
      );
    }

    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$baseUrl/auth/authPassword'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'healthId': abhaAddress,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String xToken = data['token'];

        // Get ABHA card details
        return await _getAbhaCardDetails(xToken);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      debugPrint('Error linking ABHA: $e');
      throw Exception('Failed to link ABHA ID. Please check your credentials.');
    }
  }

  // Link existing ABHA using Aadhaar OTP
  Future<AbhaCard> linkAbhaWithAadhaar({
    required String aadhaarNumber,
  }) async {
    try {
      // Generate OTP
      await generateAadhaarOtp(aadhaarNumber);
      return AbhaCard(
        abhaNumber: '',
        abhaAddress: '',
        name: '',
        gender: '',
        dateOfBirth: '',
        mobileNumber: '',
        createdDate: DateTime.now(),
      ); // Return empty card, user needs to verify OTP
    } catch (e) {
      throw Exception('Failed to initiate linking. Please try again.');
    }
  }

  // Get ABHA card details
  Future<AbhaCard> _getAbhaCardDetails(String xToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/account/profile'),
        headers: {
          'Content-Type': 'application/json',
          'X-Token': xToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AbhaCard.fromJson(data);
      } else {
        throw Exception('Failed to fetch ABHA card details');
      }
    } catch (e) {
      debugPrint('Error getting ABHA card: $e');
      throw Exception('Failed to fetch ABHA card details');
    }
  }

  // Get suggested ABHA addresses
  Future<List<String>> getSuggestedAbhaAddresses(String txnId) async {
    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$baseUrl/registration/beneficiary/generateHealthId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'txnId': txnId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['healthIdSuggestions'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      return [];
    }
  }

  // Download ABHA card as PDF (mock implementation)
  Future<String> downloadAbhaCard(AbhaCard abhaCard) async {
    // In production, call ABDM API to generate and download PDF
    // For now, return a mock path
    return '/storage/emulated/0/Download/abha_card.pdf';
  }

  // Validate Aadhaar number
  bool isValidAadhaar(String aadhaar) {
    // Remove spaces and dashes
    final cleaned = aadhaar.replaceAll(RegExp(r'[\s-]'), '');

    // Check if it's 12 digits
    if (cleaned.length != 12 || !RegExp(r'^\d+$').hasMatch(cleaned)) {
      return false;
    }

    return true;
  }

  // Validate ABHA address format
  bool isValidAbhaAddress(String address) {
    // ABHA address should be alphanumeric and can contain dots/underscores
    // Length should be between 4-18 characters
    if (address.length < 4 || address.length > 18) {
      return false;
    }

    return RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(address);
  }
}
