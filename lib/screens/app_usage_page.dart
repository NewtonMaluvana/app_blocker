import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:app_usage/app_usage.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:list_item_selector/list_item_selector.dart';
import 'package:android_intent_plus/android_intent.dart';

// Your local imports
import 'package:block_apps/components/app_usage_card.dart';
import 'package:block_apps/constants/colors.dart';

class AppUsagePage extends StatefulWidget {
  const AppUsagePage({super.key});

  @override
  State<AppUsagePage> createState() => _AppUsagePageState();
}

class _AppUsagePageState extends State<AppUsagePage> {
  String selectedValue = "Today";
  final List<String> items = ["Today", "This week", "This Month"];
  
  List<AppUsageDetails> _displayList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsageData();
  }

  /// Formats minutes into "Xd Xh Xm" format
  String _formatDuration(int totalMinutes) {
    if (totalMinutes == 0) return "0 mins";

    Duration duration = Duration(minutes: totalMinutes);
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);

    List<String> parts = [];
    if (days > 0) parts.add("${days}d");
    if (hours > 0) parts.add("${hours}h");
    if (minutes > 0 || parts.isEmpty) parts.add("${minutes}m");

    return parts.join(" ");
  }

  DateTime _getStartDate() {
    DateTime now = DateTime.now();
    switch (selectedValue) {
      case "This week":
        return now.subtract(const Duration(days: 7));
      case "This Month":
        return now.subtract(const Duration(days: 30));
      case "Today":
      default:
        return DateTime(now.year, now.month, now.day);
    }
  }

  Future<void> _fetchUsageData() async {
    setState(() => _isLoading = true);

    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = _getStartDate();

      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(
        startDate,
        endDate,
      );

      List<AppUsageDetails> tempDetails = [];

      for (var usage in infoList) {
        if (usage.usage.inMinutes > 0) {
          try {
            AppInfo? app = await InstalledApps.getAppInfo(usage.packageName);

            if (app != null && app.icon != null) {
              tempDetails.add(
                AppUsageDetails(
                  appName: app.name ?? "Unknown",
                  packageName: usage.packageName,
                  usageMinutes: usage.usage.inMinutes,
                  iconData: app.icon!,
                ),
              );
            }
          } catch (e) {
            continue;
          }
        }
      }

      tempDetails.sort((a, b) => b.usageMinutes.compareTo(a.usageMinutes));

      setState(() {
        _displayList = tempDetails;
      });
    } catch (e) {
      _showPermissionDialog();
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("Enable 'Usage Access' to see your stats."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              const intent = AndroidIntent(
                action: 'android.settings.USAGE_ACCESS_SETTINGS',
              );
              intent.launch();
            },
            child: const Text("Settings"),
          ),
        ],
      ),
    );
  }

  Widget getList() {
    return ListItemSelector(
      focusedBorderColor: color.btnColor,
      borderRadius: 25,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      borderColor: color.btnColor,
      selectedValue: selectedValue,
      items: items,
      hintText: "Select time range",
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() => selectedValue = newValue);
          _fetchUsageData();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: color.bgColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Text(
                      "Apps Usage",
                      style: TextStyle(
                        color: color.colorText2,
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    width: 300,
                    child: getList(),
                  ),
                ],
              ),
              const Gap(15),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_displayList.isEmpty)
                const Center(child: Text("No data found."))
              else
                Column(
                  children: _displayList.map((app) {
                    return AppUsageCard(
                      AppName: app.appName,
                      icon: app.iconData,
                      // Changed: Now uses the formatter for days/hours/mins
                      Time: _formatDuration(app.usageMinutes),
                      Date: selectedValue,
                    );
                  }).toList(),
                ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

class AppUsageDetails {
  final String appName;
  final String packageName;
  final int usageMinutes;
  final Uint8List iconData;

  AppUsageDetails({
    required this.appName,
    required this.packageName,
    required this.usageMinutes,
    required this.iconData,
  });
}
