import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import 'pharmacy_page.dart';
import 'checkout_page.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: AppColors.white),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: _buildCartItems(context, ref, cart),
                ),
                _buildCartSummary(context, ref),
              ],
            ),
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
            'Add some medicines to get started',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, WidgetRef ref, List<CartItem> cart) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      itemCount: cart.length,
      itemBuilder: (context, index) {
        final item = cart[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.mediumSpacing),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.medicine.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.medicine.type,
                            style: const TextStyle(
                              color: AppColors.grey600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${item.medicine.price.toStringAsFixed(2)} each',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref.read(cartProvider.notifier).removeFromCart(item.medicine.id);
                      },
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.mediumSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: item.quantity > 1 ? () {
                            ref.read(cartProvider.notifier).updateQuantity(
                              item.medicine.id,
                              item.quantity - 1,
                            );
                          } : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: item.quantity > 1 ? AppColors.primary : AppColors.grey400,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).updateQuantity(
                              item.medicine.id,
                              item.quantity + 1,
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    Text(
                      '₹${(item.medicine.price * item.quantity).toStringAsFixed(2)}',
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
          ),
        );
      },
    );
  }

  Widget _buildCartSummary(BuildContext context, WidgetRef ref) {
    final total = ref.watch(cartProvider.notifier).totalAmount;
    final itemCount = ref.watch(cartProvider).length;
    
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items ($itemCount)',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.grey600,
                  ),
                ),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey600,
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
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${(total + (total > 500 ? 0 : 50)).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}