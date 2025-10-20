import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../auth/domain/models/user.dart';
import '../../../../services/payment_service.dart';
import '../../data/models/order_model.dart';
import '../../data/services/order_storage_service.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';

// Medicine model
class Medicine {
  final int id;
  final String name;
  final String type;
  final bool availability;
  final String pharmacy;
  final double price;
  final String description;

  Medicine({
    required this.id,
    required this.name,
    required this.type,
    required this.availability,
    required this.pharmacy,
    required this.price,
    required this.description,
  });
}

// Cart item model
class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({
    required this.medicine,
    this.quantity = 1,
  });
}

// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(Medicine medicine) {
    final existingIndex =
        state.indexWhere((item) => item.medicine.id == medicine.id);

    if (existingIndex >= 0) {
      // Update quantity if item already exists
      state[existingIndex].quantity++;
      state = [...state];
    } else {
      // Add new item to cart
      state = [...state, CartItem(medicine: medicine)];
    }
  }

  void removeFromCart(int medicineId) {
    state = state.where((item) => item.medicine.id != medicineId).toList();
  }

  void updateQuantity(int medicineId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(medicineId);
      return;
    }

    final index = state.indexWhere((item) => item.medicine.id == medicineId);
    if (index >= 0) {
      state[index].quantity = quantity;
      state = [...state];
    }
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(
        0.0, (total, item) => total + (item.medicine.price * item.quantity));
  }

  int get totalItems {
    return state.fold(0, (total, item) => total + item.quantity);
  }
}

// Wishlist provider
final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<Medicine>>((ref) {
  return WishlistNotifier();
});

class WishlistNotifier extends StateNotifier<List<Medicine>> {
  WishlistNotifier() : super([]);

  void addToWishlist(Medicine medicine) {
    if (!state.any((item) => item.id == medicine.id)) {
      state = [...state, medicine];
    }
  }

  void removeFromWishlist(int medicineId) {
    state = state.where((medicine) => medicine.id != medicineId).toList();
  }

  void clearWishlist() {
    state = [];
  }

  bool isInWishlist(int medicineId) {
    return state.any((medicine) => medicine.id == medicineId);
  }
}

class PharmacyPage extends ConsumerStatefulWidget {
  const PharmacyPage({super.key});

  @override
  ConsumerState<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends ConsumerState<PharmacyPage> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  PaymentService? _paymentService;

  @override
  void initState() {
    super.initState();
    print('🏥🏥🏥 PHARMACY_DEBUG: PharmacyPage loaded!');
  }

  @override
  void dispose() {
    _paymentService?.dispose();
    super.dispose();
  }

