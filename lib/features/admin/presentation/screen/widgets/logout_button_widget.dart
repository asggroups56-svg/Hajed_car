import 'package:animate_do/animate_do.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
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
        final isArabic = dialogContext.locale.languageCode == 'ar';
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
                  isArabic ? 'تسجيل الخروج' : 'Logout',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColor.blackTextColor(dialogContext),
                  ),
                ),
                Gap(10.h),
                Text(
                  isArabic
                      ? 'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟'
                      : 'Are you sure you want to log out of your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColor.blackTextColor(
                      dialogContext,
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
                          isArabic ? 'إلغاء' : 'Cancel',
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
                          foregroundColor: Colors.white,
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
                          isArabic ? 'خروج' : 'Logout',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
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
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColor.redColor(context).withValues(alpha: (0.1)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColor.redColor(context).withValues(alpha: (0.1)),
          ),
        ),
        child: ListTile(
          onTap: () => _showLogoutDialog(context),
          leading: Icon(
            Icons.logout_rounded,
            color: AppColor.redColor(context),
          ),
          title: Text(
            AppLocaleKey.logout.tr(),
            style: TextStyle(
              color: AppColor.redColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Icon(
            Icons.chevron_left_rounded,
            color: AppColor.redColor(context),
          ),
        ),
      ),
    );
  }
}
