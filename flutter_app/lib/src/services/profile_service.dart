import 'dart:io';
import 'dart:convert';
import '../services/network_service.dart';

class ProfileService {
  // Update profile with avatar URL
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (avatar != null) body['avatar'] = avatar;

      final response = await NetworkService.put(
        '/api/users/profile',
        token: token,
        body: body,
      );

      return NetworkService.handleResponse(response);
    } catch (e) {
      throw ProfileException('Failed to update profile: $e');
    }
  }

  // Upload profile image to backend
  static Future<Map<String, dynamic>> uploadProfileImage({
    required String token,
    required File imageFile,
  }) async {
    try {
      final streamedResponse = await NetworkService.uploadFile(
        '/api/users/profile/image',
        token: token,
        file: imageFile,
        fieldName: 'profileImage',
      );

      return await NetworkService.handleStreamedResponse(streamedResponse);
    } catch (e) {
      throw ProfileException('Failed to upload profile image: $e');
    }
  }

  // Get current user profile
  static Future<Map<String, dynamic>> getCurrentUser({
    required String token,
  }) async {
    try {
      final response = await NetworkService.get(
        '/api/users/me',
        token: token,
      );

      return NetworkService.handleResponse(response);
    } catch (e) {
      throw ProfileException('Failed to get user profile: $e');
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await NetworkService.post(
        '/api/users/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      return NetworkService.handleResponse(response);
    } catch (e) {
      throw ProfileException('Login failed: $e');
    }
  }

  // Register user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      };

      if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;
      if (gender != null) body['gender'] = gender;

      final response = await NetworkService.post(
        '/api/users/register',
        body: body,
      );

      return NetworkService.handleResponse(response);
    } catch (e) {
      throw ProfileException('Registration failed: $e');
    }
  }
}

// Custom exception for profile operations
class ProfileException implements Exception {
  final String message;
  ProfileException(this.message);

  @override
  String toString() => 'ProfileException: $message';
}
