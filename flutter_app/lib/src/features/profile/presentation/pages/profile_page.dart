import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../auth/domain/models/user.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          if (user != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditProfileDialog(context, ref, user);
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _showLogoutDialog(context, ref);
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref.read(userProvider.notifier).reloadUser();
            },
          ),
        ],
      ),
      body: user == null
          ? _buildNotLoggedInState(ref)
          : _buildUserProfile(context, ref, user),
    );
  }

  Widget _buildNotLoggedInState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_off,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Not Logged In',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please sign up or login to view your profile',
            style: TextStyle(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(userProvider.notifier).reloadUser();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, WidgetRef ref, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      child: Column(
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: AppConstants.extraLargeSpacing),
          _buildProfileDetails(user),
          const SizedBox(height: AppConstants.extraLargeSpacing),
          _buildAccountActions(context, ref),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
            child: user.profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.profileImageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  ),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          Text(
            user.name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.mediumSpacing,
              vertical: AppConstants.smallSpacing,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.userType.toUpperCase(),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(User user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildInfoRow('Name', user.name),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Phone', user.phone),
            _buildInfoRow('User Type', user.userType),
            if (user.address != null) _buildInfoRow('Address', user.address!),
            if (user.dateOfBirth != null) _buildInfoRow('Date of Birth', user.dateOfBirth!),
            if (user.gender != null) _buildInfoRow('Gender', user.gender!),
            _buildInfoRow('Member Since', _formatDate(user.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.mediumSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.grey600,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.mediumSpacing),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: AppColors.grey900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            _buildActionButton(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update your personal information',
              onTap: () {
                final user = ref.read(userProvider);
                if (user != null) {
                  _showEditProfileDialog(context, ref, user);
                }
              },
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            _buildActionButton(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              isDestructive: true,
              onTap: () {
                _showLogoutDialog(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppColors.error : AppColors.grey900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.grey600,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.grey400,
      ),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, User user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final addressController = TextEditingController(text: user.address ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(userProvider.notifier).updateProfile(
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim().isEmpty 
                      ? null : addressController.text.trim(),
                );
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating profile: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(userProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
