import 'package:animate_do/animate_do.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/custom_widgets/developer_contact_bottom_sheet.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/settings/presentation/screen/widget/logout_button_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(
        context,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          AppLocaleKey.myAccount.tr(),
          style: AppTextStyle.bodyLarge(
            context,
          ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          _AccountItem(
            icon: Icons.person_outline_rounded,
            title: AppLocaleKey.profile.tr(),
            onTap: () => Navigator.pushNamed(context, RoutesName.profileScreen),
          ),
          Gap(12.h),
          _AccountItem(
            icon: Icons.directions_car_outlined,
            title: AppLocaleKey.reservedCars.tr(),
            onTap: () => Navigator.pushNamed(context, RoutesName.cartScreen),
          ),
          Gap(12.h),
          _AccountItem(
            icon: Icons.settings_outlined,
            title: AppLocaleKey.settings.tr(),
            onTap: () => Navigator.pushNamed(context, RoutesName.settingsScreen),
          ),
          Gap(12.h),
          _AccountItem(
            icon: Icons.info_outline_rounded,
            title: AppLocaleKey.aboutCompany.tr(),
            onTap: () => Navigator.pushNamed(context, RoutesName.aboutScreen),
          ),
          Gap(12.h),
          _AccountItem(
            icon: Icons.support_agent_rounded,
            title: AppLocaleKey.support.tr(),
            onTap: () => Navigator.pushNamed(context, RoutesName.supportScreen),
          ),
          Gap(12.h),
          _AccountItem(
            icon: Icons.code_rounded,
            title: AppLocaleKey.contactDeveloper.tr(),
            onTap: () => showDeveloperContactBottomSheet(context),
          ),
          Gap(12.h),
          FadeInUp(delay: const Duration(milliseconds: 200), child: const LogoutButtonWidget()),
        ],
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  const _AccountItem({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.secondAppColor(context),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Icon(icon, color: AppColor.primaryColor(context), size: 24.sp),
              Gap(14.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.bodyMedium(
                    context,
                  ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.w700),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColor.greyColor(context),
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
