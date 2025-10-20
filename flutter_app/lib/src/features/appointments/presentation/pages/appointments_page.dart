import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/user_provider.dart';
import '../providers/appointment_providers.dart';
import '../widgets/appointment_booking_widget.dart';
import '../widgets/appointment_card.dart';
import '../../domain/models/appointment.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Book New', icon: Icon(Icons.add_circle_outline)),
            Tab(text: 'Upcoming', icon: Icon(Icons.schedule)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Book New Appointment Tab
          const AppointmentBookingWidget(),

          // Upcoming Appointments Tab
          _buildUpcomingAppointments(user?.id),

          // History Tab
          _buildAppointmentHistory(user?.id),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments(String? userId) {
    if (userId == null) {
      return const Center(
        child: Text('Please log in to view appointments'),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final appointmentsAsync =
            ref.watch(patientAppointmentsProvider(userId));

        return appointmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading appointments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.grey600),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.refresh(patientAppointmentsProvider(userId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (appointments) {
            final upcomingAppointments = appointments
                .where((apt) =>
                    apt.dateTime.isAfter(DateTime.now()) &&
                    apt.status != AppointmentStatus.cancelled)
                .toList();

            upcomingAppointments
                .sort((a, b) => a.dateTime.compareTo(b.dateTime));

            if (upcomingAppointments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 64,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Upcoming Appointments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Book a new appointment to get started',
                      style: TextStyle(color: AppColors.grey600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _tabController.animateTo(0),
                      icon: const Icon(Icons.add),
                      label: const Text('Book Appointment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.refresh(patientAppointmentsProvider(userId));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: upcomingAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = upcomingAppointments[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppointmentCard(
                      appointment: appointment,
                      onCancel: () => _showCancelDialog(appointment),
                      onReschedule: () => _showRescheduleDialog(appointment),
                      onJoinCall: appointment.type == AppointmentType.video
                          ? () => _joinVideoCall(appointment)
                          : null,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppointmentHistory(String? userId) {
    if (userId == null) {
      return const Center(
        child: Text('Please log in to view appointment history'),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final appointmentsAsync =
            ref.watch(patientAppointmentsProvider(userId));

        return appointmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading history',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.grey600),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.refresh(patientAppointmentsProvider(userId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (appointments) {
            final pastAppointments = appointments
                .where((apt) =>
                    apt.dateTime.isBefore(DateTime.now()) ||
                    apt.status == AppointmentStatus.cancelled ||
                    apt.status == AppointmentStatus.completed)
                .toList();

            pastAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));

            if (pastAppointments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Appointment History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your completed appointments will appear here',
                      style: TextStyle(color: AppColors.grey600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.refresh(patientAppointmentsProvider(userId));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pastAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = pastAppointments[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppointmentCard(
                      appointment: appointment,
                      isHistoryView: true,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showCancelDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this appointment?'),
            const SizedBox(height: 16),
            Text(
              'Dr. ${appointment.doctorName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(appointment.dateTime),
              style: const TextStyle(color: AppColors.grey600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Show loading before closing dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Text('Cancelling appointment...'),
                    ],
                  ),
                  duration: Duration(seconds: 2),
                ),
              );

              Navigator.pop(dialogContext);

              await ref
                  .read(appointmentBookingProvider.notifier)
                  .cancelAppointment(appointment.id);

              final bookingState = ref.read(appointmentBookingProvider);

              if (bookingState.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Appointment cancelled successfully'),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );

                // Refresh appointments list
                final user = ref.read(userProvider);
                if (user != null) {
                  ref.invalidate(patientAppointmentsProvider(user.id));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                'Failed to cancel: ${bookingState.error}')),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(Appointment appointment) {
    DateTime? selectedDate;
    String? selectedTime;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reschedule Appointment'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current appointment with Dr. ${appointment.doctorName}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a')
                      .format(appointment.dateTime),
                  style: const TextStyle(color: AppColors.grey600),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select new date:',
                  style: TextStyle(fontWeight: FontWeight.w600),
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
                      setState(() {
                        selectedDate = date;
                        selectedTime = null; // Reset time when date changes
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate != null
                              ? DateFormat('MMM dd, yyyy').format(selectedDate!)
                              : 'Select new date',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedDate != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Available times:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, child) {
                      final availableSlotsAsync =
                          ref.watch(availableSlotsProvider({
                        'doctorId': appointment.doctorId,
                        'date': selectedDate!,
                      }));

                      return availableSlotsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) =>
                            Text('Error loading slots: $error'),
                        data: (slots) => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: slots.map((slot) {
                            final isSelected = selectedTime == slot;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedTime = slot;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.grey300,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  slot,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.grey700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedDate != null && selectedTime != null
                  ? () async {
                      Navigator.pop(dialogContext);

                      // Parse the selected time and create DateTime
                      final timeParts = selectedTime!.split(':');
                      final hour = int.parse(timeParts[0]);
                      final minute = int.parse(timeParts[1].split(' ')[0]);
                      final isPM = selectedTime!.contains('PM');
                      final finalHour = isPM && hour != 12
                          ? hour + 12
                          : (hour == 12 && !isPM ? 0 : hour);

                      final newDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        finalHour,
                        minute,
                      );

                      // Show loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 12),
                              Text('Rescheduling appointment...'),
                            ],
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      await ref
                          .read(appointmentBookingProvider.notifier)
                          .rescheduleAppointment(appointment.id, newDateTime);

                      final bookingState = ref.read(appointmentBookingProvider);

                      if (bookingState.error == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Appointment rescheduled to ${DateFormat('MMM dd, yyyy • hh:mm a').format(newDateTime)}',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );

                        // Refresh appointments list
                        final user = ref.read(userProvider);
                        if (user != null) {
                          ref.invalidate(patientAppointmentsProvider(user.id));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        'Failed to reschedule: ${bookingState.error}')),
                              ],
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reschedule'),
            ),
          ],
        ),
      ),
    );
  }

  void _joinVideoCall(Appointment appointment) {
    if (appointment.meetingUrl != null) {
      // TODO: Implement video call joining
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joining video call: ${appointment.meetingUrl}'),
        ),
      );
    }
  }
}
