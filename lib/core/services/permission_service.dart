import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';

class PermissionService {
  /// Check and request Photo Library/Gallery permission.
  /// On Android 13+ (API 33+), the system Photo Picker is used by image_picker
  /// and does NOT require READ_MEDIA_IMAGES / READ_MEDIA_VIDEO permissions.
  static Future<bool> requestPhotoPermission(BuildContext context) async {
    // On Android, the image_picker plugin uses the system's built-in Photo
    // Picker which does NOT require READ_MEDIA_IMAGES / READ_MEDIA_VIDEO.
    if (Platform.isAndroid) return true;

    // iOS: check and request Photo Library permission
    final status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) return true;
    if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, _getTranslation(context, 'photos'));
      return false;
    }

    final proceed = await _showExplanationDialog(
      context: context,
      title: _getTranslation(context, 'photos_title'),
      description: _getTranslation(context, 'photos_desc'),
      icon: Icons.photo_library_rounded,
    );

    if (proceed) {
      final result = await Permission.photos.request();
      if (result.isGranted || result.isLimited) return true;
      if (result.isPermanentlyDenied) {
        _showSettingsDialog(context, _getTranslation(context, 'photos'));
      }
    }
    return false;
  }

  /// Check and request Camera permission
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    if (status.isGranted || status.isLimited) return true;
    if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, _getTranslation(context, 'camera'));
      return false;
    }

    final proceed = await _showExplanationDialog(
      context: context,
      title: _getTranslation(context, 'camera_title'),
      description: _getTranslation(context, 'camera_desc'),
      icon: Icons.camera_alt_rounded,
    );

    if (proceed) {
      final result = await Permission.camera.request();
      if (result.isGranted || result.isLimited) return true;
      if (result.isPermanentlyDenied) {
        _showSettingsDialog(context, _getTranslation(context, 'camera'));
      }
    }
    return false;
  }

  /// Check and request Location permission
  static Future<bool> requestLocationPermission(BuildContext context) async {
    final status = await Permission.location.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, _getTranslation(context, 'location'));
      return false;
    }

    final proceed = await _showExplanationDialog(
      context: context,
      title: _getTranslation(context, 'location_title'),
      description: _getTranslation(context, 'location_desc'),
      icon: Icons.location_on_rounded,
    );

    if (proceed) {
      final result = await Permission.location.request();
      if (result.isGranted) return true;
      if (result.isPermanentlyDenied) {
        _showSettingsDialog(context, _getTranslation(context, 'location'));
      }
    }
    return false;
  }

  /// Shows a beautiful premium explanation dialog before calling OS permission request
  static Future<bool> _showExplanationDialog({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
  }) async {
    final isAr = context.locale.languageCode == 'ar';
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final primary = AppColor.primaryColor(ctx);
        final bg = AppColor.secondAppColor(ctx);
        final border = AppColor.borderColor(ctx);
        final text = AppColor.blackTextColor(ctx);
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(color: border.withValues(alpha: 0.5), width: 1.5),
          ),
          backgroundColor: bg,
          elevation: 10,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium pulsing icon header
                Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48.sp,
                    color: primary,
                  ),
                ),
                Gap(16.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.titleMedium(ctx).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: text,
                  ),
                ),
                Gap(12.h),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyMedium(ctx).copyWith(
                    color: text.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                Gap(24.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(color: border),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          isAr ? 'لاحقاً' : 'Later',
                          style: AppTextStyle.bodyMedium(ctx).copyWith(
                            color: text.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          isAr ? 'موافق' : 'Allow',
                          style: AppTextStyle.bodyMedium(ctx).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    ) ?? false;
  }

  /// Show standard prompt to redirect user to settings when permission is permanently denied
  static void _showSettingsDialog(BuildContext context, String permissionName) {
    final isAr = context.locale.languageCode == 'ar';
    showDialog(
      context: context,
      builder: (ctx) {
        final primary = AppColor.primaryColor(ctx);
        final bg = AppColor.secondAppColor(ctx);
        final text = AppColor.blackTextColor(ctx);
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: bg,
          title: Text(
            isAr ? 'تفعيل الصلاحية' : 'Permission Required',
            style: AppTextStyle.titleMedium(ctx).copyWith(fontWeight: FontWeight.bold, color: text),
          ),
          content: Text(
            isAr
                ? 'لقد قمت برفض صلاحية ($permissionName) سابقاً. يرجى تفعيلها من إعدادات الهاتف لتتمكن من استخدام هذه الميزة.'
                : 'You have permanently denied ($permissionName) permission. Please enable it from device settings to use this feature.',
            style: AppTextStyle.bodyMedium(ctx).copyWith(color: text.withValues(alpha: 0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                isAr ? 'إلغاء' : 'Cancel',
                style: TextStyle(color: text.withValues(alpha: 0.6)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings();
              },
              child: Text(
                isAr ? 'الإعدادات' : 'Settings',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Helper translations mapping
  static String _getTranslation(BuildContext context, String key) {
    final isAr = context.locale.languageCode == 'ar';
    final Map<String, Map<String, String>> localizedValues = {
      'photos': {
        'ar': 'معرض الصور',
        'en': 'Photo Library',
      },
      'photos_title': {
        'ar': 'الوصول لمعرض الصور',
        'en': 'Access Photo Library',
      },
      'photos_desc': {
        'ar': 'نحتاج للوصول لمعرض الصور الخاص بك لتتمكن من اختيار ورفع المستندات والملفات الثبوتية المطلوبة للتمويل.',
        'en': 'We need access to your photo library so you can pick and upload the required supporting documents for financing.',
      },
      'camera': {
        'ar': 'الكاميرا',
        'en': 'Camera',
      },
      'camera_title': {
        'ar': 'الوصول للكاميرا',
        'en': 'Access Camera',
      },
      'camera_desc': {
        'ar': 'نحتاج للوصول للكاميرا لتتمكن من تصوير مستنداتك الشخصية أو الهوية الوطنية بشكل مباشر وتسهيل عملية التمويل.',
        'en': 'We need camera access so you can take live photos of your identity documents directly to facilitate financing.',
      },
      'location': {
        'ar': 'الموقع الجغرافي',
        'en': 'Location',
      },
      'location_title': {
        'ar': 'تحديد الموقع الجغرافي',
        'en': 'Device Location',
      },
      'location_desc': {
        'ar': 'نطلب الوصول لموقعك الحالي لتحديد فروعنا الأقرب إليك ولحساب أسعار شحن وتوصيل السيارات بدقة فائقة.',
        'en': 'We request your location to find the nearest branches to you and to accurately calculate car shipping and delivery costs.',
      },
    };

    return localizedValues[key]?[isAr ? 'ar' : 'en'] ?? key;
  }
}
