import 'package:animate_do/animate_do.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

void showDeveloperContactBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (context) => const DeveloperContactBottomSheet(),
  );
}

class DeveloperContactBottomSheet extends StatelessWidget {
  const DeveloperContactBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          color: AppColor.scaffoldColor(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(
            color: isDark
                ? AppColor.whiteColor(context).withValues(alpha: 0.08)
                : AppColor.blackColor(context).withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(10.h),
              // Drag Handle
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.5.h,
                  decoration: BoxDecoration(
                    color: AppColor.greyColor(context).withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              Gap(8.h),

              // Sheet Header with Title & Close Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor(context).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.code_rounded,
                        color: AppColor.primaryColor(context),
                        size: 20.sp,
                      ),
                    ),
                    Gap(10.w),
                    Expanded(
                      child: Text(
                        AppLocaleKey.contactDeveloper.tr(),
                        style: AppTextStyle.titleMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColor.blackTextColor(context),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColor.whiteColor(context).withValues(alpha: 0.08)
                              : AppColor.greyColor(context).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18.sp,
                          color: AppColor.blackTextColor(context),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'إغلاق',
                    ),
                  ],
                ),
              ),
              Gap(6.h),
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? AppColor.whiteColor(context).withValues(alpha: 0.06)
                    : AppColor.blackColor(context).withValues(alpha: 0.05),
              ),

              // Scrollable Body Content
              const Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  child: DeveloperContactContent(isFullScreen: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeveloperContactContent extends StatelessWidget {
  final bool isFullScreen;

  const DeveloperContactContent({super.key, this.isFullScreen = false});

  static const String developerPhone = '+966580926448';
  static const String developerWhatsapp = '+966580926448';
  static const String developerEmail = 'erp@delta-asg.com';
  static const String developerWebsite = 'https://delta-asg.com/';

  static Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static void _copyToClipboard(BuildContext context, String text, String label) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            Gap(10.w),
            Expanded(
              child: Text(
                '$label: تم النسخ بنجاح',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColor.primaryColor(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Developer Identity Card
          FadeInDown(
            duration: const Duration(milliseconds: 350),
            child: Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E232E), const Color(0xFF11141B)]
                      : [const Color(0xFFFFFFFF), const Color(0xFFF1F5F9)],
                ),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // High-res crisp Delta ASG Logo
                      Container(
                        width: 64.w,
                        height: 64.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.asset(
                            AppImages.assetsImagesDeltaLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.business_rounded, color: primaryColor, size: 32.sp),
                          ),
                        ),
                      ),
                      Gap(14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    AppLocaleKey.company_name.tr(),
                                    style: TextStyle(
                                      color: AppColor.blackTextColor(context),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Gap(4.w),
                                Icon(Icons.verified_rounded, color: primaryColor, size: 18.sp),
                              ],
                            ),
                            Gap(4.h),
                            Text(
                              AppLocaleKey.company_description.tr(),
                              style: TextStyle(
                                color: AppColor.greyColor(context),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Gap(6.h),
                            // Developer Partner Badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'المطوّر التقني المعتمد للأنظمة',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(14.h),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark
                        ? AppColor.whiteColor(context).withValues(alpha: 0.07)
                        : AppColor.blackColor(context).withValues(alpha: 0.06),
                  ),
                  Gap(12.h),

                  // Capabilities Highlights
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildMiniBadge(
                        context,
                        icon: Icons.phone_android_rounded,
                        text: 'تطبيقات الموبايل',
                        color: const Color(0xFF0066FF),
                      ),
                      _buildMiniBadge(
                        context,
                        icon: Icons.directions_car_filled_rounded,
                        text: 'أنظمة إدارة السيارات',
                        color: const Color(0xFF10B981),
                      ),
                      _buildMiniBadge(
                        context,
                        icon: Icons.cloud_done_rounded,
                        text: 'حلول سحابية وERP',
                        color: const Color(0xFF8B5CF6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Gap(20.h),

          // 2. Direct Instant Actions Grid (4 Primary Channels)
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التواصل الفوري والسريع',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.blackTextColor(context),
                  ),
                ),
                Gap(10.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.chat_rounded,
                        label: 'محادثة واتساب',
                        subLabel: 'تواصل فوري',
                        color: const Color(0xFF25D366),
                        onTap: () =>
                            _launch('https://wa.me/${developerWhatsapp.replaceAll('+', '')}'),
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.phone_forwarded_rounded,
                        label: 'اتصال هاتفي',
                        subLabel: 'مكالمة مباشرة',
                        color: const Color(0xFF0066FF),
                        onTap: () => _launch('tel:$developerPhone'),
                      ),
                    ),
                  ],
                ),
                Gap(12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.alternate_email_rounded,
                        label: 'البريد الإلكتروني',
                        subLabel: 'مراسلة الدعم',
                        color: const Color(0xFF8B5CF6),
                        onTap: () => _launch('mailto:$developerEmail'),
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.language_rounded,
                        label: 'الموقع الرسمي',
                        subLabel: 'delta-asg.com',
                        color: const Color(0xFF0EA5E9),
                        onTap: () => _launch(developerWebsite),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Gap(22.h),

          // 3. Detailed Contact Info Section
          FadeInUp(
            duration: const Duration(milliseconds: 450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.contact_support_rounded, color: primaryColor, size: 16.sp),
                    Gap(8.w),
                    Text(
                      AppLocaleKey.contact_support_title.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.blackTextColor(context),
                      ),
                    ),
                  ],
                ),
                Gap(10.h),

                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColor.whiteColor(context).withValues(alpha: 0.04)
                        : AppColor.greyColor(context).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isDark
                          ? AppColor.whiteColor(context).withValues(alpha: 0.08)
                          : AppColor.blackColor(context).withValues(alpha: 0.06),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildContactTile(
                        context,
                        icon: Icons.phone_in_talk_rounded,
                        iconColor: const Color(0xFF10B981),
                        title: AppLocaleKey.phone_title.tr(),
                        subtitle: developerPhone,
                        actionLabel: 'اتصال',
                        onTap: () => _launch('tel:$developerPhone'),
                        onCopy: () => _copyToClipboard(
                          context,
                          developerPhone,
                          AppLocaleKey.phone_title.tr(),
                        ),
                      ),
                      _buildDivider(context, isDark),
                      _buildContactTile(
                        context,
                        icon: Icons.chat_bubble_rounded,
                        iconColor: const Color(0xFF25D366),
                        title: AppLocaleKey.whatsapp_title.tr(),
                        subtitle: developerWhatsapp,
                        actionLabel: 'محادثة',
                        onTap: () =>
                            _launch('https://wa.me/${developerWhatsapp.replaceAll('+', '')}'),
                        onCopy: () => _copyToClipboard(
                          context,
                          developerWhatsapp,
                          AppLocaleKey.whatsapp_title.tr(),
                        ),
                      ),
                      _buildDivider(context, isDark),
                      _buildContactTile(
                        context,
                        icon: Icons.mail_rounded,
                        iconColor: const Color(0xFF3B82F6),
                        title: AppLocaleKey.email_title.tr(),
                        subtitle: developerEmail,
                        actionLabel: 'إرسال',
                        onTap: () => _launch('mailto:$developerEmail'),
                        onCopy: () => _copyToClipboard(
                          context,
                          developerEmail,
                          AppLocaleKey.email_title.tr(),
                        ),
                      ),
                      _buildDivider(context, isDark),
                      _buildContactTile(
                        context,
                        icon: Icons.public_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        title: AppLocaleKey.website_title.tr(),
                        subtitle: AppLocaleKey.website.tr(),
                        actionLabel: 'زيارة',
                        onTap: () => _launch(developerWebsite),
                        onCopy: () => _copyToClipboard(
                          context,
                          developerWebsite,
                          AppLocaleKey.website_title.tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Gap(20.h),

          // 4. System & App Info Badge Card
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF14171F)
                    : AppColor.greyColor(context).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark
                      ? AppColor.whiteColor(context).withValues(alpha: 0.06)
                      : AppColor.blackColor(context).withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0xFF10B981), blurRadius: 6, spreadRadius: 1),
                      ],
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تطبيق بن وزير للسيارات • نظام هاجد',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.blackTextColor(context),
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          'الإصدار: v4.0.0 (بناء 36) | النظام يعمل بكفاءة',
                          style: TextStyle(fontSize: 10.sp, color: AppColor.greyColor(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Gap(18.h),

          // 5. Copyright statement
          Center(
            child: Text(
              'جميع الحقوق محفوظة لشركة Delta ASG للحلول البرمجية © 2026',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColor.greyColor(context).withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Gap(16.h),
        ],
      ),
    );
  }

  static Widget _buildMiniBadge(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          Gap(6.w),
          Text(
            text,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  static Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subLabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isDark ? color.withValues(alpha: 0.12) : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color.withValues(alpha: isDark ? 0.25 : 0.2), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              Gap(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.blackTextColor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap(2.h),
                    Text(
                      subLabel,
                      style: TextStyle(fontSize: 10.sp, color: AppColor.greyColor(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
    required VoidCallback onCopy,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.blackTextColor(context),
                      ),
                    ),
                    Gap(2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColor.greyColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Copy Button
              IconButton(
                icon: Icon(Icons.copy_rounded, size: 18.sp, color: AppColor.primaryColor(context)),
                onPressed: onCopy,
                tooltip: 'نسخ',
                constraints: const BoxConstraints(),
                padding: EdgeInsets.all(8.w),
              ),
              Gap(4.w),
              // Action Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                    Gap(3.w),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10.sp, color: iconColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDivider(BuildContext context, bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 14.w,
      endIndent: 14.w,
      color: isDark
          ? AppColor.whiteColor(context).withValues(alpha: 0.06)
          : AppColor.blackColor(context).withValues(alpha: 0.05),
    );
  }
}
