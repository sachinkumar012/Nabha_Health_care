import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../auth/domain/models/user.dart';
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
                Navigator.pushNamed(context, '/patient/auth');
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
                                            ref
                                                .read(cartProvider.notifier)
                                                .addToCart(medicine);
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

  void _showCheckoutDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    final _addressController = TextEditingController();
    final _streetController = TextEditingController();
    final _pincodeController = TextEditingController();
    String _selectedPaymentMethod = 'cod'; // 'cod' or 'online'

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
              if (_formKey.currentState!.validate()) {
                // Process the order
                final orderData = {
                  'name': _nameController.text.trim(),
                  'email': _emailController.text.trim(),
                  'phone': _phoneController.text.trim(),
                  'address': _addressController.text.trim(),
                  'street': _streetController.text.trim(),
                  'pincode': _pincodeController.text.trim(),
                  'paymentMethod': _selectedPaymentMethod,
                  'total': ref.read(cartProvider.notifier).totalAmount,
                  'items': ref.read(cartProvider),
                };

                Navigator.of(context).pop();
                _processOrder(context, orderData);
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
    // Show order confirmation
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
                        '#${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
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
                            : 'Online Payment',
                        style: const TextStyle(fontWeight: FontWeight.w500),
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
