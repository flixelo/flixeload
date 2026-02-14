/// Configuration for FlixeloAd SDK initialization.
///
/// Contains all necessary configuration parameters for the SDK including
/// authentication credentials, API endpoints, and compliance settings.
class AdConfig {
  /// The unique application identifier registered with FlixeloAd.
  ///
  /// Example: `com.example.myapp`
  final String appId;

  /// Your FlixeloAd API key for authentication.
  ///
  /// Obtain this from your FlixeloAd dashboard.
  final String apiKey;

  /// The base URL for FlixeloAd API endpoints.
  ///
  /// Default: `https://flixeload.com`
  final String baseUrl;

  /// Whether the SDK is running in test mode.
  ///
  /// When `true`, test ads will be served instead of real ads.
  /// Set to `false` in production.
  final bool testMode;

  /// User consent status for personalized ads (GDPR compliance).
  ///
  /// Set to `true` if the user has consented to personalized advertising.
  /// Default: `true`
  bool hasUserConsent;

  /// Optional user age for COPPA compliance.
  ///
  /// If provided, users under 13 will receive non-personalized ads only.
  int? userAge;

  /// Creates a new [AdConfig] instance.
  ///
  /// All required parameters must be provided:
  /// - [appId]: Your application identifier
  /// - [apiKey]: Your FlixeloAd API key  
  /// - [baseUrl]: API endpoint base URL
  ///
  /// Optional parameters:
  /// - [testMode]: Enable test mode (default: `false`)
  /// - [hasUserConsent]: GDPR consent status (default: `true`)
  /// - [userAge]: User age for COPPA compliance
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
