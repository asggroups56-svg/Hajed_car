import 'package:car/core/custom_widgets/copyright_widget.dart';
import 'package:car/core/custom_widgets/developer_contact_bottom_sheet.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/features/admin/presentation/screen/widgets/logout_button_widget.dart';
import 'package:car/features/admin/presentation/screen/widgets/security_section_widget.dart';
import 'package:car/features/admin/presentation/screen/widgets/setting_Item_widget.dart';
import 'package:car/features/admin/presentation/screen/widgets/show_language_dialog_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(
        context,
        elevation: 0,
        appBarColor: AppColor.scaffoldColor(context),
        automaticallyImplyLeading: false,
        title: Text(AppLocaleKey.adminSettings.tr()),
        centerTitle: true,
        leading: const SizedBox.shrink(),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -50.h,
            right: -50.w,
            child: Container(
              width: 300.w,
              height: 300.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withValues(alpha: (0.02)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: (0.02)),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SecuritySectionWidget(
                  title: AppLocaleKey.systemSettings.tr(),
                  items: [
                    SettingItemWidget(
                      icon: Icons.lock_reset_rounded,
                      title: AppLocaleKey.changePassword.tr(),
                      subtitle: AppLocaleKey.changeYourPassword.tr(),
                      onTap: () =>
                          Navigator.pushNamed(context, RoutesName.changePasswordScreen),
                    ),
                    SettingItemWidget(
                      icon: Icons.language_rounded,
                      title: AppLocaleKey.language.tr(),
                      subtitle: AppLocaleKey.appLanguageDesc.tr(),
                      onTap: () => showLanguageDialog(context),
                    ),
                    // SettingItemWidget(
                    //   icon: Icons.notifications_active_rounded,
                    //   title: AppLocaleKey.systemAlerts.tr(),
                    //   subtitle: AppLocaleKey.systemNotificationsDesc.tr(),
                    //   onTap: () => Navigator.pushNamed(context, RoutesName.systemAlerts),
                    // ),
                  ],
                ),
                Gap(32.h),
                SecuritySectionWidget(
                  title: AppLocaleKey.contentManagement.tr(),
                  items: [
                    SettingItemWidget(
                      icon: Icons.policy_rounded,
                      title: AppLocaleKey.termsAndConditions.tr(),
                      subtitle: AppLocaleKey.updateUsagePolicies.tr(),
                      onTap: () => Navigator.pushNamed(context, RoutesName.termsSettings),
                    ),
                  ],
                ),
                Gap(32.h),
                SecuritySectionWidget(
                  title: AppLocaleKey.technicalSupport.tr(),
                  items: [
                    SettingItemWidget(
                      icon: Icons.code_rounded,
                      title: AppLocaleKey.contactDeveloper.tr(),
                      subtitle: AppLocaleKey.raiseSupportTicket.tr(),
                      onTap: () => showDeveloperContactBottomSheet(context),
                    ),
                  ],
                ),
                Gap(40.h),
                const LogoutButtonWidget(),
                Gap(28.h),
                const Center(child: CopyrightWidget()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
