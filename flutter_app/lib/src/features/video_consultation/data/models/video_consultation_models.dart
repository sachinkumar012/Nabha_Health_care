class VideoConsultation {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImage;
  final DateTime scheduledTime;
  final int duration; // in minutes
  final double consultationFee;
  final String status; // scheduled, ongoing, completed, cancelled
  final String? roomId;
  final String? token;
  final String? symptoms;
  final String? notes;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? prescription;
  final String? recordingUrl;

  VideoConsultation({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImage,
    required this.scheduledTime,
    this.duration = 30,
    required this.consultationFee,
    this.status = 'scheduled',
    this.roomId,
    this.token,
    this.symptoms,
    this.notes,
    this.startedAt,
    this.endedAt,
    this.prescription,
    this.recordingUrl,
  });

  factory VideoConsultation.fromJson(Map<String, dynamic> json) {
    return VideoConsultation(
      id: json['_id'] ?? json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      doctorSpecialty: json['doctorSpecialty'] ?? '',
      doctorImage: json['doctorImage'] ?? '',
      scheduledTime: DateTime.parse(json['scheduledTime']),
      duration: json['duration'] ?? 30,
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      status: json['status'] ?? 'scheduled',
      roomId: json['roomId'],
      token: json['token'],
      symptoms: json['symptoms'],
      notes: json['notes'],
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      prescription: json['prescription'],
      recordingUrl: json['recordingUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorImage': doctorImage,
      'scheduledTime': scheduledTime.toIso8601String(),
      'duration': duration,
      'consultationFee': consultationFee,
      'status': status,
      'roomId': roomId,
      'token': token,
      'symptoms': symptoms,
      'notes': notes,
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'prescription': prescription,
      'recordingUrl': recordingUrl,
    };
  }

  VideoConsultation copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    String? doctorImage,
    DateTime? scheduledTime,
    int? duration,
    double? consultationFee,
    String? status,
    String? roomId,
    String? token,
    String? symptoms,
    String? notes,
    DateTime? startedAt,
    DateTime? endedAt,
    String? prescription,
    String? recordingUrl,
  }) {
    return VideoConsultation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorImage: doctorImage ?? this.doctorImage,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      duration: duration ?? this.duration,
      consultationFee: consultationFee ?? this.consultationFee,
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      token: token ?? this.token,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      prescription: prescription ?? this.prescription,
      recordingUrl: recordingUrl ?? this.recordingUrl,
    );
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String qualification;
  final String image;
  final int experience; // years
  final double rating;
  final int totalConsultations;
  final double consultationFee;
  final List<String> languages;
  final String about;
  final bool isAvailable;
  final List<TimeSlot> availableSlots;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.qualification,
    required this.image,
    required this.experience,
    required this.rating,
    required this.totalConsultations,
    required this.consultationFee,
    required this.languages,
    required this.about,
    this.isAvailable = true,
    this.availableSlots = const [],
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      qualification: json['qualification'] ?? '',
      image: json['image'] ?? '',
      experience: json['experience'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      totalConsultations: json['totalConsultations'] ?? 0,
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      languages: List<String>.from(json['languages'] ?? []),
      about: json['about'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      availableSlots: (json['availableSlots'] as List?)
              ?.map((slot) => TimeSlot.fromJson(slot))
              .toList() ??
          [],
    );
  }
}

class TimeSlot {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;

  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isBooked: json['isBooked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isBooked': isBooked,
    };
  }
}
