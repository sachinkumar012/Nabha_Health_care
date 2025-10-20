import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../../services/payment_service.dart';
import '../../data/models/order_model.dart';
import '../../data/services/order_storage_service.dart';
import 'pharmacy_page.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _streetController = TextEditingController();
  final _pincodeController = TextEditingController();
  String _selectedPaymentMethod = 'cod'; // 'cod' or 'online'
  PaymentService? _paymentService;
  final OrderStorageService _orderService = OrderStorageService();

  @override
  void initState() {
    super.initState();
    // Pre-fill user data if available
    final user = ref.read(userProvider);
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _addressController.text = user.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _streetController.dispose();
    _pincodeController.dispose();
    _paymentService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartProvider.notifier).totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: cart.isEmpty ? _buildEmptyCart() : _buildCheckoutForm(cart, total),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppColors.grey400,
          ),
          SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Add some medicines to proceed with checkout',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutForm(List<CartItem> cart, double total) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largeSpacing),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Section
                  _buildOrderSummary(cart, total),
                  const SizedBox(height: 32),

                  // Customer Information Section
                  _buildSectionTitle('Customer Information'),
                  const SizedBox(height: 16),
                  _buildCustomerForm(),
                  const SizedBox(height: 32),

                  // Payment Method Section
                  _buildSectionTitle('Payment Method'),
                  const SizedBox(height: 16),
                  _buildPaymentMethods(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ),
        _buildBottomSection(total),
      ],
    );
  }

  Widget _buildOrderSummary(List<CartItem> cart, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...cart.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.medicine.name} × ${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '₹${(item.medicine.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Fee:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                total > 500 ? 'FREE' : '₹50.00',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: total > 500 ? AppColors.success : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${(total + (total > 500 ? 0 : 50)).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildCustomerForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Address *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.home),
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _streetController,
          decoration: const InputDecoration(
            labelText: 'Street/Locality *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter street/locality';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _pincodeController,
          decoration: const InputDecoration(
            labelText: 'Pincode *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.pin_drop),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter pincode';
            }
            if (value.length != 6) {
              return 'Please enter valid 6-digit pincode';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Row(
              children: [
                Icon(Icons.money, color: AppColors.success),
                SizedBox(width: 12),
                Text(
                  'Cash on Delivery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            subtitle: const Text('Pay when you receive your order'),
            value: 'cod',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: const Row(
              children: [
                Icon(Icons.payment, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Online Payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            subtitle: const Text('Pay securely using UPI, Cards, or Wallets'),
            value: 'online',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(double total) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Place Order - ₹${(total + (total > 500 ? 0 : 50)).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _placeOrder() {
    if (_formKey.currentState!.validate()) {
      print('🛒 CHECKOUT_DEBUG: Starting order placement');
      print('🛒 CHECKOUT_DEBUG: Payment method: $_selectedPaymentMethod');

      final cart = ref.read(cartProvider);
      final total = ref.read(cartProvider.notifier).totalAmount;
      final deliveryFee = total > 500 ? 0.0 : 50.0;
      final finalTotal = total + deliveryFee;

      final orderData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'street': _streetController.text,
        'pincode': _pincodeController.text,
        'paymentMethod': _selectedPaymentMethod,
        'total': finalTotal,
        'items': cart,
      };

      if (_selectedPaymentMethod == 'online') {
        print('🔥🔥🔥 CHECKOUT_DEBUG: Processing online payment via Razorpay');
        _processRazorpayPayment(context, orderData);
      } else {
        print('🔥🔥🔥 CHECKOUT_DEBUG: Processing Cash on Delivery');
        _showOrderConfirmation(context, orderData, null);
      }
    }
  }

  void _processRazorpayPayment(
      BuildContext context, Map<String, dynamic> orderData) {
    print('🔥🔥🔥 PAYMENT_DEBUG: _processRazorpayPayment called');

    try {
      // Dispose previous payment service if exists
      _paymentService?.dispose();

      // Create new payment service
      _paymentService = PaymentService(context: context);

      // Generate order ID for tracking
      final orderId = 'NH${DateTime.now().millisecondsSinceEpoch}';

      print('🔥🔥🔥 PAYMENT_DEBUG: Order ID: $orderId');
      print('🔥🔥🔥 PAYMENT_DEBUG: Amount: ₹${orderData['total']}');
      print(
          '🔥🔥🔥 PAYMENT_DEBUG: Customer: ${orderData['name']} (${orderData['email']})');

      // Setup payment callbacks
      _paymentService!.onPaymentSuccess = (PaymentSuccessResponse response) {
        print('🔥🔥🔥 PAYMENT_DEBUG: ✅ Payment successful!');
        print('🔥🔥🔥 PAYMENT_DEBUG: Payment ID: ${response.paymentId}');

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Payment successful! Processing order...'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          _showOrderConfirmation(context, orderData, response);
        }
      };

      _paymentService!.onPaymentFailure = (PaymentFailureResponse response) {
        print('🔥🔥🔥 PAYMENT_DEBUG: ❌ Payment failed');
        print('🔥🔥🔥 PAYMENT_DEBUG: Error: ${response.message}');

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();

          String errorMessage = 'Payment failed';
          if (response.message != null) {
            errorMessage = response.message!;
          }

          if (response.code == Razorpay.PAYMENT_CANCELLED) {
            errorMessage = 'Payment was cancelled';
          } else if (response.code == Razorpay.NETWORK_ERROR) {
            errorMessage =
                'Network error. Please check your internet connection.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Payment Failed'),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(errorMessage, style: TextStyle(fontSize: 12)),
                ],
              ),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _processRazorpayPayment(context, orderData),
              ),
            ),
          );
        }
      };

      _paymentService!.onExternalWallet = (ExternalWalletResponse response) {
        print('🔥🔥🔥 PAYMENT_DEBUG: External wallet: ${response.walletName}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${response.walletName}...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      };

      // Show loading indicator
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Initializing secure payment...'),
                    Text('Amount: ₹${orderData['total']}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 10),
          backgroundColor: AppColors.primary,
        ),
      );

      // Validate order data
      if (orderData['total'] == null || orderData['total'] <= 0) {
        throw Exception('Invalid payment amount');
      }

      // Start payment with delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _paymentService != null) {
          print('🔥🔥🔥 PAYMENT_DEBUG: 🚀 Starting Razorpay payment');
          _paymentService!.startPayment(
            amount: orderData['total'].toDouble(),
            orderId: orderId,
            customerName: orderData['name'].toString(),
            customerEmail: orderData['email'].toString(),
            customerPhone: orderData['phone'].toString(),
            description:
                'Nabha Healthcare - Medicine Purchase (₹${orderData['total']})',
            notes: {
              'order_type': 'pharmacy',
              'customer_name': orderData['name'].toString(),
              'customer_address': orderData['address'].toString(),
              'pincode': orderData['pincode'].toString(),
              'items_count': orderData['items'].length.toString(),
              'total_amount': orderData['total'].toString(),
              'payment_timestamp': DateTime.now().toIso8601String(),
            },
          );
          print('🔥🔥🔥 PAYMENT_DEBUG: Payment initiation completed');
        }
      });
    } catch (e, stackTrace) {
      print('🔥🔥🔥 PAYMENT_DEBUG: ❌ Exception: $e');
      print('🔥🔥🔥 PAYMENT_DEBUG: Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Payment Setup Failed'),
                  ],
                ),
                SizedBox(height: 4),
                Text(e.toString(), style: TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _processRazorpayPayment(context, orderData),
            ),
          ),
        );
      }
    }
  }

  void _showOrderConfirmation(
      BuildContext context,
      Map<String, dynamic> orderData,
      PaymentSuccessResponse? paymentResponse) async {
    print('🛒 ORDER_SAVE_DEBUG: Saving order after payment');

    try {
      final currentUser = ref.read(userProvider);
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final cart = ref.read(cartProvider);
      final orderId = paymentResponse?.orderId ??
          'order_${DateTime.now().millisecondsSinceEpoch}';

      // Convert cart items to order items
      final orderItems = cart
          .map((cartItem) => OrderItem(
                medicineId: cartItem.medicine.id.toString(),
                name: cartItem.medicine.name,
                price: cartItem.medicine.price,
                quantity: cartItem.quantity,
                dosage: cartItem.medicine.type,
                manufacturer: cartItem.medicine.pharmacy,
              ))
          .toList();

      // Create customer info
      final customerInfo = OrderCustomerInfo(
        name: orderData['name'],
        email: orderData['email'],
        phone: orderData['phone'],
        address: orderData['address'],
        street: orderData['street'],
        pincode: orderData['pincode'],
      );

      // Create payment info
      final paymentInfo = OrderPaymentInfo(
        paymentMethod: orderData['paymentMethod'] == 'cod'
            ? PaymentMethod.cod
            : PaymentMethod.online,
        paymentStatus: paymentResponse != null
            ? PaymentStatus.completed
            : PaymentStatus.pending,
        paymentId: paymentResponse?.paymentId,
        transactionId: paymentResponse?.paymentId,
        paymentDate: paymentResponse != null ? DateTime.now() : null,
        amountPaid: orderData['total'].toDouble(),
      );

      // Create status history
      final statusHistory = <OrderStatusUpdate>[
        OrderStatusUpdate(
          status: OrderStatus.pending,
          timestamp: DateTime.now(),
          message: 'Order placed successfully',
        ),
        if (paymentResponse != null)
          OrderStatusUpdate(
            status: OrderStatus.confirmed,
            timestamp: DateTime.now(),
            message: 'Payment confirmed and order processing started',
          ),
      ];

      // Create the order
      final order = PharmacyOrder(
        orderId: orderId,
        userId: currentUser.id,
        items: orderItems,
        customerInfo: customerInfo,
        paymentInfo: paymentInfo,
        status: paymentResponse != null
            ? OrderStatus.confirmed
            : OrderStatus.pending,
        orderDate: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
        totalAmount: orderData['total'].toDouble(),
        deliveryFee: 0.0,
        statusHistory: statusHistory,
      );

      // Save the order
      final saved = await _orderService.saveOrder(order);

      if (saved) {
        print('✅ Order saved successfully: $orderId');

        // Clear cart
        ref.read(cartProvider.notifier).clearCart();

        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('Order Confirmed!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your order has been placed successfully.'),
                  const SizedBox(height: 8),
                  Text('Order ID: $orderId'),
                  const SizedBox(height: 8),
                  Text(
                      'Payment Method: ${orderData['paymentMethod'] == 'cod' ? 'Cash on Delivery' : 'Online Payment'}'),
                  if (paymentResponse != null) ...[
                    const SizedBox(height: 4),
                    Text('Payment ID: ${paymentResponse.paymentId}',
                        style: TextStyle(fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                      'We will send you order updates via email and SMS.'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close success dialog
                    Navigator.of(context).pop(); // Go back to cart
                    Navigator.of(context).pop(); // Go back to pharmacy
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception('Failed to save order');
      }
    } catch (e) {
      print('❌ Error saving order: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving order: $e'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
