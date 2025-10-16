import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/user_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final userName = user?.name ?? 'Guest';
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      color: AppColors.white,
                      onPressed: () {
                        // Handle notifications
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallSpacing),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.emergency),
                      color: AppColors.white,
                      onPressed: () {
                        _showEmergencyDialog(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.largeSpacing),
          
          // Health Status Card
          Container(
            padding: const EdgeInsets.all(AppConstants.mediumSpacing),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              border: Border.all(
                color: AppColors.white.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: AppConstants.mediumSpacing),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Status',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All vitals normal • Last updated 2 hours ago',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.white.withOpacity(0.7),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.emergency,
              color: AppColors.error,
            ),
            const SizedBox(width: 8),
            const Text('Emergency'),
          ],
        ),
        content: const Text(
          'In case of emergency, please call:\n\n• Emergency Services: 108\n• Ambulance: 102\n• Police: 100\n• Fire: 101',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle emergency call
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }
}