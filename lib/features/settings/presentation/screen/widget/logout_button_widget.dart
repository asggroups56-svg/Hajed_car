import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/auth/presentation/view/cubit/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class LogoutButtonWidget extends StatelessWidget {
  const LogoutButtonWidget({super.key});

  void _showLogoutDialog(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: AppColor.scaffoldColor(dialogContext),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColor.redColor(
                      dialogContext,
                    ).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColor.redColor(dialogContext),
                    size: 32.sp,
                  ),
                ),
                Gap(16.h),
                Text(
                  AppLocaleKey.logout.tr(),
                  style: AppTextStyle.titleMedium(dialogContext).copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColor.blackTextColor(dialogContext),
                  ),
                ),
                Gap(10.h),
                Text(
                  AppLocaleKey.logoutConfirmation.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyMedium(dialogContext).copyWith(
                    color: AppColor.blackTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                  ),
                ),
                Gap(24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          side: BorderSide(
                            color: AppColor.borderColor(dialogContext),
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          AppLocaleKey.cancel.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.blackTextColor(
                              dialogContext,
                            ).withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.redColor(dialogContext),
                          foregroundColor: AppColor.whiteColor(dialogContext),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await authCubit.logout();
                          if (!navigator.mounted) return;
                          navigator.pushNamedAndRemoveUntil(
                            RoutesName.loginScreen,
                            (route) => false,
                          );
                        },
                        child: Text(
                          AppLocaleKey.exit.tr(),
                          style: AppTextStyle.bodyMedium(
                            context,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = HiveMethods.isGuest();
    final actionColor = isGuest ? AppColor.primaryColor(context) : AppColor.redColor(context);

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: actionColor.withValues(alpha: 0.1),
          foregroundColor: actionColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: actionColor, width: 0.5),
          ),
          elevation: 0,
        ),
        onPressed: () {
          if (isGuest) {
            Navigator.pushNamed(context, RoutesName.loginScreen);
          } else {
            _showLogoutDialog(context);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isGuest ? Icons.login_rounded : Icons.logout_rounded, size: 20.sp),
            Gap(12.w),
            Text(
              isGuest ? AppLocaleKey.login.tr() : AppLocaleKey.logout.tr(),
              style: AppTextStyle.bodyLarge(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
