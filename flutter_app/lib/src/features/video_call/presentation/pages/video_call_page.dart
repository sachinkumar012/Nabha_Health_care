import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class VideoCallPage extends StatelessWidget {
  const VideoCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_call,
              size: 64,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16),
            Text(
              'Video Consultation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Connect with doctors remotely',
              style: TextStyle(color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}