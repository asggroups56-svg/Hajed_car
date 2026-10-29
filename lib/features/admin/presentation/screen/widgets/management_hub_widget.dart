import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/features/admin/presentation/screen/widgets/hub_Item_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ManagementHubWidget extends StatelessWidget {
  const ManagementHubWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocaleKey.managementActionCenter.tr(),
          style: TextStyle(
            color: AppColor.blackTextColor(context),
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        Gap(16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 1.4,
          children: [
            HubItemWidget(
              label: AppLocaleKey.adminUserManagement.tr(),
              icon: Icons.people_alt_rounded,
              color: AppColor.blueColor(context),
              onTap: () => Navigator.pushNamed(context, RoutesName.manageUsers),
            ),
            HubItemWidget(
              label: AppLocaleKey.loanApplications.tr(),
              icon: Icons.account_balance_rounded,
              color: AppColor.greenColor(context),
              onTap: () => Navigator.pushNamed(
                context,
                RoutesName.adminLoanApplications,
              ),
            ),
            HubItemWidget(
              label: 'comparison_reports'.tr(),
              icon: Icons.insert_chart_rounded,
              color: AppColor.orangeColor(context),
              onTap: () =>
                  Navigator.pushNamed(context, RoutesName.comparisonReports),
            ),
            // HubItemWidget(
            //   label: AppLocaleKey.adminCustomerInquiries.tr(),
            //   icon: Icons.question_answer_rounded,
            //   color: AppColor.orangeColor(context),
            //   onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => const CustomerInquiriesScreen()),
            //   ),
            // ),
            // HubItemWidget(
            //   label: AppLocaleKey.adminContentModeration.tr(),
            //   icon: Icons.fact_check_rounded,
            //   color: AppColor.greenColor(context),
            //   onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => const ContentManagementScreen()),
            //   ),
            // ),
            // HubItemWidget(
            //   label: AppLocaleKey.adminAdvancedReports.tr(),
            //   icon: Icons.analytics_rounded,
            //   color: Colors.purpleAccent,
            //   onTap: () => Navigator.pushNamed(context, RoutesName.revenueReports),
            // ),
          ],
        ),
      ],
    );
  }
}