  // Sample medicines data as requested
  final List<Medicine> _medicines = [
    Medicine(
      id: 1,
      name: 'Ecosprin 75 Tablet',
      type: 'Tablet',
      availability: true,
      pharmacy: 'Main Street Pharmacy',
      price: 25.0,
      description: 'Low-dose aspirin for cardiovascular protection',
    ),
    Medicine(
      id: 2,
      name: 'Paracetamol 500mg',
      type: 'Tablet',
      availability: true,
      pharmacy: 'City Center Pharmacy',
      price: 15.0,
      description: 'Pain relief and fever reducer',
    ),
    Medicine(
      id: 3,
      name: 'Amoxicillin 250mg',
      type: 'Capsule',
      availability: true,
      pharmacy: 'Health Plus Pharmacy',
      price: 120.0,
      description: 'Antibiotic for bacterial infections',
    ),
    Medicine(
      id: 4,
      name: 'Omeprazole 20mg',
      type: 'Capsule',
      availability: true,
      pharmacy: 'Quick Care Pharmacy',
      price: 80.0,
      description: 'Acid reflux and heartburn relief',
    ),
    Medicine(
      id: 5,
      name: 'Cetirizine 10mg',
      type: 'Tablet',
      availability: true,
      pharmacy: 'Downtown Pharmacy',
      price: 35.0,
      description: 'Antihistamine for allergies',
    ),
    Medicine(
      id: 6,
      name: 'Vitamin D3 60K IU',
      type: 'Capsule',
      availability: true,
      pharmacy: 'Wellness Pharmacy',
      price: 45.0,
      description: 'Vitamin D supplement',
    ),
    Medicine(
      id: 13,
      name: 'Salbutamol Inhaler',
      type: 'Inhaler',
      availability: false,
      pharmacy: 'Health Plus Pharmacy',
      price: 150.0,
      description: 'Bronchodilator for asthma',
    ),
    Medicine(
      id: 14,
      name: 'Diclofenac Gel',
      type: 'Ointment',
      availability: true,
      pharmacy: 'Downtown Pharmacy',
      price: 65.0,
      description: 'Topical pain relief gel',
    ),
    Medicine(
      id: 15,
      name: 'Loratadine 10mg',
      type: 'Tablet',
      availability: true,
      pharmacy: 'Quick Care Pharmacy',
      price: 40.0,
      description: 'Non-drowsy antihistamine',
    ),
    Medicine(
      id: 16,
      name: 'Simvastatin 20mg',
      type: 'Tablet',
      availability: false,
      pharmacy: 'Main Street Pharmacy',
      price: 90.0,
      description: 'Cholesterol lowering medication',
    ),
    Medicine(
      id: 17,
      name: 'Calcium Carbonate',
      type: 'Tablet',
      availability: true,
      pharmacy: 'Health Plus Pharmacy',
      price: 30.0,
      description: 'Calcium supplement',
    ),
    Medicine(
      id: 18,
      name: 'Hydrocortisone Cream',
      type: 'Ointment',
      availability: true,
      pharmacy: 'City Center Pharmacy',
      price: 55.0,
      description: 'Anti-inflammatory cream',
    ),
    Medicine(
      id: 19,
      name: 'Ranitidine 150mg',
      type: 'Tablet',
      availability: false,
      pharmacy: 'Downtown Pharmacy',
      price: 70.0,
      description: 'Acid reducer',
    ),
    Medicine(
      id: 20,
      name: 'Multivitamin Syrup',
      type: 'Syrup',
      availability: true,
      pharmacy: 'Quick Care Pharmacy',
      price: 85.0,
      description: 'Complete vitamin supplement',
    ),
  ];

