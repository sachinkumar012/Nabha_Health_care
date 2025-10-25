import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../../auth/domain/models/user.dart';
import 'complete_profile_page.dart';

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
              // First refresh from backend, then fallback to local reload
              await ref.read(userProvider.notifier).refreshFromBackend();
              await ref.read(userProvider.notifier).reloadUser();
            },
          ),
        ],
      ),
      body: user == null
          ? _buildNotLoggedInState(context, ref)
          : _buildUserProfile(context, ref, user),
    );
  }

  Widget _buildNotLoggedInState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
            const SizedBox(height: 32),

            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.login);
                },
                icon: const Icon(Icons.login, color: AppColors.white),
                label: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.register);
                },
                icon: const Icon(Icons.person_add, color: AppColors.primary),
                label: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Refresh Profile Button (smaller, less prominent)
            TextButton.icon(
              onPressed: () async {
                // First refresh from backend, then fallback to local reload
                await ref.read(userProvider.notifier).refreshFromBackend();
                await ref.read(userProvider.notifier).reloadUser();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh Profile'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    print('📸 IMAGE_DEBUG: Displaying image with URL: $imageUrl');

    return Consumer(
      builder: (context, ref, child) {
        return GestureDetector(
          onTap: () => _showImagePickerOptions(context, ref),
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: imageUrl.isEmpty
                      ? Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        )
                      : _buildImageWidget(imageUrl),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    // Check if it's a local file path or network URL
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      print('📸 IMAGE_DEBUG: Using Image.network for URL: $imageUrl');
      // Network image
      return Image.network(
        imageUrl,
        width: 114,
        height: 114,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ IMAGE_DEBUG: Network image error: $error');
          return Container(
            color: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 60,
              color: AppColors.primary,
            ),
          );
        },
      );
    } else {
      print('📸 IMAGE_DEBUG: Using Image.file for path: $imageUrl');
      // Local file
      final file = File(imageUrl);
      print('📸 IMAGE_DEBUG: File exists: ${file.existsSync()}');

      return Image.file(
        file,
        width: 114,
        height: 114,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ IMAGE_DEBUG: Local file error: $error');
          return Container(
            color: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 60,
              color: AppColors.primary,
            ),
          );
        },
      );
    }
  }

  Widget _buildUserProfile(BuildContext context, WidgetRef ref, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      child: Column(
        children: [
          _buildProfileCompletion(context, ref, user),
          const SizedBox(height: AppConstants.extraLargeSpacing),
          _buildProfileDetails(user),
          const SizedBox(height: AppConstants.extraLargeSpacing),
          _buildAccountActions(context, ref),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref, User? user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildProfileImage(user?.profileImageUrl ?? ''),
          const SizedBox(height: AppConstants.mediumSpacing),
          Text(
            user?.name ?? 'Guest',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
          ),
          if (user?.email != null) ...[
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              user!.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey600,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileDetails(User user) {
    return Column(
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
        if (user.dateOfBirth != null)
          _buildInfoRow('Date of Birth', user.dateOfBirth!),
        if (user.gender != null) _buildInfoRow('Gender', user.gender!),
        _buildInfoRow('Member Since', _formatDate(user.createdAt)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.mediumSpacing),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.mediumSpacing,
        vertical: AppConstants.smallSpacing,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.grey200,
          width: 1,
        ),
      ),
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
                fontSize: 14,
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
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletion(
      BuildContext context, WidgetRef ref, User user) {
    final completionPercentage = user.profileCompletionPercentage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image and Info Row
          Row(
            children: [
              // Profile Image
              GestureDetector(
                onTap: () => _showImagePickerOptions(context, ref),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: ClipOval(
                    child: user.profileImageUrl?.isNotEmpty == true
                        ? Image.network(
                            user.profileImageUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.primary.withOpacity(0.1),
                                child: const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              size: 30,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'View and edit profile',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 12),

          // Completion percentage badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: completionPercentage == 100
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$completionPercentage% completed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: completionPercentage == 100
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Care Plan Section (if profile is complete)
          if (completionPercentage >= 80) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: AppColors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Care Plan',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '12 FREE Appointments for a Year',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: AppColors.white, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Complete Profile Button (if not 100% complete)
          if (completionPercentage < 100)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CompleteProfilePage(),
                    ),
                  );

                  // If profile was updated, refresh the current page
                  if (result == true) {
                    // The user provider will automatically update
                  }
                },
                icon: const Icon(Icons.edit, color: AppColors.white),
                label: const Text(
                  'Complete Profile',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

          // Modify Profile Button (if 100% complete)
          if (completionPercentage == 100)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CompleteProfilePage(),
                    ),
                  );

                  // If profile was updated, refresh the current page
                  if (result == true) {
                    // The user provider will automatically update
                  }
                },
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                label: const Text(
                  'Modify Profile',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context, WidgetRef ref) {
    return Column(
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
          icon: Icons.shopping_bag_outlined,
          title: 'My Orders',
          subtitle: 'View your order history and track orders',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.orderHistory);
          },
        ),
        const SizedBox(height: AppConstants.smallSpacing),
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
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
      decoration: BoxDecoration(
        color: isDestructive
            ? AppColors.error.withOpacity(0.05)
            : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive
              ? AppColors.error.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.mediumSpacing,
          vertical: AppConstants.smallSpacing,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.error.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? AppColors.error : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppColors.error : AppColors.grey900,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.grey600,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.grey400,
          size: 20,
        ),
        onTap: onTap,
      ),
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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(AppConstants.mediumSpacing),
          padding: const EdgeInsets.all(AppConstants.largeSpacing),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.mediumSpacing),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.largeSpacing),

              // Form Fields
              _buildEditField(
                controller: nameController,
                label: 'Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              _buildEditField(
                controller: phoneController,
                label: 'Phone',
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              _buildEditField(
                controller: addressController,
                label: 'Address',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: AppConstants.largeSpacing),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.grey300),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.mediumSpacing),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await ref.read(userProvider.notifier).updateProfile(
                                name: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                                address: addressController.text.trim().isEmpty
                                    ? null
                                    : addressController.text.trim(),
                              );

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully!'),
                                backgroundColor: AppColors.success,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: const TextStyle(color: AppColors.grey600),
        ),
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

  void _showImagePickerOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppConstants.mediumSpacing),
            const Text(
              'Update Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera, ref, context);
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery, ref, context);
                  },
                ),
                if (ref.read(userProvider)?.profileImageUrl != null)
                  _buildImagePickerOption(
                    icon: Icons.delete,
                    label: 'Remove',
                    onTap: () {
                      Navigator.pop(context);
                      _removeProfileImage(ref, context);
                    },
                    isDestructive: true,
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.largeSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isDestructive ? AppColors.error : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDestructive ? AppColors.error : AppColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
      ImageSource source, WidgetRef ref, BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('📸 IMAGE_DEBUG: Selected image path: ${pickedFile.path}');

        // Show loading dialog
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text('Uploading image...'),
                  ],
                ),
              );
            },
          );
        }

        try {
          print('📸 IMAGE_DEBUG: Starting backend upload process...');

          // Upload to backend (Cloudinary + database)
          await ref.read(userProvider.notifier).uploadProfileImage(
                File(pickedFile.path),
              );

          print('📸 IMAGE_DEBUG: Backend upload completed successfully');

          // Close loading dialog
          if (context.mounted) {
            Navigator.of(context).pop();
          }

          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile image updated successfully!'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (uploadError) {
          print('❌ IMAGE_DEBUG: Error during backend upload: $uploadError');

          // Close loading dialog
          if (context.mounted) {
            Navigator.of(context).pop();
          }

          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Failed to upload image: ${uploadError.toString()}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: AppColors.white,
                  onPressed: () {
                    _pickImage(source, ref, context);
                  },
                ),
              ),
            );
          }
        }
      } else {
        print('📸 IMAGE_DEBUG: No image selected');
      }
    } catch (e) {
      print('❌ IMAGE_DEBUG: Error in _pickImage: $e');

      // Make sure loading dialog is closed
      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {
          // Dialog might not be open
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _removeProfileImage(WidgetRef ref, BuildContext context) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Removing image...'),
                ],
              ),
            );
          },
        );
      }

      // Use backend API to update profile with null avatar
      await ref.read(userProvider.notifier).updateProfileViaApi();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image removed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {
          // Dialog might not be open
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing profile image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
