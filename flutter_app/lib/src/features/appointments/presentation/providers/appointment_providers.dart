import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/appointment.dart';
import '../../data/services/appointment_booking_service.dart';

// Service provider
final appointmentBookingServiceProvider = Provider<AppointmentBookingService>(
  (ref) => AppointmentBookingService(),
);

// Doctors providers
final allDoctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final service = ref.read(appointmentBookingServiceProvider);
  return await service.getAllDoctors();
});

final doctorsBySpecializationProvider =
    FutureProvider.family<List<Doctor>, String>((ref, specialization) async {
  final service = ref.read(appointmentBookingServiceProvider);
  return await service.getDoctorsBySpecialization(specialization);
});

final doctorByIdProvider =
    FutureProvider.family<Doctor?, String>((ref, doctorId) async {
  final service = ref.read(appointmentBookingServiceProvider);
  return await service.getDoctorById(doctorId);
});

final doctorsSuggestionsProvider =
    FutureProvider.family<List<Doctor>, String>((ref, symptoms) async {
  final service = ref.read(appointmentBookingServiceProvider);
  return await service.suggestDoctorsForSymptoms(symptoms);
});

// Appointments providers
final patientAppointmentsProvider =
    FutureProvider.family<List<Appointment>, String>((ref, patientId) async {
  final service = ref.read(appointmentBookingServiceProvider);
  return await service.getPatientAppointments(patientId);
});

final availableSlotsProvider =
    FutureProvider.family<List<String>, Map<String, dynamic>>(
        (ref, params) async {
  final service = ref.read(appointmentBookingServiceProvider);
  return await service.getAvailableSlots(params['doctorId'], params['date']);
});

// Appointment booking state
class AppointmentBookingState {
  final bool isLoading;
  final String? error;
  final Appointment? bookedAppointment;

  const AppointmentBookingState({
    this.isLoading = false,
    this.error,
    this.bookedAppointment,
  });

  AppointmentBookingState copyWith({
    bool? isLoading,
    String? error,
    Appointment? bookedAppointment,
  }) {
    return AppointmentBookingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      bookedAppointment: bookedAppointment ?? this.bookedAppointment,
    );
  }
}

// Appointment booking notifier
class AppointmentBookingNotifier
    extends StateNotifier<AppointmentBookingState> {
  AppointmentBookingNotifier(this._service)
      : super(const AppointmentBookingState());

  final AppointmentBookingService _service;

  Future<void> bookAppointment({
    required String patientId,
    required String doctorId,
    required AppointmentType type,
    required DateTime dateTime,
    required String reason,
    required String symptoms,
    int durationMinutes = 30,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final appointment = await _service.bookAppointment(
        patientId: patientId,
        doctorId: doctorId,
        type: type,
        dateTime: dateTime,
        reason: reason,
        symptoms: symptoms,
        durationMinutes: durationMinutes,
      );

      state = state.copyWith(
        isLoading: false,
        bookedAppointment: appointment,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _service.cancelAppointment(appointmentId);
      if (!success) {
        throw Exception('Failed to cancel appointment');
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> rescheduleAppointment(
      String appointmentId, DateTime newDateTime) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedAppointment =
          await _service.rescheduleAppointment(appointmentId, newDateTime);
      if (updatedAppointment == null) {
        throw Exception('Failed to reschedule appointment');
      }

      state = state.copyWith(
        isLoading: false,
        bookedAppointment: updatedAppointment,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearBookedAppointment() {
    state = state.copyWith(bookedAppointment: null);
  }
}

// Appointment booking provider
final appointmentBookingProvider =
    StateNotifierProvider<AppointmentBookingNotifier, AppointmentBookingState>(
        (ref) {
  final service = ref.read(appointmentBookingServiceProvider);
  return AppointmentBookingNotifier(service);
});

// Selected appointment data for booking form
class AppointmentFormData {
  final Doctor? selectedDoctor;
  final AppointmentType? selectedType;
  final DateTime? selectedDate;
  final String? selectedTime;
  final String reason;
  final String symptoms;

  const AppointmentFormData({
    this.selectedDoctor,
    this.selectedType,
    this.selectedDate,
    this.selectedTime,
    this.reason = '',
    this.symptoms = '',
  });

  AppointmentFormData copyWith({
    Doctor? selectedDoctor,
    AppointmentType? selectedType,
    DateTime? selectedDate,
    String? selectedTime,
    String? reason,
    String? symptoms,
  }) {
    return AppointmentFormData(
      selectedDoctor: selectedDoctor ?? this.selectedDoctor,
      selectedType: selectedType ?? this.selectedType,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      reason: reason ?? this.reason,
      symptoms: symptoms ?? this.symptoms,
    );
  }

  bool get isValid {
    return selectedDoctor != null &&
        selectedType != null &&
        selectedDate != null &&
        selectedTime != null &&
        reason.isNotEmpty;
  }
}

// Appointment form notifier
class AppointmentFormNotifier extends StateNotifier<AppointmentFormData> {
  AppointmentFormNotifier() : super(const AppointmentFormData());

  void selectDoctor(Doctor doctor) {
    state = state.copyWith(selectedDoctor: doctor);
  }

  void selectType(AppointmentType type) {
    state = state.copyWith(selectedType: type);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void selectTime(String time) {
    state = state.copyWith(selectedTime: time);
  }

  void updateReason(String reason) {
    state = state.copyWith(reason: reason);
  }

  void updateSymptoms(String symptoms) {
    state = state.copyWith(symptoms: symptoms);
  }

  void clearForm() {
    state = const AppointmentFormData();
  }
}

// Appointment form provider
final appointmentFormProvider =
    StateNotifierProvider<AppointmentFormNotifier, AppointmentFormData>((ref) {
  return AppointmentFormNotifier();
});
