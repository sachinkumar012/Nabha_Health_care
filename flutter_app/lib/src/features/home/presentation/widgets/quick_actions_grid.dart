import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  final List<QuickAction> _quickActions = const [
    QuickAction(
      title: 'Video Consultation',
      subtitle: 'Talk to doctors',
      icon: Icons.video_call,
      color: AppColors.medical,
    ),
    QuickAction(
      title: 'Book Appointment',
      subtitle: 'Schedule visit',
      icon: Icons.calendar_today,
      color: AppColors.appointment,
    ),
    QuickAction(
      title: 'Pharmacy',
      subtitle: 'Order medicines',
      icon: Icons.local_pharmacy,
      color: AppColors.pharmacy,
    ),
    QuickAction(
      title: 'Health Records',
      subtitle: 'View history',
      icon: Icons.folder_shared,
      color: AppColors.secondary,
    ),
    QuickAction(
      title: 'Symptom Checker',
      subtitle: 'Check symptoms',
      icon: Icons.psychology,
      color: AppColors.accent,
    ),
    QuickAction(
      title: 'Find Hospitals',
      subtitle: 'Nearby hospitals',
      icon: Icons.local_hospital,
      color: AppColors.emergency,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppConstants.mediumSpacing,
              mainAxisSpacing: AppConstants.mediumSpacing,
              childAspectRatio: 1.2,
            ),
            itemCount: _quickActions.length,
            itemBuilder: (context, index) {
              return _buildQuickActionCard(_quickActions[index], context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(QuickAction action, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          onTap: () => _handleActionTap(action, context),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppConstants.mediumSpacing),
                Text(
                  action.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleActionTap(QuickAction action, BuildContext context) {
    // Handle specific actions with proper navigation
    switch (action.title) {
      case 'Find Hospitals':
        Navigator.of(context).pushNamed('/hospitals');
        break;
      case 'Pharmacy':
        Navigator.of(context).pushNamed('/pharmacy');
        break;
      case 'Book Appointment':
        Navigator.of(context).pushNamed('/appointments');
        break;
      case 'Health Records':
        Navigator.of(context).pushNamed('/health-records');
        break;
      case 'Video Consultation':
        Navigator.of(context).pushNamed('/video-call');
        break;
      case 'Symptom Checker':
        Navigator.of(context).pushNamed('/symptom-checker');
        break;
      default:
        // Show coming soon dialog for actions not yet implemented
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(action.title),
            content: Text('${action.title} feature is coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        break;
    }
  }
}

class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
