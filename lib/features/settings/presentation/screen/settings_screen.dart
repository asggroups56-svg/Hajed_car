import 'package:animate_do/animate_do.dart';
import 'package:car/core/custom_widgets/copyright_widget.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/custom_widgets/developer_contact_bottom_sheet.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/admin/presentation/screen/widgets/logout_button_widget.dart';
import 'package:car/features/admin/presentation/screen/widgets/show_language_dialog_widget.dart';
import 'package:car/features/settings/presentation/screen/widget/delete_account_button_widget.dart';
import 'package:car/features/settings/presentation/screen/widget/section_header_widget.dart';
import 'package:car/features/settings/presentation/screen/widget/setting_items_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(
        context,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColor.appBarTextColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocaleKey.settings.tr(),
          style: AppTextStyle.titleMedium(
            context,
          ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          SectionHeaderWidget(title: AppLocaleKey.general.tr()),
          Gap(12.h),
          FadeInLeft(
            duration: const Duration(milliseconds: 400),
            child: SettingItemsWidget(
              icon: Icons.language_rounded,
              title: AppLocaleKey.language.tr(),
              trailing: Text(
                context.locale.languageCode == 'ar'
                    ? AppLocaleKey.arabic.tr()
                    : AppLocaleKey.english.tr(),
                style: AppTextStyle.bodySmall(
                  context,
                ).copyWith(color: AppColor.primaryColor(context), fontWeight: FontWeight.bold),
              ),
              onTap: () => showLanguageDialog(context),
            ),
          ),
          Gap(24.h),
          FadeInLeft(
            duration: const Duration(milliseconds: 450),
            child: SettingItemsWidget(
              icon: Icons.help_outline_rounded,
              title: AppLocaleKey.faqs.tr(),
              onTap: () => Navigator.pushNamed(context, RoutesName.faqScreen),
            ),
          ),
          Gap(12.h),
          FadeInLeft(
            duration: const Duration(milliseconds: 500),
            child: SettingItemsWidget(
              icon: Icons.code_rounded,
              title: AppLocaleKey.contactDeveloper.tr(),
              onTap: () => showDeveloperContactBottomSheet(context),
            ),
          ),
          Gap(24.h),
          SectionHeaderWidget(title: AppLocaleKey.accountSecurity.tr()),
          Gap(12.h),
          FadeInLeft(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 400),
            child: SettingItemsWidget(
              icon: Icons.lock_outline_rounded,
              title: AppLocaleKey.changePassword.tr(),
              onTap: () => Navigator.pushNamed(context, RoutesName.changePasswordScreen),
            ),
          ),
          Gap(12.h),
          FadeInLeft(
            delay: const Duration(milliseconds: 150),
            duration: const Duration(milliseconds: 400),
            child: const DeleteAccountButtonWidget(),
          ),
          Gap(32.h),
          FadeInUp(delay: const Duration(milliseconds: 200), child: const LogoutButtonWidget()),
          Gap(28.h),
          FadeInUp(delay: const Duration(milliseconds: 250), child: const CopyrightWidget()),
        ],
      ),
    );
  }
}
