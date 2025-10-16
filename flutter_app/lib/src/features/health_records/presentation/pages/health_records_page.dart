import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class HealthRecordsPage extends StatelessWidget {
  const HealthRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_shared,
              size: 64,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16),
            Text(
              'Health Records',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Access and manage your medical records',
              style: TextStyle(color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}