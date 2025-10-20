import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/models/appointment.dart';

class AppointmentBookingService {
  // Your Google Gemini AI API configuration
  static const String _apiKey = "AIzaSyCAzGYeMcfLMCp1ghvQWBX2xdbLhbJS1Go";
  static const String _geminiApiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  // Sample doctors data - In production, this would come from your backend
  static final List<Doctor> _doctors = [
    Doctor(
      id: 'doc_001',
      name: 'Dr. Sachin Kumar',
      specialization: 'General Physician',
      image:
          'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400',
      rating: 4.8,
      experienceYears: 15,
      qualification: 'MBBS, MD',
      hospital: 'Nabha Healthcare',
      consultationFee: 500,
      availableSlots: [
        '09:00 AM',
        '10:00 AM',
        '11:00 AM',
        '02:00 PM',
        '03:00 PM'
      ],
      isOnline: true,
      languages: ['English', 'Hindi', 'Punjabi'],
    ),
    Doctor(
      id: 'doc_002',
      name: 'Dr. Tarun Thakur',
      specialization: 'Pediatrician',
      image:
          'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400',
      rating: 4.9,
      experienceYears: 12,
      qualification: 'MBBS, DCH',
      hospital: 'Nabha Healthcare',
      consultationFee: 600,
      availableSlots: [
        '10:00 AM',
        '11:00 AM',
        '12:00 PM',
        '04:00 PM',
        '05:00 PM'
      ],
      isOnline: true,
      languages: ['English', 'Hindi'],
    ),
    Doctor(
      id: 'doc_003',
      name: 'Dr. Manish Sharma',
      specialization: 'Cardiologist',
      image: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400',
      rating: 4.7,
      experienceYears: 18,
      qualification: 'MBBS, MD, DM Cardiology',
      hospital: 'Nabha Healthcare',
      consultationFee: 800,
      availableSlots: ['09:00 AM', '10:30 AM', '02:00 PM', '03:30 PM'],
      isOnline: true,
      languages: ['English', 'Hindi'],
    ),
    Doctor(
      id: 'doc_004',
      name: 'Dr. Fouziya Siddiqui',
      specialization: 'Gynecologist',
      image:
          'https://images.unsplash.com/photo-1594824532314-2b52b2629fb7?w=400',
      rating: 4.9,
      experienceYears: 14,
      qualification: 'MBBS, MS Gynecology',
      hospital: 'Nabha Healthcare',
      consultationFee: 700,
      availableSlots: [
        '11:00 AM',
        '12:00 PM',
        '03:00 PM',
        '04:00 PM',
        '05:00 PM'
      ],
      isOnline: true,
      languages: ['English', 'Hindi', 'Urdu'],
    ),
    Doctor(
      id: 'doc_005',
      name: 'Dr. Shashank',
      specialization: 'Orthopedic Surgeon',
      image:
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
      rating: 4.6,
      experienceYears: 16,
      qualification: 'MBBS, MS Orthopedics',
      hospital: 'Nabha Healthcare',
      consultationFee: 750,
      availableSlots: ['09:30 AM', '11:00 AM', '02:30 PM', '04:00 PM'],
      isOnline: false,
      languages: ['English', 'Hindi'],
    ),
    Doctor(
      id: 'doc_006',
      name: 'Dr. Kamaljeet Kaur',
      specialization: 'Dermatologist',
      image:
          'https://images.unsplash.com/photo-1609188076864-c35269136ae0?w=400',
      rating: 4.8,
      experienceYears: 10,
      qualification: 'MBBS, MD Dermatology',
      hospital: 'Nabha Healthcare',
      consultationFee: 650,
      availableSlots: ['10:00 AM', '12:00 PM', '03:00 PM', '05:00 PM'],
      isOnline: true,
      languages: ['English', 'Hindi', 'Punjabi'],
    ),
  ];

