import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../domain/models/user.dart';
import '../../../home/data/chat_storage_service.dart';

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
    } catch (e) {
      // Handle error
      throw Exception('Failed to save user data');
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

  // Login user
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Load user from storage
      await _loadUserFromStorage();

      // Check if user exists and email matches
      if (state == null || state!.email != email) {
        print('DEBUG: Login failed - User not found or email mismatch');
        throw Exception('Invalid credentials');
      }

      // In a real app, you would validate the password hash here
      // For now, we just check if user exists with the email
      print(
          'DEBUG: Login successful for user: ${state!.name} (${state!.email})');
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

  // Update specific user fields
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
}
