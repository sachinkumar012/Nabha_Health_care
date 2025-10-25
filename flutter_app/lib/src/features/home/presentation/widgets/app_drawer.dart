import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/user_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.white,
                    backgroundImage: user?.profileImageUrl != null
                        ? NetworkImage(user!.profileImageUrl!)
                        : null,
                    child: user?.profileImageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Sachin Rai',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: const Text(
                      'View and edit profile',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '9% completed',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Care Plan Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF4A4AE8),
                    const Color(0xFF6B6BF7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Care Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '12 FREE Appointments for a Year',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    icon: Icons.local_hospital,
                    title: 'ABHA',
                    color: const Color(0xFF00BCD4),
                    onTap: () => _navigateToPage(context, '/abha'),
                  ),
                  _buildMenuItem(
                    icon: Icons.calendar_today,
                    title: 'Appointments',
                    color: const Color(0xFF2196F3),
                    onTap: () => _navigateToPage(context, '/appointments'),
                  ),
                  _buildMenuItem(
                    icon: Icons.science,
                    title: 'Test Bookings',
                    color: const Color(0xFF00BCD4),
                    onTap: () => _navigateToPage(context, '/test-bookings'),
                  ),
                  _buildMenuItem(
                    icon: Icons.shopping_bag,
                    title: 'Orders',
                    color: const Color(0xFF673AB7),
                    onTap: () =>
                        _navigateToPage(context, AppRoutes.orderHistory),
                  ),
                  _buildMenuItem(
                    icon: Icons.chat_bubble_outline,
                    title: 'Consultations',
                    color: const Color(0xFF00BCD4),
                    onTap: () => _navigateToPage(context, '/consultations'),
                  ),
                  _buildMenuItem(
                    icon: Icons.people,
                    title: 'My Doctors',
                    color: const Color(0xFF2196F3),
                    onTap: () => _navigateToPage(context, '/my-doctors'),
                  ),
                  _buildMenuItem(
                    icon: Icons.folder_shared,
                    title: 'Medical Records',
                    color: const Color(0xFF00BCD4),
                    onTap: () => _navigateToPage(context, '/health-records'),
                  ),
                  _buildMenuItem(
                    icon: Icons.security,
                    title: 'My Insurance Policy',
                    color: const Color(0xFF00BCD4),
                    onTap: () => _navigateToPage(context, '/insurance'),
                  ),
                  _buildMenuItem(
                    icon: Icons.access_time,
                    title: 'Reminders',
                    color: const Color(0xFF00BCD4),
                    onTap: () => _navigateToPage(context, '/reminders'),
                  ),
                  _buildMenuItem(
                    icon: Icons.payment,
                    title: 'Payments & HealthCash',
                    color: const Color(0xFF2196F3),
                    onTap: () => _navigateToPage(context, '/payments'),
                  ),
                  _buildMenuItem(
                    icon: Icons.local_pharmacy,
                    title: 'Pharmacy',
                    color: const Color(0xFF4CAF50),
                    onTap: () => _navigateToPage(context, '/pharmacy'),
                  ),
                  _buildMenuItem(
                    icon: Icons.video_call,
                    title: 'Video Consultation',
                    color: const Color(0xFF9C27B0),
                    onTap: () => _navigateToPage(context, '/video-consultation'),
                  ),
                  _buildMenuItem(
                    icon: Icons.psychology,
                    title: 'Symptom Checker',
                    color: const Color(0xFFFF9800),
                    onTap: () => _navigateToPage(context, '/symptom-checker'),
                  ),
                  _buildMenuItem(
                    icon: Icons.local_hospital,
                    title: 'Find Hospitals',
                    color: const Color(0xFFF44336),
                    onTap: () => _navigateToPage(context, '/hospitals'),
                  ),
                  const Divider(height: 32),
                  _buildMenuItem(
                    icon: Icons.article,
                    title: 'Read about health',
                    color: AppColors.grey600,
                    onTap: () => _navigateToPage(context, '/health-articles'),
                  ),
                  _buildMenuItem(
                    icon: Icons.help_center,
                    title: 'Help Center',
                    color: AppColors.grey600,
                    onTap: () => _navigateToPage(context, '/help'),
                  ),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    color: AppColors.grey600,
                    onTap: () => _navigateToPage(context, '/settings'),
                  ),
                  _buildMenuItem(
                    icon: Icons.thumb_up,
                    title: 'Like us? Give us 5 stars',
                    color: AppColors.grey600,
                    onTap: () => _showRatingDialog(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.medical_services,
                    title: 'Are you a doctor?',
                    color: AppColors.grey600,
                    onTap: () => _navigateToPage(context, '/doctor-signup'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.grey800,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.grey400,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _navigateToPage(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer c
    
    print('🔍 DEBUG: Navigating to route: $route');

    // Check if route exists in app routes
    if (route == '/pharmacy' ||
        route == '/hospitals' ||
        route == '/symptom-checker' ||
        route == '/video-consultation' ||
        route == '/health-records' ||
        route == '/appointments' ||
        route == '/abha' ||
        route == AppRoutes.orderHistory) {
      print('✅ DEBUG: Route found, navigating to: $route');
      Navigator.pushNamed(context, route);
    } else {
      print('❌ DEBUG: Route not found, showing coming soon for: $route');
      // Show coming soon for unimplemented features
      _showComingSoonDialog(context, route);
    }
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text(
            '${feature.replaceAll('/', '').replaceAll('-', ' ').toUpperCase()} feature is under development.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Our App'),
        content: const Text('Would you like to rate our app on the app store?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add app store rating logic here
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }
}
