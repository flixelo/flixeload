/// Configuration for FlixeloAd SDK
class AdConfig {
  final String appId;
  final String apiKey;
  final String baseUrl;
  final bool testMode;
  bool hasUserConsent;
  int? userAge;

  AdConfig({
    required this.appId,
    required this.apiKey,
    required this.baseUrl,
    this.testMode = false,
    this.hasUserConsent = true,
    this.userAge,
  });

  /// Get API endpoint URL
  String getEndpoint(String path) {
    return '$baseUrl/api/mobile$path';
  }

  /// Check if user is child (COPPA)
  bool get isChild => userAge != null && userAge! < 13;

  /// Get headers for API requests
  Map<String, String> get headers => {
    'X-API-Key': apiKey,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
