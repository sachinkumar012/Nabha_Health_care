import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Expert Healthcare',
      description: 'Connect with qualified doctors and healthcare professionals specializing in rural healthcare needs.',
      icon: Icons.medical_services,
      color: AppColors.medical,
    ),
    OnboardingData(
      title: 'Digital Pharmacy',
      description: 'Order medicines online with home delivery and get expert pharmaceutical guidance.',
      icon: Icons.local_pharmacy,
      color: AppColors.pharmacy,
    ),
    OnboardingData(
      title: 'Health Records',
      description: 'Securely store and access your medical records with offline backup capabilities.',
      icon: Icons.folder_shared,
      color: AppColors.accent,
    ),
    OnboardingData(
      title: 'Emergency Support',
      description: 'Get 24/7 emergency support and quick access to nearby hospitals and clinics.',
      icon: Icons.emergency,
      color: AppColors.emergency,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _navigateToLogin,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),
            
            // Page Indicator and Navigation
            Padding(
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              child: Column(
                children: [
                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.largeSpacing),
                  
                  // Navigation Buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            child: const Text('Previous'),
                          ),
                        ),
                      
                      if (_currentPage > 0)
                        const SizedBox(width: AppConstants.mediumSpacing),
                      
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentPage == _onboardingData.length - 1
                              ? _navigateToLogin
                              : _nextPage,
                          child: Text(
                            _currentPage == _onboardingData.length - 1
                                ? 'Get Started'
                                : 'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              data.icon,
              size: 60,
              color: data.color,
            ),
          ),
          
          const SizedBox(height: AppConstants.extraLargeSpacing),
          
          // Title
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppConstants.mediumSpacing),
          
          // Description
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.grey600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.grey300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}