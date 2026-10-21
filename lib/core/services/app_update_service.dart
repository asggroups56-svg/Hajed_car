import 'dart:convert';
import 'dart:io';

import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateInfo {
  final bool hasUpdate;
  final String currentVersion;
  final String storeVersion;
  final String updateUrl;
  final String? releaseNotes;
  final bool isForceUpdate;

  AppUpdateInfo({
    required this.hasUpdate,
    required this.currentVersion,
    required this.storeVersion,
    required this.updateUrl,
    this.releaseNotes,
    this.isForceUpdate = false,
  });
}

class AppUpdateService {
  static const String _iosBundleId = 'com.Hajed.car';
  static const String _iosAppId = '6816629989';
  static const String _androidPackageName = 'com.Hajed.car';
  static const String _dismissedVersionKey = 'dismissed_update_version';

  static DateTime? _lastCheckTime;
  static bool _isDialogShowing = false;

  /// Saves the store version the user already acted on (tapped "Update Now").
  /// The dialog will not appear again until a newer version is published.
  static void _saveDismissedVersion(String version) {
    try {
      Hive.box('app').put(_dismissedVersionKey, version);
    } catch (_) {}
  }

  /// Returns the store version that the user previously dismissed / acted on.
  static String? _getDismissedVersion() {
    try {
      return Hive.box('app').get(_dismissedVersionKey) as String?;
    } catch (_) {
      return null;
    }
  }

