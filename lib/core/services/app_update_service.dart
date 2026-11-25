import 'dart:convert';
import 'dart:io';

import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart' as play_core;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateInfo {
  final bool hasUpdate;
  final String currentVersion;
  final String storeVersion;
  final String updateUrl;
  final String? releaseNotes;
  final bool isForceUpdate;

  /// Play Core only exposes the version *code* (build number), not the
  /// marketing version name, so it must not be rendered as "v12.3.4".
  final bool versionIsBuildNumber;

  const AppUpdateInfo({
    required this.hasUpdate,
    required this.currentVersion,
    required this.storeVersion,
    required this.updateUrl,
    this.releaseNotes,
    this.isForceUpdate = false,
    this.versionIsBuildNumber = false,
  });
}

class AppUpdateService {
  AppUpdateService._();

  static const String _iosBundleId = 'com.Hajed.car';
  static const String _iosAppId = '6816629989';
  static const String _androidPackageName = 'com.Hajed.car';
  static const String _androidStoreUrl =
      'https://play.google.com/store/apps/details?id=$_androidPackageName';
  static const String _dismissedVersionKey = 'dismissed_update_version';

  static const Duration _checkThrottle = Duration(minutes: 10);

  static DateTime? _lastCheckTime;
  static bool _isDialogShowing = false;

  /// Saves the store version the user already acted on (tapped "Update Now"
  /// or dismissed the dialog). The dialog stays hidden until a newer version
  /// is published.
  static void _saveDismissedVersion(String version) {
    if (version.isEmpty) return;
    try {
      Hive.box('app').put(_dismissedVersionKey, version);
    } catch (_) {}
  }

  static String? _getDismissedVersion() {
    try {
      final value = Hive.box('app').get(_dismissedVersionKey);
      return value is String && value.isNotEmpty ? value : null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _installedVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version.trim();
      return version.isEmpty ? null : version;
    } catch (_) {
      return null;
    }
  }

  /// Checks if a new version is available on the App Store / Play Store.
  static Future<AppUpdateInfo?> checkUpdate({bool forceUpdate = false}) async {
    try {
      final currentVersion = await _installedVersion();
      if (currentVersion == null) return null;

      if (Platform.isIOS) {
        return await _checkIosUpdate(currentVersion, forceUpdate: forceUpdate);
      }
      if (Platform.isAndroid) {
        return await _checkAndroidUpdate(currentVersion, forceUpdate: forceUpdate);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppUpdateService] Error checking for update: $e');
      }
    }
    return null;
  }

  /// Checks the store and, when a newer version exists, shows the update
  /// dialog. Safe to call from every app shell — checks are throttled and a
  /// dialog is never shown twice at the same time.
  static Future<void> checkForUpdate(
    BuildContext context, {
    bool isForceUpdate = false,
    bool forceCheck = false,
  }) async {
    if (!context.mounted) return;

    if (!forceCheck && _lastCheckTime != null) {
      if (DateTime.now().difference(_lastCheckTime!) < _checkThrottle) return;
    }
    _lastCheckTime = DateTime.now();

    final updateInfo = await checkUpdate(forceUpdate: isForceUpdate);
    if (updateInfo == null || !updateInfo.hasUpdate) return;
    if (!context.mounted) return;

    // Skip if the user already acted on this exact store version.
    final dismissed = _getDismissedVersion();
    if (dismissed != null &&
        updateInfo.storeVersion.isNotEmpty &&
        dismissed == updateInfo.storeVersion) {
      return;
    }

    showUpdateDialog(context, updateInfo);
  }

  static Future<AppUpdateInfo?> _checkIosUpdate(
    String currentVersion, {
    bool forceUpdate = false,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
      'https://itunes.apple.com/lookup?bundleId=$_iosBundleId&country=sa&t=$timestamp',
    );

    final response = await http
        .get(url, headers: {'Cache-Control': 'no-cache'})
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    final results = data['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    final storeData = results.first as Map<String, dynamic>;
    final storeVersion = storeData['version']?.toString() ?? '';
    final trackViewUrl =
        storeData['trackViewUrl']?.toString() ?? 'https://apps.apple.com/sa/app/id$_iosAppId';
    final releaseNotes = storeData['releaseNotes']?.toString();

    return AppUpdateInfo(
      hasUpdate: _isVersionGreater(storeVersion, currentVersion),
      currentVersion: currentVersion,
      storeVersion: storeVersion,
      updateUrl: trackViewUrl,
      releaseNotes: releaseNotes,
      isForceUpdate: forceUpdate,
    );
  }

  /// Android: the Play Store HTML no longer contains the version name, so we
  /// ask Play Core (the official in-app update API) whether an update exists.
  static Future<AppUpdateInfo?> _checkAndroidUpdate(
    String currentVersion, {
    bool forceUpdate = false,
  }) async {
    try {
      final info = await play_core.InAppUpdate.checkForUpdate();
      final hasUpdate = info.updateAvailability == play_core.UpdateAvailability.updateAvailable;

      return AppUpdateInfo(
        hasUpdate: hasUpdate,
        currentVersion: currentVersion,
        storeVersion: info.availableVersionCode?.toString() ?? '',
        updateUrl: _androidStoreUrl,
        isForceUpdate: forceUpdate && hasUpdate,
        versionIsBuildNumber: true,
      );
    } on PlatformException catch (e) {
      // Thrown for side-loaded/dev builds and devices without Play services;
      // there is nothing to update in that case.
      if (kDebugMode) {
        debugPrint('[AppUpdateService] Play Core unavailable: ${e.code}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppUpdateService] Error checking Android update: $e');
      }
    }
    return null;
  }

  /// Compares semantic versions (e.g. "3.0.1" > "3.0.0").
  /// Returns true ONLY if [newVersion] is strictly higher than [currentVersion].
  static bool _isVersionGreater(String newVersion, String currentVersion) {
    if (newVersion.isEmpty || currentVersion.isEmpty) return false;

    // Clean versions of any leading 'v' and build suffixes like +35.
    final cleanNew = newVersion.trim().replaceFirst(RegExp(r'^[vV]'), '').split('+').first.trim();
    final cleanCurrent = currentVersion
        .trim()
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split('+')
        .first
        .trim();

    final newParts = cleanNew
        .split('.')
        .map((e) => int.tryParse(RegExp(r'\d+').stringMatch(e) ?? '0') ?? 0)
        .toList();
    final currentParts = cleanCurrent
        .split('.')
        .map((e) => int.tryParse(RegExp(r'\d+').stringMatch(e) ?? '0') ?? 0)
        .toList();

    final maxLength = newParts.length > currentParts.length ? newParts.length : currentParts.length;

    for (int i = 0; i < maxLength; i++) {
      final v1 = i < newParts.length ? newParts[i] : 0;
      final v2 = i < currentParts.length ? currentParts[i] : 0;

      if (v1 > v2) return true;
      if (v1 < v2) return false;
    }

    return false;
  }

  /// Shows the update dialog to the user.
  static void showUpdateDialog(BuildContext context, AppUpdateInfo info) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: !info.isForceUpdate,
      barrierLabel: 'update',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (ctx, _, __) => PopScope(
        canPop: !info.isForceUpdate,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) _saveDismissedVersion(info.storeVersion);
        },
        child: _UpdateDialogContent(info: info, onUpdate: () => _openStore(ctx, info)),
      ),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.82, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    ).whenComplete(() => _isDialogShowing = false);
  }

  static Future<void> _openStore(BuildContext context, AppUpdateInfo info) async {
    final uri = Uri.tryParse(info.updateUrl);
    if (uri == null) return;

    // Remember this version so the dialog does not nag on every launch.
    _saveDismissedVersion(info.storeVersion);
    if (context.mounted) Navigator.of(context).pop();

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppUpdateService] Could not open store: $e');
      }
    }
  }
}

