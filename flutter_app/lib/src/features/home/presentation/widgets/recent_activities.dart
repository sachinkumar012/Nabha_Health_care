import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key});

  final List<RecentActivity> _recentActivities = const [
    RecentActivity(
      title: 'Video Consultation',
      subtitle: 'Dr. Smith - Completed',
      time: '2 hours ago',
      icon: Icons.video_call,
      color: AppColors.medical,
    ),
    RecentActivity(
      title: 'Medicine Order',
      subtitle: 'Order #12345 - Delivered',
      time: '1 day ago',
      icon: Icons.local_pharmacy,
      color: AppColors.pharmacy,
    ),
    RecentActivity(
      title: 'Health Checkup',
      subtitle: 'Blood test results updated',
      time: '3 days ago',
      icon: Icons.assignment,
      color: AppColors.secondary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all activities
                },
                child: const Text('View All'),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.mediumSpacing),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentActivities.length,
            itemBuilder: (context, index) {
              return _buildActivityItem(_recentActivities[index], context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity activity, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 24,
            ),
          ),
          
          const SizedBox(width: AppConstants.mediumSpacing),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.grey400,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecentActivity {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  const RecentActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}