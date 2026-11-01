import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FinancingTabBar extends StatelessWidget {
  final TabController controller;

  const FinancingTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.appBarColor(context),
      child: IgnorePointer(
        child: TabBar(
          controller: controller,
          labelColor: AppColor.primaryColor(context),
          unselectedLabelColor: AppColor.greyColor(context),
          labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp),
          indicatorColor: AppColor.primaryColor(context),
          indicatorWeight: 2.5,
          tabs: [
            Tab(text: AppLocaleKey.agentTabTitle.tr()),
            Tab(text: AppLocaleKey.agentTabTitle2.tr()),
            Tab(text: AppLocaleKey.agentTabTitle3.tr()),
          ],
        ),
      ),
    );
  }
}
