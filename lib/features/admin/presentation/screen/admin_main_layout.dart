import 'dart:ui';

import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/services/deep_link_service.dart';
import 'package:car/core/services/services_locator.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:car/features/admin/presentation/screen/admin_dashboard_screen.dart';
import 'package:car/features/admin/presentation/screen/admin_settings_screen.dart';
import 'package:car/features/admin/presentation/screen/manage_cars_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService.markNavigatorReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      BlocProvider.value(value: sl<AdminCubit>(), child: const AdminDashboardScreen()),
      BlocProvider.value(value: sl<AdminCubit>(), child: const ManageCarsScreen()),
      const AdminSettingsScreen(),
    ];
    return Scaffold(
      key: ValueKey(context.locale.languageCode),
      backgroundColor: AppColor.scaffoldColor(context),
      body: SafeArea(child: screens[_currentIndex]),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColor.secondAppColor(context).withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(color: AppColor.blackTextColor(context).withValues(alpha: 0.05)),
        ),
      ),
      child: SafeArea(
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.dashboard_rounded, AppLocaleKey.home.tr()),
                  _buildNavItem(1, Icons.directions_car_rounded, AppLocaleKey.cars.tr()),
                  _buildNavItem(2, Icons.settings_rounded, AppLocaleKey.settings.tr()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    Color color = isSelected
        ? AppColor.primaryColor(context)
        : AppColor.blackTextColor(context).withValues(alpha: 0.4);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primaryColor(context).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24.sp),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
