import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class for fetching device-specific info
class DeviceUtils {
  DeviceUtils._(); // Private constructor

  /// Get screen width
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get screen height
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Get status bar height
  static double getStatusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  /// Get bottom safe area (useful for iPhone with notches)
  static double getBottomSafeArea(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = math.sqrt(
      (size.width * size.width) + (size.height * size.height),
    );
    return diagonal > 1100.0; // Rough threshold for tablets
  }

  /// Check platform type
  static bool isAndroid() => Platform.isAndroid;
  static bool isIOS() => Platform.isIOS;
  static bool isWeb() => identical(0, 0.0); // Flutter web detection trick

  /// Get device info (Model, OS version, etc.)
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      return {
        "platform": "Android",
        "model": androidInfo.model,
        "manufacturer": androidInfo.manufacturer,
        "version": androidInfo.version.release,
        "sdkInt": androidInfo.version.sdkInt,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      return {
        "platform": "iOS",
        "model": iosInfo.utsname.machine,
        "name": iosInfo.name,
        "systemVersion": iosInfo.systemVersion,
      };
    }
    return {"platform": "Unknown"};
  }

  /// Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Launch a URL (web, tel, mail, etc.)
  static Future<void> launchAppUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("❌ Could not launch $url");
      throw 'Could not launch $url';
    }
  }
}