class _UpdateDialogContent extends StatefulWidget {
  final AppUpdateInfo info;
  final VoidCallback onUpdate;

  const _UpdateDialogContent({required this.info, required this.onUpdate});

  @override
  State<_UpdateDialogContent> createState() => _UpdateDialogContentState();
}

class _UpdateDialogContentState extends State<_UpdateDialogContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.18,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color _darken(Color c, [double amount = 0.14]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final primary = AppColor.primaryColor(context);
    final primaryDark = _darken(primary);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showVersionTag = info.storeVersion.isNotEmpty && !info.versionIsBuildNumber;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.scaffoldColor(context),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: isDark ? 0.25 : 0.3),
                  blurRadius: 30,
                  spreadRadius: 1,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ───────── Header ─────────
                Container(
                  width: double.infinity,
                  height: 100.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [primary, primaryDark],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -24.h,
                        right: -16.w,
                        child: _circle(80.r, Colors.white.withValues(alpha: 0.10)),
                      ),
                      Positioned(
                        bottom: -30.h,
                        left: -20.w,
                        child: _circle(90.r, Colors.white.withValues(alpha: 0.08)),
                      ),
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, __) => Transform.scale(
                          scale: _pulseAnim.value,
                          child: _circle(88.r, Colors.white.withValues(alpha: 0.16)),
                        ),
                      ),
                      Container(
                        width: 66.r,
                        height: 66.r,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.9),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(AppImages.assetsImagesLogeStatic, fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                ),

                // ───────── Body ─────────
                Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocaleKey.new_update.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.titleMedium(
                          context,
                        ).copyWith(fontWeight: FontWeight.w900, fontSize: 18.sp),
                      ),
                      Gap(8.h),

                      if (showVersionTag) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _versionChip(
                              context,
                              'v${info.currentVersion}',
                              filled: false,
                              color: AppColor.greyColor(context),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: Icon(Icons.arrow_forward_rounded, size: 16.sp, color: primary),
                            ),
                            _versionChip(
                              context,
                              'v${info.storeVersion}',
                              filled: true,
                              color: primary,
                            ),
                          ],
                        ),
                        Gap(10.h),
                      ],

                      Text(
                        AppLocaleKey.new_update_text.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          color: AppColor.greyColor(context),
                          height: 1.5,
                          fontSize: 12.5.sp,
                        ),
                      ),
                      Gap(16.h),

                      // ───────── Update button ─────────
                      Container(
                        width: double.infinity,
                        height: 46.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [primary, primaryDark]),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14.r),
                            onTap: widget.onUpdate,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download_rounded, color: Colors.white, size: 20.sp),
                                Gap(6.w),
                                Text(
                                  AppLocaleKey.update_now.tr(),
                                  style: AppTextStyle.titleSmall(context).copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _versionChip(
    BuildContext context,
    String text, {
    required bool filled,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: filled ? 0 : 0.5)),
      ),
      child: Text(
        text,
        style: AppTextStyle.bodySmall(context).copyWith(
          color: filled ? Colors.white : color,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
