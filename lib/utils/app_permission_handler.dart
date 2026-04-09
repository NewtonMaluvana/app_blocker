import 'package:flutter/services.dart';

class AppPermissionService {
  static const _channel = MethodChannel('com.example.app_blocker/usage_stats');

  /// Opens the Usage Access settings screen
  static Future<void> requestUsageStatsPermission() async {
    await _channel.invokeMethod('openUsageSettings');
  }

  /// Check if usage stats permission is granted
  static Future<bool> hasUsageStatsPermission() async {
    final granted = await _channel.invokeMethod<bool>(
      'hasUsageStatsPermission',
    );
    return granted ?? false;
  }
}
