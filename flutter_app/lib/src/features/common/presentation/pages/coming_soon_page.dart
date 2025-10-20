import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ComingSoonPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const ComingSoonPage({
    super.key,
    required this.title,
    this.description = 'This feature is under development and will be available soon.',
    this.icon = Icons.construction,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Coming Soon',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}