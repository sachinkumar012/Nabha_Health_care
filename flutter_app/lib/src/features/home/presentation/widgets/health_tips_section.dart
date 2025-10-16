import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class HealthTipsSection extends StatelessWidget {
  const HealthTipsSection({super.key});

  final List<HealthTip> _healthTips = const [
    HealthTip(
      title: 'Stay Hydrated',
      description: 'Drink at least 8 glasses of water daily for optimal health.',
      icon: Icons.water_drop,
      color: AppColors.medical,
    ),
    HealthTip(
      title: 'Regular Exercise',
      description: '30 minutes of daily exercise keeps you fit and healthy.',
      icon: Icons.fitness_center,
      color: AppColors.success,
    ),
    HealthTip(
      title: 'Healthy Diet',
      description: 'Include fruits and vegetables in your daily meals.',
      icon: Icons.restaurant,
      color: AppColors.warning,
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
                'Health Tips',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all tips
                },
                child: const Text('View All'),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.mediumSpacing),
          
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _healthTips.length,
              itemBuilder: (context, index) {
                return _buildHealthTipCard(_healthTips[index], context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTipCard(HealthTip tip, BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppConstants.mediumSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tip.color.withOpacity(0.8),
            tip.color,
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: tip.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          onTap: () => _showTipDetails(tip, context),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        tip.icon,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.white.withOpacity(0.7),
                      size: 16,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.mediumSpacing),
                
                Text(
                  tip.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: AppConstants.smallSpacing),
                
                Text(
                  tip.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTipDetails(HealthTip tip, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(tip.icon, color: tip.color),
            const SizedBox(width: 8),
            Text(tip.title),
          ],
        ),
        content: Text(tip.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class HealthTip {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const HealthTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}