import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/ad_config.dart';
import '../models/ad_response.dart';
import '../models/ad_type.dart';
import '../utils/device_info.dart';

/// API service for communicating with FlixeloAd backend
class ApiService {
  final AdConfig config;
  
  ApiService({required this.config});

  /// Register app with backend
  Future<Map<String, dynamic>> registerApp() async {
    try {
      final url = Uri.parse(config.getEndpoint('/apps/register'));
      final deviceInfo = await DeviceInfo.getDeviceInfo();
      
      final response = await http.post(
        url,
        headers: config.headers,
        body: jsonEncode({
          'app_id': config.appId,
          'platform': deviceInfo['platform'],
          'device_info': deviceInfo,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register app: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ApiService: registerApp error - $e');
      rethrow;
    }
  }

  /// Request an ad from the backend
  Future<AdResponse> requestAd({
    required AdType adType,
    String? adSize,
    Map<String, dynamic>? targeting,
  }) async {
    try {
      final url = Uri.parse(config.getEndpoint('/ads/request'));
      final deviceInfo = await DeviceInfo.getDeviceInfo();
      
      final body = {
        'app_id': config.appId, // ✅ Added missing app_id
        'ad_type': adSize ?? adType.apiValue,
        'device_info': deviceInfo,
        'user_consent': config.hasUserConsent,
        'is_child': config.isChild,
      };

      if (targeting != null) {
        body['targeting'] = targeting;
      }

      final response = await http.post(
        url,
        headers: config.headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return AdResponse.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load ad');
        }
      } else {
        throw Exception('Failed to request ad: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ApiService: requestAd error - $e');
      rethrow;
    }
  }

  /// Track ad impression
  Future<void> trackImpression(String requestId) async {
    try {
      final url = Uri.parse(config.getEndpoint('/ads/impression'));
      
      await http.post(
        url,
        headers: config.headers,
        body: jsonEncode({
          'request_id': requestId,
        }),
      );
    } catch (e) {
      debugPrint('ApiService: trackImpression error - $e');
    }
  }

  /// Track ad click
  Future<void> trackClick(String requestId) async {
    try {
      final url = Uri.parse(config.getEndpoint('/ads/click'));
      
      await http.post(
        url,
        headers: config.headers,
        body: jsonEncode({
          'request_id': requestId,
        }),
      );
    } catch (e) {
      debugPrint('ApiService: trackClick error - $e');
    }
  }

  /// Get app configuration from backend
  Future<Map<String, dynamic>> getConfig() async {
    try {
      final url = Uri.parse(config.getEndpoint('/apps/config'));
      
      final response = await http.get(
        url,
        headers: config.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to get config: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ApiService: getConfig error - $e');
      rethrow;
    }
  }
}
