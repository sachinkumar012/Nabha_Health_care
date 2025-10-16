class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String userType;
  final DateTime createdAt;
  final String? profileImageUrl;
  final String? address;
  final String? dateOfBirth;
  final String? gender;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    required this.createdAt,
    this.profileImageUrl,
    this.address,
    this.dateOfBirth,
    this.gender,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? userType,
    DateTime? createdAt,
    String? profileImageUrl,
    String? address,
    String? dateOfBirth,
    String? gender,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType,
      'createdAt': createdAt.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      userType: json['userType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      profileImageUrl: json['profileImageUrl'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, userType: $userType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
