import 'package:animate_do/animate_do.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/features/admin/presentation/screen/widgets/back_ground_aura_widget.dart';
import 'package:car/features/admin/presentation/screen/widgets/header_admin_dashboard_widget.dart';
import 'package:car/features/admin/presentation/screen/widgets/management_hub_widget.dart';
import 'package:car/features/admin/presentation/screen/widgets/performance_chart_widget.dart';
import 'package:car/features/admin/presentation/screen/widgets/stats_grid_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      body: Stack(
        children: [
          const BackGroundAuraWidget(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(child: const HeaderAdminDashboardWidget()),
                  Gap(24.h),
                  FadeInUp(child: const StatsGridWidget()),
                  Gap(32.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: const PerformanceChartWidget(),
                  ),
                  Gap(24.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 250),

                    child: const ManagementHubWidget(),
                  ),
                  // Gap(32.h),
                  // FadeInLeft(child: const UrgentApprovalWidget()),
                  // Gap(32.h),
                  // FadeInUp(
                  //   delay: const Duration(milliseconds: 300),
                  //   child: const ActivityFeedWidget(),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
