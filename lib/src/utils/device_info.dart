import 'dart:io';
import 'package:flutter/foundation.dart';

/// Device information utility
class DeviceInfo {
  static Map<String, dynamic>? _cachedInfo;

  static Future<void> initialize() async {
    _cachedInfo = await _fetchDeviceInfo();
  }

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    _cachedInfo ??= await _fetchDeviceInfo();
    return Map<String, dynamic>.from(_cachedInfo!);
  }

  static Future<Map<String, dynamic>> _fetchDeviceInfo() async {
    final info = <String, dynamic>{};

    try {
      // Platform
      if (kIsWeb) {
        info['platform'] = 'web';
      } else if (Platform.isAndroid) {
        info['platform'] = 'android';
      } else if (Platform.isIOS) {
        info['platform'] = 'ios';
      } else {
        info['platform'] = 'unknown';
      }

      // OS Version
      if (!kIsWeb) {
        info['os_version'] = Platform.operatingSystemVersion;
      }

      // Screen size (will be set by widgets)
      info['screen_width'] = 0;
      info['screen_height'] = 0;

      // Language
      info['language'] = Platform.localeName.split('_').first;

      // Connection type (simplified)
      info['connection_type'] = 'unknown';

    } catch (e) {
      debugPrint('DeviceInfo: Error fetching device info - $e');
    }

    return info;
  }

  static void updateScreenSize(double width, double height) {
    if (_cachedInfo != null) {
      _cachedInfo!['screen_width'] = width.toInt();
      _cachedInfo!['screen_height'] = height.toInt();
    }
  }
}
