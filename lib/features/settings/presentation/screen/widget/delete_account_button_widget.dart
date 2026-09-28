import 'package:animate_do/animate_do.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/auth/presentation/view/cubit/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class DeleteAccountButtonWidget extends StatelessWidget {
  final bool isListTile;
  const DeleteAccountButtonWidget({super.key, this.isListTile = false});

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              previous.deleteAccountStatus != current.deleteAccountStatus,
          listener: (context, state) {
            if (state.deleteAccountStatus.isSuccess) {
              Navigator.of(dialogContext).pop();
              CommonMethods.showToast(
                message: AppLocaleKey.deleteAccountSuccess.tr(),
                type: ToastType.success,
              );
              Navigator.pushNamedAndRemoveUntil(context, RoutesName.loginScreen, (route) => false);
            } else if (state.deleteAccountStatus.isFailure) {
              CommonMethods.showToast(
                message: state.deleteAccountStatus.message ?? 'Failed to delete account',
                type: ToastType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state.deleteAccountStatus.isLoading;

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
              backgroundColor: AppColor.scaffoldColor(context),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColor.redColor(context).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_forever_rounded,
                        color: AppColor.redColor(context),
                        size: 36.sp,
                      ),
                    ),
                    Gap(16.h),
                    Text(
                      AppLocaleKey.deleteAccount.tr(),
                      style: AppTextStyle.titleMedium(context).copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColor.redColor(context),
                      ),
                    ),
                    Gap(10.h),
                    Text(
                      AppLocaleKey.deleteAccountConfirmation.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        color: AppColor.blackTextColor(context).withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                    Gap(8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColor.redColor(context).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColor.redColor(context),
                            size: 16.sp,
                          ),
                          Gap(6.w),
                          Flexible(
                            child: Text(
                              AppLocaleKey.deleteAccountWarning.tr(),
                              style: TextStyle(
                                color: AppColor.redColor(context),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
                              side: BorderSide(color: AppColor.borderColor(context)),
                            ),
                            onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                            child: Text(
                              AppLocaleKey.cancel.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.blackTextColor(context).withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                        Gap(12.w),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.redColor(context),
                              foregroundColor: AppColor.whiteColor(context),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.read<AuthCubit>().deleteAccount();
                                  },
                            child: isLoading
                                ? SizedBox(
                                    height: 20.w,
                                    width: 20.w,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    AppLocaleKey.deleteAccount.tr(),
                                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isListTile) {
      return FadeInUp(
        delay: const Duration(milliseconds: 400),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColor.redColor(context).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColor.redColor(context).withValues(alpha: 0.15)),
          ),
          child: ListTile(
            onTap: () => _showDeleteAccountDialog(context),
            leading: Icon(Icons.delete_forever_rounded, color: AppColor.redColor(context)),
            title: Text(
              AppLocaleKey.deleteAccount.tr(),
              style: TextStyle(color: AppColor.redColor(context), fontWeight: FontWeight.bold),
            ),
            trailing: Icon(Icons.chevron_left_rounded, color: AppColor.redColor(context)),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColor.redColor(context).withValues(alpha: 0.05),
          foregroundColor: AppColor.redColor(context),
          side: BorderSide(color: AppColor.redColor(context).withValues(alpha: 0.3), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          elevation: 0,
        ),
        onPressed: () => _showDeleteAccountDialog(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever_rounded, size: 20.sp, color: AppColor.redColor(context)),
            Gap(10.w),
            Text(
              AppLocaleKey.deleteAccount.tr(),
              style: AppTextStyle.bodyLarge(
                context,
              ).copyWith(fontWeight: FontWeight.bold, color: AppColor.redColor(context)),
            ),
          ],
        ),
      ),
    );
  }
}
