import 'package:flutter/material.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart'
    as ProfileModule;
import '../../features/appointments/presentation/pages/appointments_page.dart'
    as AppointmentsModule;
import '../../features/pharmacy/presentation/pages/pharmacy_page.dart'
    as PharmacyModule;
import '../../features/symptom_checker/presentation/pages/symptom_checker_page.dart';
import '../../features/hospitals/presentation/pages/hospitals_page.dart';
import '../../features/health_records/presentation/pages/health_records_page.dart';
import '../../features/video_call/presentation/pages/video_call_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String appointments = '/appointments';
  static const String pharmacy = '/pharmacy';
  static const String symptomChecker = '/symptom-checker';
  static const String hospitals = '/hospitals';
  static const String healthRecords = '/health-records';
  static const String videoCall = '/video-call';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashPage(),
      onboarding: (context) => const OnboardingPage(),
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      home: (context) => const HomePage(),
      profile: (context) => const ProfileModule.ProfilePage(),
      appointments: (context) => const AppointmentsModule.AppointmentsPage(),
      pharmacy: (context) => const PharmacyModule.PharmacyPage(),
      symptomChecker: (context) => SymptomCheckerPage(),
      hospitals: (context) => const HospitalsPage(),
      healthRecords: (context) => const HealthRecordsPage(),
      videoCall: (context) => const VideoCallPage(),
    };
  }
}
