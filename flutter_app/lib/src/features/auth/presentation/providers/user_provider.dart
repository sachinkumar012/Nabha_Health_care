import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import '../../domain/models/user.dart';
import '../../../home/data/chat_storage_service.dart';
import '../../../../services/profile_service.dart';
import '../../../../services/cloudinary_service.dart';

// User state provider
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

// Authentication state provider
final authStateProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider);
  return user != null;
});

// Loading state provider
final userLoadingProvider = StateProvider<bool>((ref) => true);

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null) {
    _loadUserFromStorage();
  }

  // Load user from local storage
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');

      print('DEBUG: Loading user from storage, userJson: $userJson');

      if (userJson != null && userJson.isNotEmpty) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        final user = User.fromJson(userMap);
        state = user;
        print('DEBUG: User loaded successfully: ${user.name} (${user.email})');
      } else {
        state = null;
        print('DEBUG: No user data found in storage');
      }
    } catch (e) {
      // Handle error - user not found or corrupted data
      print('DEBUG: Error loading user from storage: $e');
      state = null;
    }
  }

  // Save user to local storage
  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString('user_data', userJson);

      // Also save to users database (for persistent login)
      await _saveUserToDatabase(user);
    } catch (e) {
      // Handle error
      throw Exception('Failed to save user data');
    }
  }

  Future<User?> _getUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');

      if (userJson != null && userJson.isNotEmpty) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('ERROR: Failed to get user from storage: $e');
      return null;
    }
  }

  Future<void> _saveUserToDatabase(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing users database
      List<String> usersDb = prefs.getStringList('users_database') ?? [];

      // Remove existing user with same email if exists
      usersDb.removeWhere((userString) {
        final userData = json.decode(userString);
        return userData['email'] == user.email;
      });

      // Add the user
      usersDb.add(json.encode(user.toJson()));

      // Save back to database
      await prefs.setStringList('users_database', usersDb);
      print('DEBUG: User added to permanent database');
    } catch (e) {
      print('ERROR: Failed to save user to database: $e');
    }
  }

  Future<User?> _getUserFromDatabase(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> usersDb = prefs.getStringList('users_database') ?? [];

      for (String userString in usersDb) {
        final userData = json.decode(userString);
        if (userData['email'] == email) {
          return User.fromJson(userData);
        }
      }
      return null;
    } catch (e) {
      print('ERROR: Failed to get user from database: $e');
      return null;
    }
  }

  // Initialize provider with stored user data and refresh from backend
  Future<void> initializeUser() async {
    final user = await _getUserFromStorage();
    if (user != null) {
      state = user;
      print('DEBUG: User initialized from storage: ${user.name}');

      // Try to refresh user data from backend in the background
      try {
        await refreshFromBackend();
      } catch (e) {
        print('DEBUG: Background refresh from backend failed: $e');
        // Continue with local data
      }
    }
  }

  // Register new user
  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String userType,
  }) async {
    try {
      print('DEBUG: Registering user: $name ($email)');

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Generate a simple user ID (in real app, this would come from the server)
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

      final newUser = User(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        userType: userType,
        createdAt: DateTime.now(),
      );

      state = newUser;
      await _saveUserToStorage(newUser);
      print('DEBUG: User registration completed, state updated');
    } catch (e) {
      print('DEBUG: Registration error: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login user with backend integration
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting backend login for: $email');

      // Try backend authentication first
      final response = await ProfileService.login(
        email: email,
        password: password,
      );

      if (response['success'] == true && response['data'] != null) {
        print('✅ Backend login successful');

        // Save authentication token
        final prefs = await SharedPreferences.getInstance();
        final token = response['token'];
        if (token != null) {
          await prefs.setString('auth_token', token);
          print('🔑 Auth token saved');
        }

        // Map backend user data to local user
        final userData = response['data'] as Map<String, dynamic>;
        final user = _mapBackendUserToLocal(userData);

        // Update state and save to storage
        state = user;
        await _saveUserToStorage(user);

        print('✅ Backend login completed successfully for: ${user.name}');
        return;
      }
    } catch (backendError) {
      print('❌ Backend login failed: $backendError');
      print('🔄 Falling back to local authentication...');
    }

    try {
      // Fallback to local authentication
      await Future.delayed(const Duration(seconds: 1));

      // Try to get user from permanent database
      final user = await _getUserFromDatabase(email);

      if (user == null) {
        print('DEBUG: Local login failed - User not found in database');
        throw Exception('Invalid credentials');
      }

      // In a real app, you would validate the password hash here
      // For now, we just check if user exists with the email
      state = user;
      await _saveUserToStorage(user); // Save to current session storage

      print(
          'DEBUG: Local login successful for user: ${user.name} (${user.email})');
    } catch (e) {
      print('DEBUG: Login error: ${e.toString()}');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUser(User updatedUser) async {
    try {
      state = updatedUser;
      await _saveUserToStorage(updatedUser);
    } catch (e) {
      throw Exception('Failed to update user profile');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');

      // Clear chat messages on logout
      await ChatStorageService.clearMessages();

      state = null;
      print('DEBUG: User logged out and chat messages cleared');
    } catch (e) {
      // Handle error
      print('ERROR: Logout error: $e');
      state = null;
    }
  }

  // Public method to reload user data
  Future<void> reloadUser() async {
    await _loadUserFromStorage();
  }

  // Update specific user fields (local only - for backward compatibility)
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? gender,
    String? profileImageUrl,
  }) async {
    if (state == null) return;

    final updatedUser = state!.copyWith(
      name: name,
      phone: phone,
      address: address,
      dateOfBirth: dateOfBirth,
      gender: gender,
      profileImageUrl: profileImageUrl,
    );

    await updateUser(updatedUser);
  }

  // Upload profile image to Cloudinary and save to backend
  Future<void> uploadProfileImage(File imageFile) async {
    if (state == null) {
      throw Exception('User not logged in');
    }

    try {
      print('🚀 Starting profile image upload process...');

      // Step 1: Upload to Cloudinary
      print('📤 Uploading to Cloudinary...');
      final cloudinaryUrl = await CloudinaryService.uploadImage(imageFile);
      print('✅ Cloudinary upload successful: $cloudinaryUrl');

      // Step 2: Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Step 3: Update profile via backend API
      print('💾 Updating profile in backend...');
      final response = await ProfileService.updateProfile(
        token: token,
        avatar: cloudinaryUrl,
      );

      if (response['success'] == true && response['data'] != null) {
        // Step 4: Update local state with backend response
        final userData = response['data'] as Map<String, dynamic>;
        final updatedUser = _mapBackendUserToLocal(userData);

        state = updatedUser;
        await _saveUserToStorage(updatedUser);

        print('✅ Profile image updated successfully!');
      } else {
        throw Exception(
            'Backend update failed: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ Profile image upload failed: $e');
      rethrow;
    }
  }

  // Update profile via backend API
  Future<void> updateProfileViaApi({
    String? name,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? gender,
  }) async {
    if (state == null) {
      throw Exception('User not logged in');
    }

    try {
      // Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Update profile via backend API
      final response = await ProfileService.updateProfile(
        token: token,
        name: name,
        phone: phone,
      );

      if (response['success'] == true && response['data'] != null) {
        // Update local state with backend response
        final userData = response['data'] as Map<String, dynamic>;
        final updatedUser = _mapBackendUserToLocal(userData);

        state = updatedUser;
        await _saveUserToStorage(updatedUser);

        print('✅ Profile updated successfully via API!');
      } else {
        throw Exception(
            'Profile update failed: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ Profile update failed: $e');
      rethrow;
    }
  }

  // Refresh user data from backend
  Future<void> refreshFromBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('No auth token found, skipping backend refresh');
        return;
      }

      final response = await ProfileService.getCurrentUser(token: token);

      if (response['success'] == true && response['data'] != null) {
        final userData = response['data'] as Map<String, dynamic>;
        final updatedUser = _mapBackendUserToLocal(userData);

        state = updatedUser;
        await _saveUserToStorage(updatedUser);

        print('✅ User data refreshed from backend');
      }
    } catch (e) {
      print('❌ Failed to refresh user data from backend: $e');
      // Don't throw error - user can continue with local data
    }
  }

  // Map backend user data to local User model
  User _mapBackendUserToLocal(Map<String, dynamic> userData) {
    return User(
      id: userData['_id'] ?? userData['id'] ?? state!.id,
      name: userData['name'] ?? state!.name,
      email: userData['email'] ?? state!.email,
      phone: userData['phone'] ?? state!.phone,
      userType: userData['role'] ?? state!.userType,
      createdAt: userData['createdAt'] != null
          ? DateTime.parse(userData['createdAt'])
          : state!.createdAt,
      profileImageUrl: userData['avatar'] ?? userData['profileImageUrl'],
      address: userData['address'] is Map
          ? '${userData['address']['street'] ?? ''}, ${userData['address']['city'] ?? ''}'
          : userData['address'],
      dateOfBirth: userData['dateOfBirth'] != null
          ? DateTime.parse(userData['dateOfBirth']).toIso8601String()
          : state!.dateOfBirth,
      gender: userData['gender'] ?? state!.gender,
    );
  }
}
