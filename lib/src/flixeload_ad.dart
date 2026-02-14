import 'package:flutter/foundation.dart';
import 'models/ad_config.dart';
import 'services/api_service.dart';
import 'utils/device_info.dart';

/// Main FlixeloAd SDK class
/// Initialize this once in your app's main() function
class FlixeloAd {
  static FlixeloAd? _instance;
  static FlixeloAd get instance => _instance ??= FlixeloAd._();

  FlixeloAd._();

  late ApiService _apiService;
  late AdConfig _config;
  bool _isInitialized = false;

  /// Initialize the FlixeloAd SDK
  /// 
  /// [appId] - Your unique app identifier (e.g., com.example.myapp)
  /// [apiKey] - Your API key from FlixeloAd dashboard
  /// [baseUrl] - Your FlixeloAd backend URL (default: https://flixeload.com)
  /// [testMode] - Enable test mode for development (default: false)
  Future<void> initialize({
    required String appId,
    required String apiKey,
    String baseUrl = 'https://flixeload.com',
    bool testMode = false,
  }) async {
    if (_isInitialized) {
      debugPrint('FlixeloAd: Already initialized');
      return;
    }

    _config = AdConfig(
      appId: appId,
      apiKey: apiKey,
      baseUrl: baseUrl,
      testMode: testMode,
    );

    _apiService = ApiService(config: _config);

    // Initialize device info
    await DeviceInfo.initialize();

    // Register app with backend
    try {
      await _apiService.registerApp();
      _isInitialized = true;
      debugPrint('FlixeloAd: Initialized successfully');
    } catch (e) {
      debugPrint('FlixeloAd: Failed to initialize - $e');
      rethrow;
    }
  }

  /// Check if SDK is initialized
  bool get isInitialized => _isInitialized;

  /// Get the API service instance
  ApiService get apiService {
    if (!_isInitialized) {
      throw Exception('FlixeloAd SDK not initialized. Call FlixeloAd.instance.initialize() first.');
    }
    return _apiService;
  }

  /// Get the current configuration
  AdConfig get config {
    if (!_isInitialized) {
      throw Exception('FlixeloAd SDK not initialized. Call FlixeloAd.instance.initialize() first.');
    }
    return _config;
  }

  /// Set user consent for personalized ads (GDPR compliance)
  void setUserConsent(bool hasConsent) {
    _config.hasUserConsent = hasConsent;
    debugPrint('FlixeloAd: User consent set to $hasConsent');
  }

  /// Set user age for COPPA compliance
  void setUserAge(int age) {
    _config.userAge = age;
    debugPrint('FlixeloAd: User age set to $age');
  }
}
