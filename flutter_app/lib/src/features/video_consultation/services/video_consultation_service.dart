import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/video_consultation_models.dart';
import '../../../core/config/api_config.dart';

class VideoConsultationService {
  // Set to false to use real MongoDB backend, true for demo mode
  // IMPORTANT: Set to false after setting up MongoDB backend
  static const bool demoMode = true;

  final http.Client _client = http.Client();

  // Get current user ID from storage
  Future<String> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      return userData['id'] ?? 'guest_user';
    }
    return 'guest_user';
  }

  // Get list of available doctors
  Future<List<Doctor>> getAvailableDoctors({String? specialty}) async {
    if (demoMode) {
      await Future.delayed(Duration(seconds: 1));
      return _getDemoDoctors(specialty);
    }

    try {
      String url = ApiConfig.doctors;
      if (specialty != null) {
        url += '?specialty=$specialty';
      }

      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['doctors'] as List)
            .map((doctor) => Doctor.fromJson(doctor))
            .toList();
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      debugPrint('Error loading doctors: $e');
      throw Exception('Failed to load doctors');
    }
  }

  // Book video consultation
  Future<VideoConsultation> bookConsultation({
    required String doctorId,
    required DateTime scheduledTime,
    required String symptoms,
    String? notes,
  }) async {
    if (demoMode) {
      await Future.delayed(Duration(seconds: 2));
      final consultation =
          _createDemoConsultation(doctorId, scheduledTime, symptoms, notes);

      // Store in SharedPreferences for demo mode
      await _storeDemoConsultation(consultation);

      return consultation;
    }

    try {
      final userId = await _getCurrentUserId();

      final response = await _client.post(
        Uri.parse(ApiConfig.bookConsultation),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'doctorId': doctorId,
          'scheduledTime': scheduledTime.toIso8601String(),
          'symptoms': symptoms,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VideoConsultation.fromJson(data['consultation']);
      } else {
        throw Exception('Failed to book consultation: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error booking consultation: $e');
      throw Exception('Failed to book consultation: $e');
    }
  }

  // Store demo consultation in local storage
  Future<void> _storeDemoConsultation(VideoConsultation consultation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consultationsJson = prefs.getString('demo_consultations') ?? '[]';
      final List<dynamic> consultations = jsonDecode(consultationsJson);

      consultations.add({
        'id': consultation.id,
        'patientId': consultation.patientId,
        'patientName': consultation.patientName,
        'doctorId': consultation.doctorId,
        'doctorName': consultation.doctorName,
        'doctorSpecialty': consultation.doctorSpecialty,
        'doctorImage': consultation.doctorImage,
        'scheduledTime': consultation.scheduledTime.toIso8601String(),
        'duration': consultation.duration,
        'consultationFee': consultation.consultationFee,
        'status': consultation.status,
        'symptoms': consultation.symptoms,
        'notes': consultation.notes,
        'roomId': consultation.roomId,
      });

      await prefs.setString('demo_consultations', jsonEncode(consultations));
      debugPrint('Demo consultation stored: ${consultation.id}');
    } catch (e) {
      debugPrint('Error storing demo consultation: $e');
    }
  }

  // Get stored demo consultations
  Future<List<VideoConsultation>> _getStoredDemoConsultations(
      String? status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consultationsJson = prefs.getString('demo_consultations') ?? '[]';
      final List<dynamic> consultations = jsonDecode(consultationsJson);

      List<VideoConsultation> result = consultations.map((json) {
        return VideoConsultation(
          id: json['id'],
          patientId: json['patientId'],
          patientName: json['patientName'],
          doctorId: json['doctorId'],
          doctorName: json['doctorName'],
          doctorSpecialty: json['doctorSpecialty'],
          doctorImage: json['doctorImage'],
          scheduledTime: DateTime.parse(json['scheduledTime']),
          duration: json['duration'],
          consultationFee: json['consultationFee'].toDouble(),
          status: json['status'],
          symptoms: json['symptoms'],
          notes: json['notes'],
          roomId: json['roomId'],
        );
      }).toList();

      // Filter by status if provided
      if (status != null) {
        result = result.where((c) => c.status == status).toList();
      }

      // Sort by scheduled time
      result.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

      debugPrint('Retrieved ${result.length} stored demo consultations');
      return result;
    } catch (e) {
      debugPrint('Error getting stored demo consultations: $e');
      return [];
    }
  }

  // Update stored consultation status (for demo mode cancel)
  Future<void> _updateStoredConsultationStatus(
      String consultationId, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? consultationsJson = prefs.getString('demo_consultations');

      if (consultationsJson != null) {
        List<dynamic> consultations = jsonDecode(consultationsJson);

        // Find and update the consultation
        for (var i = 0; i < consultations.length; i++) {
          if (consultations[i]['id'] == consultationId) {
            consultations[i]['status'] = newStatus;
            break;
          }
        }

        // Save updated list
        await prefs.setString('demo_consultations', jsonEncode(consultations));
        debugPrint('Updated consultation $consultationId status to $newStatus');
      }
    } catch (e) {
      debugPrint('Error updating stored consultation status: $e');
    }
  }

  // Update stored consultation time (for demo mode reschedule)
  Future<void> _updateStoredConsultationTime(
      String consultationId, DateTime newDateTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? consultationsJson = prefs.getString('demo_consultations');

      if (consultationsJson != null) {
        List<dynamic> consultations = jsonDecode(consultationsJson);

        // Find and update the consultation
        for (var i = 0; i < consultations.length; i++) {
          if (consultations[i]['id'] == consultationId) {
            consultations[i]['scheduledTime'] = newDateTime.toIso8601String();
            break;
          }
        }

        // Save updated list
        await prefs.setString('demo_consultations', jsonEncode(consultations));
        debugPrint('Updated consultation $consultationId time to $newDateTime');
      }
    } catch (e) {
      debugPrint('Error updating stored consultation time: $e');
    }
  }

  // Get user's consultations
  Future<List<VideoConsultation>> getMyConsultations({
    String? status,
  }) async {
    if (demoMode) {
      await Future.delayed(Duration(seconds: 1));
      // Get stored consultations instead of hardcoded demo data
      return await _getStoredDemoConsultations(status);
    }

    try {
      final userId = await _getCurrentUserId();
      String url = '${ApiConfig.myConsultations}?userId=$userId';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['consultations'] as List)
            .map((consultation) => VideoConsultation.fromJson(consultation))
            .toList();
      } else {
        throw Exception('Failed to load consultations');
      }
    } catch (e) {
      debugPrint('Error loading consultations: $e');
      throw Exception('Failed to load consultations: $e');
    }
  }

  // Join video call (get Agora token)
  Future<Map<String, dynamic>> joinVideoCall(String consultationId) async {
    if (demoMode) {
      await Future.delayed(Duration(seconds: 1));
      return {
        'token': 'DEMO_AGORA_TOKEN_${DateTime.now().millisecondsSinceEpoch}',
        'channelName': 'consultation_$consultationId',
        'uid': 12345,
        'appId': 'demo_app_id',
      };
    }

    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.joinCall}/$consultationId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to join call');
      }
    } catch (e) {
      debugPrint('Error joining call: $e');
      throw Exception('Failed to join video call');
    }
  }

  // End video call
  Future<void> endVideoCall(String consultationId) async {
    if (demoMode) {
      await Future.delayed(Duration(seconds: 1));
      debugPrint('DEMO: Video call ended');
      return;
    }

    try {
      final response = await _client.post(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/video-consultations/$consultationId/end'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to end call');
      }
    } catch (e) {
      debugPrint('Error ending call: $e');
      throw Exception('Failed to end video call');
    }
  }

  // Cancel consultation
  Future<void> cancelConsultation(String consultationId, String reason) async {
    if (demoMode) {
      await Future.delayed(Duration(seconds: 1));
      // Update stored consultation status
      await _updateStoredConsultationStatus(consultationId, 'cancelled');
      debugPrint('DEMO: Consultation cancelled');
      return;
    }

    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.cancelConsultation}/$consultationId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel consultation: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error cancelling consultation: $e');
      throw Exception('Failed to cancel consultation: $e');
    }
  }

  // Reschedule consultation
  Future<void> rescheduleConsultation(
      String consultationId, DateTime newDateTime) async {
    if (demoMode) {
      await Future.delayed(Duration(seconds: 1));
      // Update stored consultation time
      await _updateStoredConsultationTime(consultationId, newDateTime);
      debugPrint('DEMO: Consultation rescheduled to $newDateTime');
      return;
    }

    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.rescheduleConsultation}/$consultationId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'newDateTime': newDateTime.toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reschedule consultation: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error rescheduling consultation: $e');
      throw Exception('Failed to reschedule consultation: $e');
    }
  }

  // Demo data
  List<Doctor> _getDemoDoctors(String? specialty) {
    final allDoctors = [
      Doctor(
        id: '1',
        name: 'Dr. Rajesh Kumar',
        specialty: 'Cardiologist',
        qualification: 'MBBS, MD (Cardiology)',
        image: 'https://randomuser.me/api/portraits/men/1.jpg',
        experience: 15,
        rating: 4.8,
        totalConsultations: 1250,
        consultationFee: 800,
        languages: ['English', 'Hindi', 'Punjabi'],
        about:
            'Experienced cardiologist specializing in heart diseases and interventional cardiology.',
        isAvailable: true,
        availableSlots: _generateTimeSlots(),
      ),
      Doctor(
        id: '2',
        name: 'Dr. Priya Sharma',
        specialty: 'General Physician',
        qualification: 'MBBS, MD (Medicine)',
        image: 'https://randomuser.me/api/portraits/women/2.jpg',
        experience: 10,
        rating: 4.9,
        totalConsultations: 2100,
        consultationFee: 500,
        languages: ['English', 'Hindi'],
        about:
            'General physician with expertise in primary care and preventive medicine.',
        isAvailable: true,
        availableSlots: _generateTimeSlots(),
      ),
      Doctor(
        id: '3',
        name: 'Dr. Amit Patel',
        specialty: 'Dermatologist',
        qualification: 'MBBS, MD (Dermatology)',
        image: 'https://randomuser.me/api/portraits/men/3.jpg',
        experience: 12,
        rating: 4.7,
        totalConsultations: 980,
        consultationFee: 700,
        languages: ['English', 'Hindi', 'Gujarati'],
        about:
            'Skin specialist with focus on cosmetic dermatology and skin diseases.',
        isAvailable: true,
        availableSlots: _generateTimeSlots(),
      ),
      Doctor(
        id: '4',
        name: 'Dr. Sneha Reddy',
        specialty: 'Pediatrician',
        qualification: 'MBBS, MD (Pediatrics)',
        image: 'https://randomuser.me/api/portraits/women/4.jpg',
        experience: 8,
        rating: 4.9,
        totalConsultations: 1560,
        consultationFee: 600,
        languages: ['English', 'Hindi', 'Telugu'],
        about:
            'Pediatrician specializing in child healthcare and immunization.',
        isAvailable: true,
        availableSlots: _generateTimeSlots(),
      ),
      Doctor(
        id: '5',
        name: 'Dr. Vikram Singh',
        specialty: 'Orthopedic',
        qualification: 'MBBS, MS (Orthopedics)',
        image: 'https://randomuser.me/api/portraits/men/5.jpg',
        experience: 18,
        rating: 4.6,
        totalConsultations: 875,
        consultationFee: 900,
        languages: ['English', 'Hindi'],
        about:
            'Orthopedic surgeon with expertise in joint replacement and sports injuries.',
        isAvailable: true,
        availableSlots: _generateTimeSlots(),
      ),
    ];

    if (specialty != null && specialty.isNotEmpty) {
      return allDoctors.where((d) => d.specialty == specialty).toList();
    }
    return allDoctors;
  }

  List<TimeSlot> _generateTimeSlots() {
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    final slots = <TimeSlot>[];

    for (int hour = 9; hour < 18; hour++) {
      final startTime =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, hour, 0);
      final endTime = startTime.add(Duration(minutes: 30));

      slots.add(TimeSlot(
        id: 'slot_$hour',
        startTime: startTime,
        endTime: endTime,
        isBooked: false,
      ));
    }

    return slots;
  }

  VideoConsultation _createDemoConsultation(
    String doctorId,
    DateTime scheduledTime,
    String symptoms,
    String? notes,
  ) {
    final doctor = _getDemoDoctors(null).firstWhere(
      (d) => d.id == doctorId,
      orElse: () => _getDemoDoctors(null).first,
    );

    return VideoConsultation(
      id: 'consultation_${DateTime.now().millisecondsSinceEpoch}',
      patientId: 'patient_123',
      patientName: 'Demo Patient',
      doctorId: doctor.id,
      doctorName: doctor.name,
      doctorSpecialty: doctor.specialty,
      doctorImage: doctor.image,
      scheduledTime: scheduledTime,
      duration: 30,
      consultationFee: doctor.consultationFee,
      status: 'scheduled',
      symptoms: symptoms,
      notes: notes,
      roomId: 'room_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  List<VideoConsultation> _getDemoConsultations(String? status) {
    final consultations = [
      VideoConsultation(
        id: 'cons_1',
        patientId: 'patient_123',
        patientName: 'Demo Patient',
        doctorId: '1',
        doctorName: 'Dr. Rajesh Kumar',
        doctorSpecialty: 'Cardiologist',
        doctorImage: 'https://randomuser.me/api/portraits/men/1.jpg',
        scheduledTime: DateTime.now().add(Duration(days: 1, hours: 2)),
        duration: 30,
        consultationFee: 800,
        status: 'scheduled',
        symptoms: 'Chest pain and shortness of breath',
        roomId: 'room_001',
      ),
      VideoConsultation(
        id: 'cons_2',
        patientId: 'patient_123',
        patientName: 'Demo Patient',
        doctorId: '2',
        doctorName: 'Dr. Priya Sharma',
        doctorSpecialty: 'General Physician',
        doctorImage: 'https://randomuser.me/api/portraits/women/2.jpg',
        scheduledTime: DateTime.now().subtract(Duration(days: 2)),
        duration: 30,
        consultationFee: 500,
        status: 'completed',
        symptoms: 'Fever and headache',
        startedAt: DateTime.now().subtract(Duration(days: 2, minutes: 35)),
        endedAt: DateTime.now().subtract(Duration(days: 2, minutes: 5)),
        prescription: 'Paracetamol 500mg, twice daily for 3 days',
        roomId: 'room_002',
      ),
    ];

    if (status != null && status.isNotEmpty) {
      return consultations.where((c) => c.status == status).toList();
    }
    return consultations;
  }

  void dispose() {
    _client.close();
  }
}
