enum AppointmentType {
  video,
  inPerson,
  phone,
  chat,
}

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  inProgress,
  rescheduled,
}

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String doctorImage;
  final AppointmentType type;
  final DateTime dateTime;
  final int durationMinutes;
  final double fee;
  final String reason;
  final String symptoms;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final String? meetingUrl;
  final String? prescriptionId;
  final Map<String, dynamic>? metadata;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.doctorImage,
    required this.type,
    required this.dateTime,
    required this.durationMinutes,
    required this.fee,
    required this.reason,
    required this.symptoms,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.meetingUrl,
    this.prescriptionId,
    this.metadata,
  });

  Appointment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialization,
    String? doctorImage,
    AppointmentType? type,
    DateTime? dateTime,
    int? durationMinutes,
    double? fee,
    String? reason,
    String? symptoms,
    AppointmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? meetingUrl,
    String? prescriptionId,
    Map<String, dynamic>? metadata,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialization: doctorSpecialization ?? this.doctorSpecialization,
      doctorImage: doctorImage ?? this.doctorImage,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      fee: fee ?? this.fee,
      reason: reason ?? this.reason,
      symptoms: symptoms ?? this.symptoms,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'doctorImage': doctorImage,
      'type': type.name,
      'dateTime': dateTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'fee': fee,
      'reason': reason,
      'symptoms': symptoms,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
      'meetingUrl': meetingUrl,
      'prescriptionId': prescriptionId,
      'metadata': metadata,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      doctorSpecialization: json['doctorSpecialization'] ?? '',
      doctorImage: json['doctorImage'] ?? '',
      type: AppointmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AppointmentType.inPerson,
      ),
      dateTime: DateTime.parse(json['dateTime']),
      durationMinutes: json['durationMinutes'] ?? 30,
      fee: (json['fee'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
      symptoms: json['symptoms'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      notes: json['notes'],
      meetingUrl: json['meetingUrl'],
      prescriptionId: json['prescriptionId'],
      metadata: json['metadata'],
    );
  }

  String get typeDisplayName {
    switch (type) {
      case AppointmentType.video:
        return 'Video Consultation';
      case AppointmentType.inPerson:
        return 'In-Person Visit';
      case AppointmentType.phone:
        return 'Phone Call';
      case AppointmentType.chat:
        return 'Text Chat';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
    }
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String image;
  final double rating;
  final int experienceYears;
  final String qualification;
  final String hospital;
  final double consultationFee;
  final List<String> availableSlots;
  final bool isOnline;
  final List<String> languages;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.image,
    required this.rating,
    required this.experienceYears,
    required this.qualification,
    required this.hospital,
    required this.consultationFee,
    required this.availableSlots,
    required this.isOnline,
    required this.languages,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'image': image,
      'rating': rating,
      'experienceYears': experienceYears,
      'qualification': qualification,
      'hospital': hospital,
      'consultationFee': consultationFee,
      'availableSlots': availableSlots,
      'isOnline': isOnline,
      'languages': languages,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      experienceYears: json['experienceYears'] ?? 0,
      qualification: json['qualification'] ?? '',
      hospital: json['hospital'] ?? '',
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      availableSlots: List<String>.from(json['availableSlots'] ?? []),
      isOnline: json['isOnline'] ?? false,
      languages: List<String>.from(json['languages'] ?? []),
    );
  }
}
