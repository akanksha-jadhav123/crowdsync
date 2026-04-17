class AppConfig {
  // Change this to your computer's IP if running on a physical device
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  // Use localhost for web or Windows desktop
  static const String baseUrlDesktop = 'http://localhost:3000/api';
  
  static const String appName = 'CrowdSync';
  static const String appVersion = '1.0.0';
  
  static String getBaseUrl(bool isDesktop) {
    return isDesktop ? baseUrlDesktop : baseUrl;
  }
}
