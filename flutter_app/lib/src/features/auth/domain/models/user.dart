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

  // Personal Information
  final String? bloodGroup;
  final String? maritalStatus;
  final String? height;
  final String? weight;
  final String? emergencyContact;
  final String? location;

  // Medical Information
  final List<String>? allergies;
  final List<String>? currentMedications;
  final List<String>? pastMedications;
  final List<String>? chronicDiseases;
  final List<String>? injuries;
  final List<String>? surgeries;

  // Lifestyle Information
  final String? smokingHabits;
  final String? alcoholConsumption;
  final String? activityLevel;
  final String? foodPreference;
  final String? occupation;

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
    // Personal Information
    this.bloodGroup,
    this.maritalStatus,
    this.height,
    this.weight,
    this.emergencyContact,
    this.location,
    // Medical Information
    this.allergies,
    this.currentMedications,
    this.pastMedications,
    this.chronicDiseases,
    this.injuries,
    this.surgeries,
    // Lifestyle Information
    this.smokingHabits,
    this.alcoholConsumption,
    this.activityLevel,
    this.foodPreference,
    this.occupation,
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
    // Personal Information
    String? bloodGroup,
    String? maritalStatus,
    String? height,
    String? weight,
    String? emergencyContact,
    String? location,
    // Medical Information
    List<String>? allergies,
    List<String>? currentMedications,
    List<String>? pastMedications,
    List<String>? chronicDiseases,
    List<String>? injuries,
    List<String>? surgeries,
    // Lifestyle Information
    String? smokingHabits,
    String? alcoholConsumption,
    String? activityLevel,
    String? foodPreference,
    String? occupation,
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
      // Personal Information
      bloodGroup: bloodGroup ?? this.bloodGroup,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      location: location ?? this.location,
      // Medical Information
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      pastMedications: pastMedications ?? this.pastMedications,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      injuries: injuries ?? this.injuries,
      surgeries: surgeries ?? this.surgeries,
      // Lifestyle Information
      smokingHabits: smokingHabits ?? this.smokingHabits,
      alcoholConsumption: alcoholConsumption ?? this.alcoholConsumption,
      activityLevel: activityLevel ?? this.activityLevel,
      foodPreference: foodPreference ?? this.foodPreference,
      occupation: occupation ?? this.occupation,
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
      // Personal Information
      'bloodGroup': bloodGroup,
      'maritalStatus': maritalStatus,
      'height': height,
      'weight': weight,
      'emergencyContact': emergencyContact,
      'location': location,
      // Medical Information
      'allergies': allergies,
      'currentMedications': currentMedications,
      'pastMedications': pastMedications,
      'chronicDiseases': chronicDiseases,
      'injuries': injuries,
      'surgeries': surgeries,
      // Lifestyle Information
      'smokingHabits': smokingHabits,
      'alcoholConsumption': alcoholConsumption,
      'activityLevel': activityLevel,
      'foodPreference': foodPreference,
      'occupation': occupation,
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
      // Personal Information
      bloodGroup: json['bloodGroup'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      height: json['height'] as String?,
      weight: json['weight'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      location: json['location'] as String?,
      // Medical Information
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : null,
      currentMedications: json['currentMedications'] != null
          ? List<String>.from(json['currentMedications'])
          : null,
      pastMedications: json['pastMedications'] != null
          ? List<String>.from(json['pastMedications'])
          : null,
      chronicDiseases: json['chronicDiseases'] != null
          ? List<String>.from(json['chronicDiseases'])
          : null,
      injuries:
          json['injuries'] != null ? List<String>.from(json['injuries']) : null,
      surgeries: json['surgeries'] != null
          ? List<String>.from(json['surgeries'])
          : null,
      // Lifestyle Information
      smokingHabits: json['smokingHabits'] as String?,
      alcoholConsumption: json['alcoholConsumption'] as String?,
      activityLevel: json['activityLevel'] as String?,
      foodPreference: json['foodPreference'] as String?,
      occupation: json['occupation'] as String?,
    );
  }

  /// Calculate profile completion percentage
  int get profileCompletionPercentage {
    int totalFields = 20; // Total fields that can be filled
    int filledFields = 0;

    // Basic required fields (always filled)
    filledFields += 4; // id, name, email, phone

    // Optional fields
    if (profileImageUrl?.isNotEmpty == true) filledFields++;
    if (address?.isNotEmpty == true) filledFields++;
    if (dateOfBirth?.isNotEmpty == true) filledFields++;
    if (gender?.isNotEmpty == true) filledFields++;
    if (bloodGroup?.isNotEmpty == true) filledFields++;
    if (maritalStatus?.isNotEmpty == true) filledFields++;
    if (height?.isNotEmpty == true) filledFields++;
    if (weight?.isNotEmpty == true) filledFields++;
    if (emergencyContact?.isNotEmpty == true) filledFields++;
    if (location?.isNotEmpty == true) filledFields++;
    if (allergies?.isNotEmpty == true) filledFields++;
    if (currentMedications?.isNotEmpty == true) filledFields++;
    if (chronicDiseases?.isNotEmpty == true) filledFields++;
    if (smokingHabits?.isNotEmpty == true) filledFields++;
    if (alcoholConsumption?.isNotEmpty == true) filledFields++;
    if (activityLevel?.isNotEmpty == true) filledFields++;
    if (foodPreference?.isNotEmpty == true) filledFields++;
    if (occupation?.isNotEmpty == true) filledFields++;

    return ((filledFields / totalFields) * 100).round();
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
