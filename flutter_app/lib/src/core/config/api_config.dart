class ApiConfig {
  // Change this to your actual backend URL
  static const String baseUrl = 'http://localhost:5000'; // or your deployed backend URL
  
  // Video Consultation Endpoints
  static const String doctorsEndpoint = '/api/video-consultations/doctors';
  static const String bookConsultationEndpoint = '/api/video-consultations/book';
  static const String myConsultationsEndpoint = '/api/video-consultations/my-consultations';
  static const String cancelConsultationEndpoint = '/api/video-consultations/cancel';
  static const String rescheduleConsultationEndpoint = '/api/video-consultations/reschedule';
  static const String joinCallEndpoint = '/api/video-consultations/join';
  
  // Helper methods
  static String get doctors => '$baseUrl$doctorsEndpoint';
  static String get bookConsultation => '$baseUrl$bookConsultationEndpoint';
  static String get myConsultations => '$baseUrl$myConsultationsEndpoint';
  static String get cancelConsultation => '$baseUrl$cancelConsultationEndpoint';
  static String get rescheduleConsultation => '$baseUrl$rescheduleConsultationEndpoint';
  static String get joinCall => '$baseUrl$joinCallEndpoint';
}
