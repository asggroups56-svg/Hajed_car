import 'package:car/core/custom_widgets/contact_row.dart';
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
    builder: (context) => const DeveloperContactBottomSheet(),
  );
}

class DeveloperContactBottomSheet extends StatelessWidget {
  const DeveloperContactBottomSheet({super.key});

  static const String developerPhone = '+966580926448';
  static const String developerWhatsapp = '+966580926448';
  static const String developerEmail = 'erp@delta-asg.com';
  static const String developerWebsite = 'https://delta-asg.com/';

  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label: تم النسخ بنجاح'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: AppColor.blackColor(context).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColor.greyColor(context).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          Gap(16.h),

          // Header Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.primaryColor(context),
                  AppColor.primaryColor(context).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor(context).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25.w,
                  child: Image.asset('assets/images/delta_loge.jpg', width: 50.w, height: 50.w),
                ),
                Gap(14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocaleKey.company_name.tr(),
                        style: TextStyle(
                          color: AppColor.whiteColor(context),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Gap(3.h),
                      Text(
                        AppLocaleKey.company_description.tr(),
                        style: TextStyle(
                          color: AppColor.whiteColor(context).withValues(alpha: 0.9),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Gap(20.h),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              AppLocaleKey.contact_support_title.tr(),
              style: AppTextStyle.bodyMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: AppColor.blackTextColor(context),
              ),
            ),
          ),

          Gap(12.h),

          // Single Unified Frame Container
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColor.whiteColor(context).withValues(alpha: 0.05)
                  : AppColor.greyColor(context).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isDark
                    ? AppColor.whiteColor(context).withValues(alpha: 0.1)
                    : AppColor.blackColor(context).withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              children: [
                ContactRow(
                  icon: Icons.phone_in_talk_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: AppLocaleKey.phone_title.tr(),
                  subtitle: developerPhone,
                  onTap: () => _launch('tel:$developerPhone'),
                  onCopy: () =>
                      _copyToClipboard(context, developerPhone, AppLocaleKey.phone_title.tr()),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16.w,
                  endIndent: 16.w,
                  color: isDark
                      ? AppColor.whiteColor(context).withValues(alpha: 0.08)
                      : AppColor.blackColor(context).withValues(alpha: 0.06),
                ),
                ContactRow(
                  icon: Icons.chat_rounded,
                  iconColor: const Color(0xFF25D366),
                  title: AppLocaleKey.whatsapp_title.tr(),
                  subtitle: developerWhatsapp,
                  onTap: () => _launch('https://wa.me/${developerWhatsapp.replaceAll('+', '')}'),
                  onCopy: () => _copyToClipboard(
                    context,
                    developerWhatsapp,
                    AppLocaleKey.whatsapp_title.tr(),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16.w,
                  endIndent: 16.w,
                  color: isDark
                      ? AppColor.whiteColor(context).withValues(alpha: 0.08)
                      : AppColor.blackColor(context).withValues(alpha: 0.06),
                ),
                ContactRow(
                  icon: Icons.email_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: AppLocaleKey.email_title.tr(),
                  subtitle: developerEmail,
                  onTap: () => _launch('mailto:$developerEmail'),
                  onCopy: () =>
                      _copyToClipboard(context, developerEmail, AppLocaleKey.email_title.tr()),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16.w,
                  endIndent: 16.w,
                  color: isDark
                      ? AppColor.whiteColor(context).withValues(alpha: 0.08)
                      : AppColor.blackColor(context).withValues(alpha: 0.06),
                ),
                ContactRow(
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: AppLocaleKey.website_title.tr(),
                  subtitle: AppLocaleKey.website.tr(),
                  onTap: () => _launch(developerWebsite),
                  onCopy: () =>
                      _copyToClipboard(context, developerWebsite, AppLocaleKey.website_title.tr()),
                ),
              ],
            ),
          ),

          Gap(12.h),
        ],
      ),
    );
  }
}
