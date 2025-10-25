import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

// User model
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? image;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.image,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? image,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// User state notifier
class UserNotifier extends Notifier<User?> {
  @override
  User? build() {
    // Initialize with null, will be set when user logs in
    return null;
  }

  void _initializeDefaultUser() {
    // Create a default test user
    final defaultUser = User(
      id: 'user_123',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+91 9876543210',
      image:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      createdAt: DateTime.now(),
    );

    state = defaultUser;
  }

  void login(User user) {
    state = user;
  }

  void logout() {
    state = null;
  }

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? image,
  }) {
    if (state != null) {
      state = state!.copyWith(
        name: name,
        email: email,
        phone: phone,
        image: image,
      );
    }
  }
}

// User provider
final userProvider = NotifierProvider<UserNotifier, User?>(() {
  return UserNotifier();
});

// Computed providers
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider);
  return user != null;
});

final userNameProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider);
  return user?.name ?? 'Guest';
});

final userEmailProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider);
  return user?.email ?? '';
});
