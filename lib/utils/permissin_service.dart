import 'package:app_blocker/utils/app_permission_handler.dart';
import 'package:flutter/material.dart';

Future<void> checkAndRequestPermission(BuildContext context) async {
  final hasPermission = await AppPermissionService.hasUsageStatsPermission();

  if (!hasPermission) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'This app needs access to Usage Stats to see which apps are running. '
          'Please enable it in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AppPermissionService.requestUsageStatsPermission();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