  /// Checks if a new version is available on App Store / Play Store.
  static Future<AppUpdateInfo?> checkUpdate({bool forceUpdate = false}) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (Platform.isIOS) {
        return await _checkIosUpdate(currentVersion, forceUpdate: forceUpdate);
      } else if (Platform.isAndroid) {
        return await _checkAndroidUpdate(currentVersion, forceUpdate: forceUpdate);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AppUpdateService] Error checking for update: $e');
      }
    }
    return null;
  }

  /// Automatically checks and displays an update dialog if an update is found.
  static Future<void> checkForUpdate(
    BuildContext context, {
    bool isForceUpdate = false,
    bool forceCheck = false,
  }) async {
    // Avoid spamming check if checked recently (within 10 minutes) unless forced
    if (!forceCheck && _lastCheckTime != null) {
      final diff = DateTime.now().difference(_lastCheckTime!);
      if (diff.inMinutes < 10) return;
    }
    _lastCheckTime = DateTime.now();

    final updateInfo = await checkUpdate(forceUpdate: isForceUpdate);
    if (updateInfo != null && updateInfo.hasUpdate && context.mounted) {
      // Skip if user already acted on this exact store version
      final dismissed = _getDismissedVersion();
      if (dismissed != null && dismissed == updateInfo.storeVersion) {
        return;
      }
      showUpdateDialog(context, updateInfo);
    }
  }

  static Future<AppUpdateInfo?> _checkIosUpdate(
    String currentVersion, {
    bool forceUpdate = false,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
      'https://itunes.apple.com/lookup?bundleId=$_iosBundleId&country=sa&t=$timestamp',
    );

    final response = await http.get(url, headers: {'Cache-Control': 'no-cache'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>?;

      if (results != null && results.isNotEmpty) {
        final storeData = results.first as Map<String, dynamic>;
        final storeVersion = storeData['version']?.toString() ?? '';
        final trackViewUrl =
            storeData['trackViewUrl']?.toString() ?? 'https://apps.apple.com/sa/app/id$_iosAppId';
        final releaseNotes = storeData['releaseNotes']?.toString();

        final hasUpdate = _isVersionGreater(storeVersion, currentVersion);

        return AppUpdateInfo(
          hasUpdate: hasUpdate,
          currentVersion: currentVersion,
          storeVersion: storeVersion,
          updateUrl: trackViewUrl,
          releaseNotes: releaseNotes,
          isForceUpdate: forceUpdate,
        );
      }
    }
    return null;
  }

  static Future<AppUpdateInfo?> _checkAndroidUpdate(
    String currentVersion, {
    bool forceUpdate = false,
  }) async {
    // Default Android store URL
    const storeUrl = 'https://play.google.com/store/apps/details?id=$_androidPackageName';
    return AppUpdateInfo(
      hasUpdate: false,
      currentVersion: currentVersion,
      storeVersion: currentVersion,
      updateUrl: storeUrl,
      isForceUpdate: forceUpdate,
    );
  }

  /// Compares semantic versions (e.g. "1.9.33" > "1.9.32")
  static bool _isVersionGreater(String newVersion, String currentVersion) {
    if (newVersion.isEmpty || currentVersion.isEmpty) return false;
    // Clean versions of any build suffixes like +30
    final cleanNew = newVersion.split('+').first.trim();
    final cleanCurrent = currentVersion.split('+').first.trim();
    final newParts = cleanNew.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = newParts.length > currentParts.length ? newParts.length : currentParts.length;

    for (int i = 0; i < maxLength; i++) {
      final v1 = i < newParts.length ? newParts[i] : 0;
      final v2 = i < currentParts.length ? currentParts[i] : 0;

      if (v1 > v2) return true;
      if (v1 < v2) return false;
    }

    return false;
  }

  /// Shows the update dialog to the user
  static void showUpdateDialog(BuildContext context, AppUpdateInfo info) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: !info.isForceUpdate,
      builder: (ctx) => PopScope(
        canPop: !info.isForceUpdate,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          backgroundColor: AppColor.scaffoldColor(ctx),
          elevation: 10,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header with pulse background
                Container(
                  width: 72.r,
                  height: 72.r,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor(ctx).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.system_update_rounded,
                      color: AppColor.primaryColor(ctx),
                      size: 38.sp,
                    ),
                  ),
                ),
                Gap(16.h),

                // Title
                Text(
                  AppLocaleKey.new_update.tr(),
                  style: AppTextStyle.titleMedium(
                    ctx,
                  ).copyWith(fontWeight: FontWeight.w900, fontSize: 20.sp),
                  textAlign: TextAlign.center,
                ),
                Gap(8.h),

                // Version Tag
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor(ctx).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColor.primaryColor(ctx).withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '${AppLocaleKey.new_version.tr()} v${info.storeVersion}',
                    style: AppTextStyle.bodySmall(ctx).copyWith(
                      color: AppColor.primaryColor(ctx),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                Gap(14.h),

                // Message Description
                Text(
                  AppLocaleKey.new_update_text.tr(),
                  style: AppTextStyle.bodyMedium(
                    ctx,
                  ).copyWith(color: AppColor.greyColor(ctx), height: 1.5, fontSize: 13.sp),
                  textAlign: TextAlign.center,
                ),
                Gap(24.h),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor(ctx),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () async {
                      final uri = Uri.parse(info.updateUrl);
                      // Remember this version so the dialog won't reappear
                      // when the user returns from the store.
                      _saveDismissedVersion(info.storeVersion);
                      // Dismiss immediately so a failed store handoff never
                      // leaves the update dialog blocking the app.
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_rounded, color: Colors.white, size: 20.sp),
                        Gap(8.w),
                        Text(
                          AppLocaleKey.update_now.tr(),
                          style: AppTextStyle.titleSmall(ctx).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Later Button (only shown if update is not mandatory)
                if (!info.isForceUpdate) ...[
                  Gap(10.h),
                  SizedBox(
                    width: double.infinity,
                    height: 42.h,
                    child: TextButton(
                      onPressed: () {
                        _isDialogShowing = false;
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        AppLocaleKey.Later.tr(),
                        style: AppTextStyle.bodyMedium(
                          ctx,
                        ).copyWith(color: AppColor.greyColor(ctx), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      _isDialogShowing = false;
    });
  }
}
