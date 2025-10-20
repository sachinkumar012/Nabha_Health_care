import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onJoinCall;
  final bool isHistoryView;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
    this.onReschedule,
    this.onJoinCall,
    this.isHistoryView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAppointmentDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(appointment.doctorImage),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${appointment.doctorName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appointment.doctorSpecialization,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 16),

              // Appointment details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Date & Time',
                      DateFormat('MMM dd, yyyy • hh:mm a')
                          .format(appointment.dateTime),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      _getAppointmentTypeIcon(appointment.type),
                      'Type',
                      appointment.typeDisplayName,
                    ),
                    if (appointment.reason.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.description,
                        'Reason',
                        appointment.reason,
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.currency_rupee,
                      'Fee',
                      '₹${appointment.fee.toInt()}',
                    ),
                  ],
                ),
              ),

              // Action buttons
              if (!isHistoryView) ...[
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (appointment.status) {
      case AppointmentStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        icon = Icons.schedule;
        break;
      case AppointmentStatus.confirmed:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      case AppointmentStatus.cancelled:
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        icon = Icons.cancel;
        break;
      case AppointmentStatus.completed:
        backgroundColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        icon = Icons.done_all;
        break;
      case AppointmentStatus.inProgress:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        icon = Icons.play_circle;
        break;
      case AppointmentStatus.rescheduled:
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        icon = Icons.update;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            appointment.statusDisplayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.grey600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.grey600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final now = DateTime.now();
    final appointmentTime = appointment.dateTime;
    final canJoinCall = appointment.type == AppointmentType.video &&
        appointment.status == AppointmentStatus.confirmed &&
        appointmentTime.difference(now).inMinutes <= 15 &&
        appointmentTime.isAfter(now.subtract(const Duration(minutes: 30)));

    List<Widget> buttons = [];

    // Join call button for video appointments
    if (canJoinCall && onJoinCall != null) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onJoinCall,
            icon: const Icon(Icons.video_call),
            label: const Text('Join Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );
    }

    // Cancel button
    if (appointment.status == AppointmentStatus.pending ||
        appointment.status == AppointmentStatus.confirmed) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 8));

      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      );
    }

    // Reschedule button
    if (appointment.status == AppointmentStatus.pending ||
        appointment.status == AppointmentStatus.confirmed) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 8));

      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onReschedule,
            icon: const Icon(Icons.schedule),
            label: const Text('Reschedule'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: buttons);
  }

  IconData _getAppointmentTypeIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.video:
        return Icons.video_call;
      case AppointmentType.phone:
        return Icons.phone;
      case AppointmentType.inPerson:
        return Icons.person;
      case AppointmentType.chat:
        return Icons.chat;
    }
  }

  void _showAppointmentDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dr. ${appointment.doctorName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem(
                  'Specialization', appointment.doctorSpecialization),
              _buildDetailItem('Type', appointment.typeDisplayName),
              _buildDetailItem(
                  'Date & Time',
                  DateFormat('MMM dd, yyyy • hh:mm a')
                      .format(appointment.dateTime)),
              _buildDetailItem('Status', appointment.statusDisplayName),
              _buildDetailItem('Fee', '₹${appointment.fee.toInt()}'),
              if (appointment.reason.isNotEmpty)
                _buildDetailItem('Reason', appointment.reason),
              if (appointment.symptoms.isNotEmpty)
                _buildDetailItem('Symptoms', appointment.symptoms),
              if (appointment.notes != null)
                _buildDetailItem('Notes', appointment.notes!),
              if (appointment.meetingUrl != null)
                _buildDetailItem('Meeting URL', appointment.meetingUrl!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
