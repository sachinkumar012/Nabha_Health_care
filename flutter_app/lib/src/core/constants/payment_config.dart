class PaymentConfig {
  // Razorpay Configuration
  static const String razorpayKeyId = 'rzp_test_5KDLZcQOeZLk8K';
  static const String razorpayKeySecret = 'iup6OxBjjs22NfyIV2vN4x8p';
  static const String razorpayMonthlyPlanId = 'plan_Qq8H89m2adcMl6';
  static const String razorpayYearlyPlanId = 'plan_Qq8Hl09aOS9uAg';
  static const String razorpayWebhookSecret =
      '69f8825c-ae86-4a76-89d5-501a621e772e';
  static const String paymentApiUrl = 'http://localhost:3001/api/payments';

  // Currency
  static const String currency = 'INR';

  // Company Information
  static const String companyName = 'Nabha Healthcare';
  static const String companyLogo = 'assets/images/nabha_logo.png';
  static const String companyDescription = 'Healthcare & Medicine Delivery';

  // Payment notes and themes
  static const int themeColor = 0xFF1976D2; // Blue theme
}
