import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/user_provider.dart';
import '../providers/appointment_providers.dart';
import '../../domain/models/appointment.dart';

class AppointmentBookingWidget extends ConsumerStatefulWidget {
  const AppointmentBookingWidget({super.key});

  @override
  ConsumerState<AppointmentBookingWidget> createState() =>
      _AppointmentBookingWidgetState();
}

class _AppointmentBookingWidgetState
    extends ConsumerState<AppointmentBookingWidget> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form controllers
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _symptomsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.grey50,
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < 3 ? 8 : 0,
                    ),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? AppColors.primary
                          : AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Page view
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildSymptomsStep(),
                _buildDoctorSelectionStep(),
                _buildAppointmentTypeStep(),
                _buildDateTimeStep(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.grey200)),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep < 3 ? _nextStep : _bookAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_currentStep < 3 ? 'Next' : 'Book Appointment'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about your symptoms',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our AI will suggest the best doctor for you',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),

          // Symptoms input
          TextFormField(
            controller: _symptomsController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Describe your symptoms',
              hintText: 'e.g., headache, fever, stomach pain...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            onChanged: (value) {
              ref.read(appointmentFormProvider.notifier).updateSymptoms(value);
            },
          ),
          const SizedBox(height: 16),

          // Quick symptom buttons
          const Text(
            'Common symptoms:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Fever',
              'Headache',
              'Cough',
              'Stomach pain',
              'Body ache',
              'Chest pain',
              'Skin problem',
              'Eye problem',
            ].map((symptom) {
              return ActionChip(
                label: Text(symptom),
                onPressed: () {
                  final current = _symptomsController.text;
                  final newText =
                      current.isEmpty ? symptom : '$current, $symptom';
                  _symptomsController.text = newText;
                  ref
                      .read(appointmentFormProvider.notifier)
                      .updateSymptoms(newText);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSelectionStep() {
    final formData = ref.watch(appointmentFormProvider);

    return Consumer(
      builder: (context, ref, child) {
        if (formData.symptoms.isEmpty) {
          return const Center(
            child: Text('Please describe your symptoms first'),
          );
        }

        final doctorSuggestionsAsync =
            ref.watch(doctorsSuggestionsProvider(formData.symptoms));

        return doctorSuggestionsAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('🤖 AI is analyzing your symptoms...'),
                SizedBox(height: 8),
                Text(
                  'Finding the best doctors for you',
                  style: TextStyle(color: AppColors.grey600),
                ),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                const Text('Failed to get doctor suggestions'),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.grey600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .refresh(doctorsSuggestionsProvider(formData.symptoms)),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
          data: (doctors) {
            if (doctors.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.grey400,
                    ),
                    SizedBox(height: 16),
                    Text('No doctors found'),
                    SizedBox(height: 8),
                    Text(
                      'Please try different symptoms',
                      style: TextStyle(color: AppColors.grey600),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recommended doctors',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '🤖 AI Suggested',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Based on your symptoms',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...doctors.map((doctor) {
                    final isSelected = formData.selectedDoctor?.id == doctor.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(appointmentFormProvider.notifier)
                              .selectDoctor(doctor);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.grey200,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.05)
                                : null,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(doctor.image),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      doctor.specialization,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${doctor.rating} • ${doctor.experienceYears} years',
                                          style: const TextStyle(
                                            color: AppColors.grey600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${doctor.consultationFee.toInt()}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppointmentTypeStep() {
    final formData = ref.watch(appointmentFormProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose consultation type',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select how you want to consult',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),

          // Reason input
          TextFormField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason for appointment',
              hintText: 'e.g., Regular checkup, Follow-up...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              ref.read(appointmentFormProvider.notifier).updateReason(value);
            },
          ),
          const SizedBox(height: 24),

          // Appointment types
          ...AppointmentType.values.map((type) {
            final isSelected = formData.selectedType == type;
            IconData icon;
            String title;
            String description;
            String price;

            switch (type) {
              case AppointmentType.video:
                icon = Icons.video_call;
                title = 'Video Consultation';
                description = 'Face-to-face consultation via video call';
                price =
                    '₹${formData.selectedDoctor?.consultationFee.toInt() ?? 500}';
                break;
              case AppointmentType.phone:
                icon = Icons.phone;
                title = 'Phone Consultation';
                description = 'Voice-only consultation call';
                price =
                    '₹${((formData.selectedDoctor?.consultationFee ?? 500) * 0.7).toInt()}';
                break;
              case AppointmentType.inPerson:
                icon = Icons.person;
                title = 'In-Person Visit';
                description = 'Visit doctor at clinic';
                price =
                    '₹${formData.selectedDoctor?.consultationFee.toInt() ?? 500}';
                break;
              case AppointmentType.chat:
                icon = Icons.chat;
                title = 'Text Consultation';
                description = 'Text-based consultation';
                price =
                    '₹${((formData.selectedDoctor?.consultationFee ?? 500) * 0.5).toInt()}';
                break;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  ref.read(appointmentFormProvider.notifier).selectType(type);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.grey200,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color:
                        isSelected ? AppColors.primary.withOpacity(0.05) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 32,
                        color:
                            isSelected ? AppColors.primary : AppColors.grey600,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.grey900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: const TextStyle(
                                color: AppColors.grey600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.success,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDateTimeStep() {
    final formData = ref.watch(appointmentFormProvider);
    final selectedDoctor = formData.selectedDoctor;

    if (selectedDoctor == null) {
      return const Center(child: Text('Please select a doctor first'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select date and time',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your preferred slot',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),

          // Date picker
          const Text(
            'Select Date:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );

              if (date != null) {
                ref.read(appointmentFormProvider.notifier).selectDate(date);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    formData.selectedDate != null
                        ? '${formData.selectedDate!.day}/${formData.selectedDate!.month}/${formData.selectedDate!.year}'
                        : 'Select date',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Time slots
          if (formData.selectedDate != null) ...[
            const Text(
              'Available Times:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: selectedDoctor.availableSlots.map((slot) {
                final isSelected = formData.selectedTime == slot;

                return InkWell(
                  onTap: () {
                    ref.read(appointmentFormProvider.notifier).selectTime(slot);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.grey300,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.grey700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _bookAppointment() async {
    final user = ref.read(userProvider);
    final formData = ref.read(appointmentFormProvider);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book appointment')),
      );
      return;
    }

    if (!formData.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Parse the selected time and create DateTime
    final selectedDate = formData.selectedDate!;
    final timeParts = formData.selectedTime!.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1].split(' ')[0]);
    final isPM = formData.selectedTime!.contains('PM');
    final finalHour =
        isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);

    final appointmentDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      finalHour,
      minute,
    );

    print('📅 BOOKING_DEBUG: Booking appointment...');
    print('📅 BOOKING_DEBUG: Doctor: ${formData.selectedDoctor!.name}');
    print('📅 BOOKING_DEBUG: Type: ${formData.selectedType}');
    print('📅 BOOKING_DEBUG: DateTime: $appointmentDateTime');
    print('📅 BOOKING_DEBUG: Reason: ${formData.reason}');
    print('📅 BOOKING_DEBUG: Symptoms: ${formData.symptoms}');

    await ref.read(appointmentBookingProvider.notifier).bookAppointment(
          patientId: user.id,
          doctorId: formData.selectedDoctor!.id,
          type: formData.selectedType!,
          dateTime: appointmentDateTime,
          reason: formData.reason,
          symptoms: formData.symptoms,
        );

    final bookingState = ref.read(appointmentBookingProvider);

    if (bookingState.bookedAppointment != null) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment booked successfully! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );

      // Reset form
      ref.read(appointmentFormProvider.notifier).clearForm();
      _symptomsController.clear();
      _reasonController.clear();
      setState(() {
        _currentStep = 0;
      });
      _pageController.animateToPage(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

      // Show success dialog
      _showSuccessDialog(bookingState.bookedAppointment!);
    } else if (bookingState.error != null) {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book appointment: ${bookingState.error}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog(Appointment appointment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            SizedBox(width: 12),
            Text('Appointment Booked!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your appointment has been confirmed:'),
            const SizedBox(height: 16),
            _buildDetailRow('Doctor:', 'Dr. ${appointment.doctorName}'),
            _buildDetailRow(
                'Specialization:', appointment.doctorSpecialization),
            _buildDetailRow('Type:', appointment.typeDisplayName),
            _buildDetailRow('Date:',
                '${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year}'),
            _buildDetailRow('Time:',
                '${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}'),
            _buildDetailRow('Fee:', '₹${appointment.fee.toInt()}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'You will receive appointment details via SMS and email.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.grey600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