  /// Get all available doctors
  Future<List<Doctor>> getAllDoctors() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _doctors;
  }

  /// Get doctors by specialization
  Future<List<Doctor>> getDoctorsBySpecialization(String specialization) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _doctors
        .where((doctor) => doctor.specialization
            .toLowerCase()
            .contains(specialization.toLowerCase()))
        .toList();
  }

  /// Get doctor by ID
  Future<Doctor?> getDoctorById(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _doctors.firstWhere((doctor) => doctor.id == doctorId);
    } catch (e) {
      return null;
    }
  }

  /// Use Gemini AI to suggest doctors based on symptoms
  Future<List<Doctor>> suggestDoctorsForSymptoms(String symptoms) async {
    try {
      print('🤖 AI_APPOINTMENT_DEBUG: Analyzing symptoms: $symptoms');

      final systemPrompt = '''
You are a medical AI assistant for Nabha Healthcare appointment booking system. 
Analyze the symptoms and suggest the most appropriate medical specialization.

Available Specializations:
- General Physician (for common symptoms, fever, cold, general checkup)
- Pediatrician (for children-related issues)
- Cardiologist (for heart, chest pain, blood pressure issues)
- Gynecologist (for women's health issues)
- Orthopedic Surgeon (for bone, joint, muscle pain)
- Dermatologist (for skin, hair, nail problems)

Patient Symptoms: "$symptoms"

Respond with ONLY the specialization name that matches exactly from the list above.
If symptoms are general or unclear, suggest "General Physician".
''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': systemPrompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.1,
          'topK': 1,
          'topP': 1,
          'maxOutputTokens': 50,
        }
      };

      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];

        print(
            '🤖 AI_APPOINTMENT_DEBUG: AI suggested specialization: $aiResponse');

        // Clean the AI response and find matching doctors
        final suggestedSpecialization = aiResponse.trim();
        final suggestedDoctors =
            await getDoctorsBySpecialization(suggestedSpecialization);

        if (suggestedDoctors.isNotEmpty) {
          print(
              '🤖 AI_APPOINTMENT_DEBUG: Found ${suggestedDoctors.length} doctors for $suggestedSpecialization');
          return suggestedDoctors;
        } else {
          // Fallback to General Physician if no specific match
          print(
              '🤖 AI_APPOINTMENT_DEBUG: No specific doctors found, returning General Physicians');
          return await getDoctorsBySpecialization('General Physician');
        }
      } else {
        print('❌ AI_APPOINTMENT_DEBUG: API error: ${response.statusCode}');
        // Fallback to General Physician
        return await getDoctorsBySpecialization('General Physician');
      }
    } catch (e) {
      print('❌ AI_APPOINTMENT_DEBUG: Exception: $e');
      // Fallback to General Physician
      return await getDoctorsBySpecialization('General Physician');
    }
  }

  /// Book an appointment
  Future<Appointment> bookAppointment({
    required String patientId,
    required String doctorId,
    required AppointmentType type,
    required DateTime dateTime,
    required String reason,
    required String symptoms,
    int durationMinutes = 30,
  }) async {
    try {
      print(
          '📅 APPOINTMENT_DEBUG: Booking appointment for patient $patientId with doctor $doctorId');

      // Get doctor details
      final doctor = await getDoctorById(doctorId);
      if (doctor == null) {
        throw Exception('Doctor not found');
      }

      // Generate appointment ID
      final appointmentId = 'apt_${DateTime.now().millisecondsSinceEpoch}';

      // Calculate fee based on appointment type
      double fee = doctor.consultationFee;
      switch (type) {
        case AppointmentType.video:
          fee = doctor.consultationFee;
          break;
        case AppointmentType.phone:
          fee = doctor.consultationFee * 0.7; // 30% discount for phone
          break;
        case AppointmentType.chat:
          fee = doctor.consultationFee * 0.5; // 50% discount for chat
          break;
        case AppointmentType.inPerson:
          fee = doctor.consultationFee;
          break;
      }

      // Generate meeting URL for video appointments
      String? meetingUrl;
      if (type == AppointmentType.video) {
        meetingUrl = 'https://nabha-health.com/video-call/$appointmentId';
      }

      // Create appointment
      final appointment = Appointment(
        id: appointmentId,
        patientId: patientId,
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorSpecialization: doctor.specialization,
        doctorImage: doctor.image,
        type: type,
        dateTime: dateTime,
        durationMinutes: durationMinutes,
        fee: fee,
        reason: reason,
        symptoms: symptoms,
        status: AppointmentStatus.confirmed,
        createdAt: DateTime.now(),
        meetingUrl: meetingUrl,
        metadata: {
          'doctorRating': doctor.rating,
          'doctorExperience': doctor.experienceYears,
          'hospital': doctor.hospital,
        },
      );

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      print(
          '✅ APPOINTMENT_DEBUG: Appointment booked successfully: $appointmentId');
      print('✅ APPOINTMENT_DEBUG: Type: ${appointment.typeDisplayName}');
      print('✅ APPOINTMENT_DEBUG: Fee: ₹${appointment.fee}');
      print('✅ APPOINTMENT_DEBUG: DateTime: ${appointment.dateTime}');

      return appointment;
    } catch (e) {
      print('❌ APPOINTMENT_DEBUG: Booking failed: $e');
      rethrow;
    }
  }

  /// Get patient appointments
  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    // In production, this would fetch from your backend
    // For now, return sample appointments
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Appointment(
        id: 'apt_sample_1',
        patientId: patientId,
        doctorId: 'doc_001',
        doctorName: 'Dr. Sachin Kumar',
        doctorSpecialization: 'General Physician',
        doctorImage:
            'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400',
        type: AppointmentType.video,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        durationMinutes: 30,
        fee: 500,
        reason: 'Regular checkup',
        symptoms: 'Feeling tired lately',
        status: AppointmentStatus.confirmed,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        meetingUrl: 'https://nabha-health.com/video-call/apt_sample_1',
      ),
      Appointment(
        id: 'apt_sample_2',
        patientId: patientId,
        doctorId: 'doc_003',
        doctorName: 'Dr. Manish Sharma',
        doctorSpecialization: 'Cardiologist',
        doctorImage:
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400',
        type: AppointmentType.inPerson,
        dateTime: DateTime.now().add(const Duration(days: 7)),
        durationMinutes: 45,
        fee: 800,
        reason: 'Heart checkup',
        symptoms: 'Chest discomfort during exercise',
        status: AppointmentStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  /// Cancel appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      print('❌ APPOINTMENT_DEBUG: Cancelling appointment: $appointmentId');

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      print('✅ APPOINTMENT_DEBUG: Appointment cancelled successfully');
      return true;
    } catch (e) {
      print('❌ APPOINTMENT_DEBUG: Cancellation failed: $e');
      return false;
    }
  }

  /// Reschedule appointment
  Future<Appointment?> rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime,
  ) async {
    try {
      print('🔄 APPOINTMENT_DEBUG: Rescheduling appointment: $appointmentId');
      print('🔄 APPOINTMENT_DEBUG: New date: $newDateTime');

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 600));

      // In production, fetch the existing appointment and update it
      // For now, return a sample updated appointment
      final updatedAppointment = Appointment(
        id: appointmentId,
        patientId: 'current_user',
        doctorId: 'doc_001',
        doctorName: 'Dr. Sachin Kumar',
        doctorSpecialization: 'General Physician',
        doctorImage:
            'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400',
        type: AppointmentType.video,
        dateTime: newDateTime,
        durationMinutes: 30,
        fee: 500,
        reason: 'Regular checkup',
        symptoms: 'Feeling tired lately',
        status: AppointmentStatus.rescheduled,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
        meetingUrl: 'https://nabha-health.com/video-call/$appointmentId',
      );

      print('✅ APPOINTMENT_DEBUG: Appointment rescheduled successfully');
      return updatedAppointment;
    } catch (e) {
      print('❌ APPOINTMENT_DEBUG: Rescheduling failed: $e');
      return null;
    }
  }

  /// Get available slots for a doctor on a specific date
  Future<List<String>> getAvailableSlots(String doctorId, DateTime date) async {
    try {
      final doctor = await getDoctorById(doctorId);
      if (doctor == null) return [];

      // Simulate checking availability
      await Future.delayed(const Duration(milliseconds: 300));

      // Return doctor's available slots (in production, check against existing bookings)
      return doctor.availableSlots;
    } catch (e) {
      print('❌ APPOINTMENT_DEBUG: Failed to get slots: $e');
      return [];
    }
  }
}
