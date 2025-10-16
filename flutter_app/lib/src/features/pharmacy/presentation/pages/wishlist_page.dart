import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import 'pharmacy_page.dart';
import 'cart_page.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          if (wishlist.isNotEmpty)
            TextButton(
              onPressed: () {
                _showClearWishlistDialog(context, ref);
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: AppColors.white),
              ),
            ),
        ],
      ),
      body: wishlist.isEmpty
          ? _buildEmptyWishlist()
          : _buildWishlistItems(context, ref, wishlist),
    );
  }

  Widget _buildEmptyWishlist() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: AppColors.grey400,
          ),
          SizedBox(height: 24),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Add medicines you love to your wishlist',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItems(BuildContext context, WidgetRef ref, List<Medicine> wishlist) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      itemCount: wishlist.length,
      itemBuilder: (context, index) {
        final medicine = wishlist[index];
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
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medication,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: AppConstants.mediumSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            medicine.type,
                            style: const TextStyle(
                              color: AppColors.grey600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            medicine.pharmacy,
                            style: const TextStyle(
                              color: AppColors.grey600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '₹${medicine.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: medicine.availability 
                                      ? AppColors.success.withOpacity(0.1)
                                      : AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  medicine.availability ? 'Available' : 'Out of Stock',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: medicine.availability 
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref.read(wishlistProvider.notifier).removeFromWishlist(medicine.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${medicine.name} removed from wishlist'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite),
                      color: AppColors.error,
                    ),
                  ],
                ),
                if (medicine.description.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.mediumSpacing),
                  Text(
                    medicine.description,
                    style: const TextStyle(
                      color: AppColors.grey600,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: AppConstants.mediumSpacing),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: medicine.availability ? () {
                          ref.read(cartProvider.notifier).addToCart(medicine);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${medicine.name} added to cart'),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'View Cart',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CartPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        } : null,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: medicine.availability 
                              ? AppColors.primary
                              : AppColors.grey400,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(wishlistProvider.notifier).removeFromWishlist(medicine.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${medicine.name} removed from wishlist'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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

  void _showClearWishlistDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text('Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(wishlistProvider.notifier).clearWishlist();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wishlist cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}