  List<Medicine> get _filteredMedicines {
    List<Medicine> filtered = _medicines;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((medicine) =>
              medicine.name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              medicine.pharmacy
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply type filter
    if (_selectedFilter != 'All') {
      filtered = filtered
          .where((medicine) => medicine.type == _selectedFilter)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final cart = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          // Cart icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartPage(),
                    ),
                  );
                },
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${ref.read(cartProvider.notifier).totalItems}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Wishlist icon
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WishlistPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? _buildLoginPrompt()
          : _buildMedicineStore(context, cart, wishlist),
      bottomNavigationBar: user != null && cart.isNotEmpty
          ? _buildCheckoutBar(context, cart)
          : null,
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_pharmacy,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Nabha Pharmacy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Please login as a patient to browse medicines and place orders',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to login/auth page
                Navigator.pushNamed(context, AppRoutes.login);
              },
              icon: const Icon(Icons.login),
              label: const Text('Login as Patient'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineStore(
      BuildContext context, List<CartItem> cart, List<Medicine> wishlist) {
    return Column(
      children: [
        // Search and filter section
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.grey50,
          child: Column(
            children: [
              // Search bar
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search medicines or pharmacy...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'All',
                    'Tablet',
                    'Capsule',
                    'Syrup',
                    'Inhaler',
                    'Ointment'
                  ].map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // Medicine list
        Expanded(
          child: _filteredMedicines.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.grey400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No medicines found',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredMedicines.length,
                  itemBuilder: (context, index) {
                    final medicine = _filteredMedicines[index];
                    final isInWishlist = ref
                        .read(wishlistProvider.notifier)
                        .isInWishlist(medicine.id);
                    final isInCart =
                        cart.any((item) => item.medicine.id == medicine.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medicine.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.grey900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID: ${medicine.id}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.grey600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (isInWishlist) {
                                      ref
                                          .read(wishlistProvider.notifier)
                                          .removeFromWishlist(medicine.id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${medicine.name} removed from wishlist'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      ref
                                          .read(wishlistProvider.notifier)
                                          .addToWishlist(medicine);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${medicine.name} added to wishlist'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    isInWishlist
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isInWishlist
                                        ? AppColors.error
                                        : AppColors.grey400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    medicine.type,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  medicine.availability
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: medicine.availability
                                      ? AppColors.success
                                      : AppColors.error,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  medicine.availability
                                      ? 'Available'
                                      : 'Out of Stock',
                                  style: TextStyle(
                                    color: medicine.availability
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              medicine.pharmacy,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.grey700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              medicine.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.grey600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${medicine.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: medicine.availability
                                      ? () {
                                          if (isInCart) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    '${medicine.name} is already in cart'),
                                                duration:
                                                    const Duration(seconds: 2),
                                              ),
                                            );
                                          } else {
                                            print(
                                                '🛒🛒🛒 CART_DEBUG: Adding ${medicine.name} to cart');
                                            ref
                                                .read(cartProvider.notifier)
                                                .addToCart(medicine);
                                            print(
                                                '🛒🛒🛒 CART_DEBUG: Cart now has ${ref.read(cartProvider.notifier).totalItems} items');
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    '${medicine.name} added to cart'),
                                                duration:
                                                    const Duration(seconds: 2),
                                                action: SnackBarAction(
                                                  label: 'View Cart',
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const CartPage(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                  icon: Icon(
                                    isInCart
                                        ? Icons.check
                                        : Icons.add_shopping_cart,
                                    size: 16,
                                  ),
                                  label: Text(
                                    isInCart ? 'In Cart' : 'Add to Cart',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isInCart
                                        ? AppColors.success
                                        : medicine.availability
                                            ? AppColors.primary
                                            : AppColors.grey400,
                                    foregroundColor: AppColors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context, List<CartItem> cart) {
    final totalAmount = ref.read(cartProvider.notifier).totalAmount;
    final totalItems = ref.read(cartProvider.notifier).totalItems;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.grey300, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Cart summary
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$totalItems items in cart',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Checkout button
            ElevatedButton.icon(
              onPressed: () => _showCheckoutDialog(context),
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    final _addressController = TextEditingController();
    final _streetController = TextEditingController();
    final _pincodeController = TextEditingController();
    String _selectedPaymentMethod = 'cod'; // 'cod' or 'online'

    print('🛒🛒🛒 CHECKOUT_DIALOG_DEBUG: Opening checkout dialog');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${ref.read(cartProvider.notifier).totalItems} items',
                          style: const TextStyle(color: AppColors.grey600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ₹${ref.read(cartProvider.notifier).totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Customer Information
                  const Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Email field
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
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Phone field
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
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Address field
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
                  const SizedBox(height: 12),

                  // Street field
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(
                      labelText: 'Street/Landmark',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pincode field
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
                        return 'Please enter a valid 6-digit pincode';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Payment Method
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment options
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Row(
                            children: [
                              Icon(Icons.money, color: AppColors.success),
                              SizedBox(width: 8),
                              Text('Cash on Delivery'),
                            ],
                          ),
                          subtitle:
                              const Text('Pay when you receive your order'),
                          value: 'cod',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            Navigator.of(context).pop();
                            _selectedPaymentMethod = value!;
                            _showCheckoutDialog(context);
                          },
                        ),
                        const Divider(height: 1),
                        RadioListTile<String>(
                          title: const Row(
                            children: [
                              Icon(Icons.payment, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Online Payment'),
                            ],
                          ),
                          subtitle: const Text(
                              'Pay securely using UPI, Cards, or Wallets'),
                          value: 'online',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            Navigator.of(context).pop();
                            _selectedPaymentMethod = value!;
                            _showCheckoutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Delivery Information
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.local_shipping, color: AppColors.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Free delivery within 2-3 business days',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              print('🚨🚨🚨 CHECKOUT_DEBUG: Checkout button pressed!');
              if (_formKey.currentState!.validate()) {
                print('🚨🚨🚨 CHECKOUT_DEBUG: Form validation passed!');
                // Process the order
                final cartItems = ref.read(cartProvider);
                final totalAmount = ref.read(cartProvider.notifier).totalAmount;

                print(
                    '🚨🚨🚨 CHECKOUT_DEBUG: Cart items at checkout: ${cartItems.length}');
                print('🚨🚨🚨 CHECKOUT_DEBUG: Total amount: ₹$totalAmount');

                final orderData = {
                  'name': _nameController.text.trim(),
                  'email': _emailController.text.trim(),
                  'phone': _phoneController.text.trim(),
                  'address': _addressController.text.trim(),
                  'street': _streetController.text.trim(),
                  'pincode': _pincodeController.text.trim(),
                  'paymentMethod': _selectedPaymentMethod,
                  'total': totalAmount,
                  'items': cartItems,
                };

                print('🚨🚨🚨 CHECKOUT_DEBUG: OrderData created: $orderData');
                Navigator.of(context).pop();
                print('🚨🚨🚨 CHECKOUT_DEBUG: About to call _processOrder');
                _processOrder(context, orderData);
              } else {
                print('🚨🚨🚨 CHECKOUT_DEBUG: Form validation FAILED!');
              }
            },
            icon: Icon(
                _selectedPaymentMethod == 'cod' ? Icons.money : Icons.payment),
            label: Text(_selectedPaymentMethod == 'cod'
                ? 'Place Order (COD)'
                : 'Pay Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _processOrder(BuildContext context, Map<String, dynamic> orderData) {
    print(
        '🔥🔥🔥 PAYMENT_DEBUG: _processOrder called with paymentMethod: ${orderData['paymentMethod']}');
    print('🔥🔥🔥 PAYMENT_DEBUG: Full orderData: $orderData');

    if (orderData['paymentMethod'] == 'online') {
      print('🔥🔥🔥 PAYMENT_DEBUG: Processing online payment via Razorpay');
      _processRazorpayPayment(context, orderData);
    } else {
      print(
          '🔥🔥🔥 PAYMENT_DEBUG: Processing Cash on Delivery - showing order confirmation directly');
      // Cash on Delivery
      _showOrderConfirmation(context, orderData, null);
    }
  }

  void _processRazorpayPayment(
      BuildContext context, Map<String, dynamic> orderData) {
    print(
        '🔥🔥🔥 PAYMENT_DEBUG: _processRazorpayPayment called with orderData: $orderData');

    try {
      // Dispose previous payment service if exists
      _paymentService?.dispose();

      // Create new payment service
      _paymentService = PaymentService(context: context);

      // Generate order ID for tracking
      final orderId = 'NH${DateTime.now().millisecondsSinceEpoch}';

      debugPrint('Starting Razorpay payment for order: $orderId');
      debugPrint('Payment amount: ${orderData['total']}');
      debugPrint('Customer: ${orderData['name']} (${orderData['email']})');

      print('🔥🔥🔥 PAYMENT_DEBUG: Setting up payment callbacks');

      // Setup payment callbacks
      _paymentService!.onPaymentSuccess = (PaymentSuccessResponse response) {
        print('🔥🔥🔥 PAYMENT_DEBUG: Payment success callback triggered');
        print('🔥🔥🔥 PAYMENT_DEBUG: Payment ID: ${response.paymentId}');
        print('🔥🔥🔥 PAYMENT_DEBUG: Order ID: ${response.orderId}');
        print('🔥🔥🔥 PAYMENT_DEBUG: Signature: ${response.signature}');

        // Hide any loading indicators
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Payment successful! Order confirmed.'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Process order confirmation
          _showOrderConfirmation(context, orderData, response);
        }
      };

      _paymentService!.onPaymentFailure = (PaymentFailureResponse response) {
        print('🔥🔥🔥 PAYMENT_DEBUG: Payment failure callback triggered');
        print('🔥🔥🔥 PAYMENT_DEBUG: Error Code: ${response.code}');
        print('🔥🔥🔥 PAYMENT_DEBUG: Error Message: ${response.message}');

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();

          String errorMessage = 'Payment failed';
          if (response.message != null) {
            errorMessage = response.message!;
          }

          // Show user-friendly error messages
          if (response.code == Razorpay.PAYMENT_CANCELLED) {
            errorMessage = 'Payment was cancelled by user';
          } else if (response.code == Razorpay.NETWORK_ERROR) {
            errorMessage =
                'Network error. Please check your internet connection.';
          } else if (response.code == Razorpay.TLS_ERROR) {
            errorMessage = 'Security error. Please try again.';
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
        print('🔥🔥🔥 PAYMENT_DEBUG: External wallet callback triggered');
        print('🔥🔥🔥 PAYMENT_DEBUG: Wallet: ${response.walletName}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Opening ${response.walletName}...'),
                ],
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      };

      print('🔥🔥🔥 PAYMENT_DEBUG: Showing loading indicator');

      // Show improved loading indicator
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

      print(
          '🔥🔥🔥 PAYMENT_DEBUG: About to start payment with enhanced validation');

      // Validate order data before proceeding
      if (orderData['total'] == null || orderData['total'] <= 0) {
        throw Exception('Invalid payment amount');
      }

      if (orderData['name'] == null || orderData['name'].toString().isEmpty) {
        throw Exception('Customer name is required');
      }

      if (orderData['email'] == null || orderData['email'].toString().isEmpty) {
        throw Exception('Customer email is required');
      }

      if (orderData['phone'] == null || orderData['phone'].toString().isEmpty) {
        throw Exception('Customer phone is required');
      }

      // Start payment with enhanced parameters
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _paymentService != null) {
          print('🔥🔥🔥 PAYMENT_DEBUG: Executing payment with validated data');
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
        } else {
          print(
              '🔥🔥🔥 PAYMENT_DEBUG: Payment cancelled - widget unmounted or service null');
        }
      });

      print('🔥🔥🔥 PAYMENT_DEBUG: _processRazorpayPayment method completing');
    } catch (e, stackTrace) {
      print('🔥🔥🔥 PAYMENT_DEBUG: Exception in _processRazorpayPayment: $e');
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
                    Text('Payment Initialization Failed'),
                  ],
                ),
                SizedBox(height: 4),
                Text(e.toString(), style: TextStyle(fontSize: 12)),
                SizedBox(height: 8),
                Text(
                    'Please try again or contact support if the issue persists.',
                    style: TextStyle(
                        fontSize: 11, color: Colors.white.withOpacity(0.8))),
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
    print('🛒 ORDER_SAVE_DEBUG: _showOrderConfirmation called');
    print('🛒 ORDER_SAVE_DEBUG: orderData = $orderData');
    print('🛒 ORDER_SAVE_DEBUG: paymentResponse = $paymentResponse');

    final orderId = paymentResponse?.orderId ??
        'order_${DateTime.now().millisecondsSinceEpoch}';
    print('🛒 ORDER_SAVE_DEBUG: Generated orderId = $orderId');

    // Save order to local storage
    try {
      final orderStorageService = OrderStorageService();
      final currentUser = ref.read(userProvider);

      print('🛒 ORDER_SAVE_DEBUG: currentUser = ${currentUser?.id}');

      if (currentUser != null) {
        // Convert cart items to order items
        final cartItems = ref.read(cartProvider);
        print('🛒 ORDER_SAVE_DEBUG: cartItems count = ${cartItems.length}');

        final orderItems = cartItems
            .map((cartItem) => OrderItem(
                  medicineId: cartItem.medicine.id.toString(),
                  name: cartItem.medicine.name,
                  price: cartItem.medicine.price,
                  quantity: cartItem.quantity,
                  dosage:
                      cartItem.medicine.type, // Using type as dosage for now
                  manufacturer: cartItem.medicine.pharmacy,
                ))
            .toList();

        print(
            '🛒 ORDER_SAVE_DEBUG: orderItems created, count = ${orderItems.length}');

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

        // Create initial status history
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

        print('🛒 ORDER_SAVE_DEBUG: Creating order object...');

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

        print('🛒 ORDER_SAVE_DEBUG: Order object created successfully');
        print('🛒 ORDER_SAVE_DEBUG: Order ID = ${order.orderId}');
        print('🛒 ORDER_SAVE_DEBUG: User ID = ${order.userId}');
        print('🛒 ORDER_SAVE_DEBUG: Items count = ${order.items.length}');
        print('🛒 ORDER_SAVE_DEBUG: Total amount = ${order.totalAmount}');

        // Test JSON serialization
        try {
          final orderJson = order.toJson();
          print('🛒 ORDER_SAVE_DEBUG: ✅ Order JSON serialization successful');
          print(
              '🛒 ORDER_SAVE_DEBUG: JSON preview: ${orderJson.toString().substring(0, 100)}...');
        } catch (jsonError) {
          print(
              '🛒 ORDER_SAVE_DEBUG: ❌ Order JSON serialization failed: $jsonError');
        }

        // Save the order
        print('🛒 ORDER_SAVE_DEBUG: About to save order...');
        final saved = await orderStorageService.saveOrder(order);
        print('🛒 ORDER_SAVE_DEBUG: Save operation completed, result = $saved');

        // Immediate verification - check if order was actually saved
        try {
          final allOrdersAfterSave = await orderStorageService.getAllOrders();
          print(
              '🛒 ORDER_SAVE_DEBUG: 🔍 Total orders after save: ${allOrdersAfterSave.length}');

          final userOrdersAfterSave =
              await orderStorageService.getOrdersForUser(currentUser.id);
          print(
              '🛒 ORDER_SAVE_DEBUG: 🔍 User orders after save: ${userOrdersAfterSave.length}');

          final savedOrder =
              await orderStorageService.getOrderById(order.orderId);
          if (savedOrder != null) {
            print(
                '🛒 ORDER_SAVE_DEBUG: ✅ Order verification successful - order found by ID');
          } else {
            print(
                '🛒 ORDER_SAVE_DEBUG: ❌ Order verification failed - order not found by ID');
          }
        } catch (verifyError) {
          print(
              '🛒 ORDER_SAVE_DEBUG: ❌ Order verification error: $verifyError');
        }

        if (saved) {
          print('✅ Order saved successfully with ID: ${order.orderId}');
          print('👤 User ID: ${currentUser.id}');
          print('📦 Items count: ${order.items.length}');
          print('💰 Total amount: ₹${order.totalAmount}');
        } else {
          print('❌ Failed to save order');
        }
      } else {
        print('🛒 ORDER_SAVE_DEBUG: ❌ currentUser is null!');
      }
    } catch (e) {
      print('🛒 ORDER_SAVE_DEBUG: ❌ Exception in order saving: $e');
      print('🛒 ORDER_SAVE_DEBUG: ❌ Stack trace: ${StackTrace.current}');
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            SizedBox(width: 12),
            Text('Order Confirmed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thank you, ${orderData['name']}!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order ID:'),
                      Text(
                        '#${orderId.substring(orderId.length > 10 ? orderId.length - 10 : 0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (paymentResponse != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Payment ID:'),
                        Text(
                          paymentResponse.paymentId ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:'),
                      Text(
                        '₹${orderData['total'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payment:'),
                      Text(
                        orderData['paymentMethod'] == 'cod'
                            ? 'Cash on Delivery'
                            : 'Online Payment ✓',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: orderData['paymentMethod'] == 'cod'
                              ? AppColors.grey700
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '📧 Order confirmation sent to your email\n🚚 Expected delivery: 2-3 business days\n📱 You will receive SMS updates',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to order history
              Navigator.pushNamed(context, AppRoutes.orderHistory);
            },
            child: const Text('View Orders'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    orderData['paymentMethod'] == 'cod'
                        ? 'Order placed successfully! Pay on delivery.'
                        : 'Payment successful! Order confirmed.',
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 3),
                ),
              );
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
}
