// ABHA (Ayushman Bharat Health Account) Models

class AbhaCard {
  final String abhaNumber;
  final String abhaAddress;
  final String name;
  final String gender;
  final String dateOfBirth;
  final String mobileNumber;
  final String? email;
  final String? profilePhoto;
  final String? address;
  final String? stateName;
  final String? districtName;
  final DateTime createdDate;
  final String status; // active, inactive, pending

  AbhaCard({
    required this.abhaNumber,
    required this.abhaAddress,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.mobileNumber,
    this.email,
    this.profilePhoto,
    this.address,
    this.stateName,
    this.districtName,
    required this.createdDate,
    this.status = 'active',
  });

  factory AbhaCard.fromJson(Map<String, dynamic> json) {
    return AbhaCard(
      abhaNumber: json['abhaNumber'] ?? json['healthIdNumber'] ?? '',
      abhaAddress: json['abhaAddress'] ?? json['healthId'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? json['dob'] ?? '',
      mobileNumber: json['mobile'] ?? json['mobileNumber'] ?? '',
      email: json['email'],
      profilePhoto: json['profilePhoto'] ?? json['photo'],
      address: json['address'],
      stateName: json['stateName'],
      districtName: json['districtName'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : DateTime.now(),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'abhaNumber': abhaNumber,
      'abhaAddress': abhaAddress,
      'name': name,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'mobileNumber': mobileNumber,
      'email': email,
      'profilePhoto': profilePhoto,
      'address': address,
      'stateName': stateName,
      'districtName': districtName,
      'createdDate': createdDate.toIso8601String(),
      'status': status,
    };
  }

  // Format ABHA number for display (XX-XXXX-XXXX-XXXX)
  String get formattedAbhaNumber {
    if (abhaNumber.length == 14) {
      return '${abhaNumber.substring(0, 2)}-${abhaNumber.substring(2, 6)}-${abhaNumber.substring(6, 10)}-${abhaNumber.substring(10, 14)}';
    }
    return abhaNumber;
  }
}

class AadhaarOtpRequest {
  final String aadhaarNumber;
  final String txnId;

  AadhaarOtpRequest({
    required this.aadhaarNumber,
    required this.txnId,
  });

  Map<String, dynamic> toJson() {
    return {
      'aadhaar': aadhaarNumber,
      'txnId': txnId,
    };
  }
}

class AadhaarOtpVerification {
  final String otp;
  final String txnId;
  final String? mobileNumber;

  AadhaarOtpVerification({
    required this.otp,
    required this.txnId,
    this.mobileNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'txnId': txnId,
      if (mobileNumber != null) 'mobile': mobileNumber,
    };
  }
}

class MobileOtpRequest {
  final String mobileNumber;
  final String txnId;

  MobileOtpRequest({
    required this.mobileNumber,
    required this.txnId,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobileNumber,
      'txnId': txnId,
    };
  }
}

class AbhaCreationRequest {
  final String txnId;
  final String abhaAddress; // preferred health ID
  final String? email;
  final String? password;

  AbhaCreationRequest({
    required this.txnId,
    required this.abhaAddress,
    this.email,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'txnId': txnId,
      'healthId': abhaAddress,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
    };
  }
}

class AbhaLinkRequest {
  final String abhaAddress;
  final String password;

  AbhaLinkRequest({
    required this.abhaAddress,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'healthId': abhaAddress,
      'password': password,
    };
  }
}

class AbhaBenefit {
  final String title;
  final String description;
  final String icon;

  AbhaBenefit({
    required this.title,
    required this.description,
    required this.icon,
  });
}

// Pre-defined benefits
final List<AbhaBenefit> abhaBenefits = [
  AbhaBenefit(
    title: 'Secure & Private',
    description: 'Your health data is encrypted and secure',
    icon: '🛡️',
  ),
  AbhaBenefit(
    title: 'Easy Access',
    description: 'Access your health records from anywhere',
    icon: '📱',
  ),
  AbhaBenefit(
    title: 'Link Records',
    description: 'Connect with healthcare providers easily',
    icon: '🔗',
  ),
  AbhaBenefit(
    title: 'Government Verified',
    description: 'Official health ID by Government of India',
    icon: '✓',
  ),
];
