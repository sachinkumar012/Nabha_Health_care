import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/constants/payment_config.dart';

class PaymentService {
  late Razorpay _razorpay;
  final BuildContext context;
  bool _isInitialized = false;

  // Callback functions
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentFailure;
  Function(ExternalWalletResponse)? onExternalWallet;

  PaymentService({required this.context}) {
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    try {
      print('🔥🔥🔥 PAYMENT_DEBUG: === INITIALIZING RAZORPAY ===');

      // Dispose existing instance if any
      try {
        _razorpay.clear();
      } catch (e) {
        print('🔥🔥🔥 PAYMENT_DEBUG: Previous instance cleanup: $e');
      }

      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      _isInitialized = true;

      print('🔥🔥🔥 PAYMENT_DEBUG: ✅ Razorpay initialized successfully');
      print(
          '🔥🔥🔥 PAYMENT_DEBUG: 🔑 Using Key ID: ${PaymentConfig.razorpayKeyId}');
      print('🔥🔥🔥 PAYMENT_DEBUG: 💱 Currency: ${PaymentConfig.currency}');
      print('🔥🔥🔥 PAYMENT_DEBUG: 🏢 Company: ${PaymentConfig.companyName}');
    } catch (e) {
      print('🔥🔥🔥 PAYMENT_DEBUG: ❌ Error initializing Razorpay: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> startPayment({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? description,
    Map<String, dynamic>? notes,
  }) async {
    try {
      print('🔥🔥🔥 PAYMENT_DEBUG: === STARTING RAZORPAY PAYMENT ===');

      if (!_isInitialized) {
        print(
            '🔥🔥🔥 PAYMENT_DEBUG: ❌ Razorpay not initialized! Attempting to reinitialize...');
        _initializeRazorpay();
        if (!_isInitialized) {
          throw Exception('Razorpay initialization failed');
        }
      }

      print('🔥🔥🔥 PAYMENT_DEBUG: ✅ Razorpay is initialized');
      print('🔥🔥🔥 PAYMENT_DEBUG: 💰 Amount: ₹$amount');
      print(
          '�🔥🔥 PAYMENT_DEBUG: �👤 Customer: $customerName ($customerEmail, $customerPhone)');
      print('🔥🔥🔥 PAYMENT_DEBUG: 🆔 Order ID: $orderId');
      print(
          '🔥🔥🔥 PAYMENT_DEBUG: 🔑 Using Razorpay Key: ${PaymentConfig.razorpayKeyId}');

      // Convert amount to paise (smallest currency unit)
      int amountInPaise = (amount * 100).round();
      print('🔥🔥� PAYMENT_DEBUG: �💱 Amount in paise: $amountInPaise');

      var options = {
        'key': PaymentConfig.razorpayKeyId,
        'amount': amountInPaise,
        'currency': PaymentConfig.currency,
        'name': PaymentConfig.companyName,
        'description': description ?? PaymentConfig.companyDescription,
        'prefill': {
          'contact': customerPhone,
          'email': customerEmail,
          'name': customerName,
        },
        'theme': {
          'color': '#1976D2',
        },
        'notes': notes ??
            {
              'order_id': orderId,
            },
        'retry': {'enabled': true, 'max_count': 3},
        'send_sms_hash': true,
        'remember_customer': false,
        'timeout': 300, // 5 minutes timeout
      };

      print('�🔥🔥 PAYMENT_DEBUG: �📋 Payment options prepared: $options');
      print('�🔥🔥 PAYMENT_DEBUG: �🚀 Calling _razorpay.open()...');

      // Open Razorpay checkout
      _razorpay.open(options);

      print(
          '🔥🔥🔥 PAYMENT_DEBUG: ✅ _razorpay.open() called successfully - waiting for user interaction');
    } catch (e) {
      print('🔥🔥🔥 PAYMENT_DEBUG: === PAYMENT ERROR ===');
      print('🔥🔥🔥 PAYMENT_DEBUG: ❌ Error starting payment: $e');
      print('🔥🔥🔥 PAYMENT_DEBUG: 📋 Error type: ${e.runtimeType}');
      print('🔥🔥🔥 PAYMENT_DEBUG: 📱 Context: ${context.mounted}');
      _showErrorDialog(
          'Payment initialization failed: $e\n\nPlease try again.');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('🔥🔥🔥 PAYMENT_DEBUG: Payment Success: ${response.paymentId}');

    // Only call the callback, don't show dialog here
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(
        '🔥🔥🔥 PAYMENT_DEBUG: Payment Error: ${response.code} - ${response.message}');

    // Only call the callback, don't show dialog here
    if (onPaymentFailure != null) {
      onPaymentFailure!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('🔥🔥🔥 PAYMENT_DEBUG: External Wallet: ${response.walletName}');

    // Only call the callback, don't show dialog here
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    }
  }

  Future<void> _verifyPayment(PaymentSuccessResponse response) async {
    try {
      final verificationData = {
        'payment_id': response.paymentId,
        'order_id': response.orderId,
        'signature': response.signature,
      };

      final verifyResponse = await http.post(
        Uri.parse('${PaymentConfig.paymentApiUrl}/verify'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(verificationData),
      );

      if (verifyResponse.statusCode == 200) {
        final result = json.decode(verifyResponse.body);
        debugPrint('Payment verification result: $result');
      } else {
        debugPrint('Payment verification failed: ${verifyResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error verifying payment: $e');
    }
  }

  Future<String?> createOrder({
    required double amount,
    required String currency,
    String? receipt,
    Map<String, dynamic>? notes,
  }) async {
    try {
      final orderData = {
        'amount': (amount * 100).round(), // Amount in paise
        'currency': currency,
        'receipt': receipt ?? 'order_${DateTime.now().millisecondsSinceEpoch}',
        'notes': notes ?? {},
      };

      final response = await http.post(
        Uri.parse('${PaymentConfig.paymentApiUrl}/create-order'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['id']; // Return order ID
      } else {
        debugPrint('Order creation failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Payment Failed'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info, color: Colors.blue),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    _razorpay.clear();
  }
}

// Payment response models for better type safety
class PaymentResult {
  final bool isSuccess;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;
  final int? errorCode;

  PaymentResult({
    required this.isSuccess,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorMessage,
    this.errorCode,
  });

  factory PaymentResult.success({
    required String paymentId,
    required String orderId,
    required String signature,
  }) {
    return PaymentResult(
      isSuccess: true,
      paymentId: paymentId,
      orderId: orderId,
      signature: signature,
    );
  }

  factory PaymentResult.failure({
    required String errorMessage,
    int? errorCode,
  }) {
    return PaymentResult(
      isSuccess: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}
