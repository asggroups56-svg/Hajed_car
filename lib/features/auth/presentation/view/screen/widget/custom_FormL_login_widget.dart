import 'package:animate_do/animate_do.dart';
import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/buttons/custom_button.dart';
import 'package:car/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:car/core/images/app_images.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/auth/presentation/view/cubit/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomFormLoginWidget extends StatelessWidget {
  const CustomFormLoginWidget({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.cubit,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final AuthCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(10.h),
          Center(
            child: Image.asset(AppImages.assetsImagesLogeBlack, width: 100.w, height: 200.h),
          ),
          FadeInLeft(
            duration: const Duration(milliseconds: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocaleKey.welcomeBack.tr(),
                  style: AppTextStyle.titleLarge(context, color: AppColor.blackTextColor(context)),
                ),
                Gap(8.h),
                Text(
                  AppLocaleKey.loginToContinueYourPremiumExperience.tr(),
                  style: AppTextStyle.bodyLarge(
                    context,
                    color: AppColor.blackTextColor(context).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Gap(40.h),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 1000),
            child: CustomFormField(
              controller: cubit.mobileController,
              title: AppLocaleKey.userName.tr(),
              hintText: AppLocaleKey.userName.tr(),
              prefixIcon: Icon(Icons.person, color: AppColor.primaryColor(context)),
              fillColor: AppColor.textFormFillColor(context),
              textStyle: TextStyle(color: AppColor.blackTextColor(context)),
              hintStyle: TextStyle(color: AppColor.blackTextColor(context).withValues(alpha: 0.3)),
              radius: 16,
              keyboardType: TextInputType.name,

              validator: (p0) {
                if (p0 == null || p0.trim().isEmpty) {
                  return AppLocaleKey.userName.tr();
                }
                return null;
              },
            ),
          ),
          Gap(20.h),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 1000),
            child: CustomFormField(
              controller: cubit.passwordController,
              title: AppLocaleKey.password.tr(),
              hintText: AppLocaleKey.password.tr(),
              isPassword: true,
              prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColor.primaryColor(context)),
              fillColor: AppColor.textFormFillColor(context),
              textStyle: TextStyle(color: AppColor.blackTextColor(context)),
              hintStyle: TextStyle(color: AppColor.blackTextColor(context).withValues(alpha: 0.3)),
              radius: 16,
              keyboardType: TextInputType.visiblePassword,
              validator: (p0) {
                if (p0 == null || p0.trim().isEmpty) {
                  return AppLocaleKey.passwordRequired.tr();
                }
                return null;
              },
            ),
          ),
          Gap(10.h),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            duration: const Duration(milliseconds: 1000),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 24.h,
                      width: 24.h,
                      child: Theme(
                        data: ThemeData(
                          unselectedWidgetColor: AppColor.blackTextColor(
                            context,
                          ).withValues(alpha: 0.3),
                        ),
                        child: Checkbox(
                          value: cubit.rememberMe,
                          activeColor: AppColor.primaryColor(context),
                          checkColor: AppColor.whiteColor(context),
                          onChanged: (value) => cubit.changeRememberMe(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      AppLocaleKey.rememberMe.tr(),
                      style: AppTextStyle.bodySmall(
                        context,
                        color: AppColor.blackTextColor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap(10.h),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            duration: const Duration(milliseconds: 1000),
            child: Column(
              children: [
                CustomButton(
                  radius: 12.r,
                  text: AppLocaleKey.login.tr(),
                  cubitState: cubit.state.loginStatus,
                  onPressed: () {
                    if (cubit.mobileController.text == '999' &&
                        cubit.passwordController.text == 'admin') {
                      HiveMethods.updateIsGuest(false);
                      HiveMethods.updateToken('admin_dummy_token');
                      HiveMethods.updateRole('admin');
                      HiveMethods.updateUserCode('1');
                      CommonMethods.showToast(message: AppLocaleKey.adminLoginSuccess.tr());
                      NavigatorMethods.pushReplacementNamed(context, RoutesName.adminDashboard);
                    } else {
                      cubit.login();
                    }
                  },
                ),
                Gap(15.h),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     // TextButton(
                //     //   onPressed: () {
                //     //     HiveMethods.updateIsGuest(true);
                //     //     NavigatorMethods.pushReplacementNamed(context, RoutesName.mainLayout);
                //     //   },
                //     //   child: Text(
                //     //     AppLocaleKey.continueAsGuest.tr(),
                //     //     style: AppTextStyle.bodyLarge(
                //     //       context,
                //     //       color: AppColor.blackTextColor(context),
                //     //     ),
                //     //   ),
                //     // ),
                //     Container(
                //       width: 1,
                //       height: 20.h,
                //       color: AppColor.blackTextColor(context).withValues(alpha: 0.2),
                //     ),
                //     TextButton(
                //       onPressed: () {
                //         HiveMethods.updateIsGuest(false);
                //         HiveMethods.updateToken('admin_dummy_token');
                //         HiveMethods.updateRole('admin');
                //         HiveMethods.updateUserCode('1');
                //         CommonMethods.showToast(message: AppLocaleKey.managerLoginSuccess.tr());
                //         NavigatorMethods.pushReplacementNamed(context, RoutesName.adminDashboard);
                //       },
                //       child: Text(
                //         AppLocaleKey.loginAsAdmin.tr(),
                //         style: AppTextStyle.bodyLarge(
                //           context,
                //           color: AppColor.primaryColor(context),
                //         ).copyWith(fontWeight: FontWeight.bold),
                //       ),
                //     ),
                //   ],
                // ),
                // Gap(5.h),
                // TextButton(
                //   onPressed: () {
                //     HiveMethods.updateIsGuest(false);
                //     HiveMethods.updateToken('agent_dummy_token');
                //     HiveMethods.updateRole('agent');
                //     HiveMethods.updateUserCode('1');
                //     CommonMethods.showToast(message: AppLocaleKey.agentLoginSuccess.tr());
                //     NavigatorMethods.pushReplacementNamed(context, RoutesName.agentDashboard);
                //   },
                //   child: Text(
                //     AppLocaleKey.loginAsAgent.tr(),
                //     style: AppTextStyle.bodyLarge(
                //       context,
                //       color: const Color(0xFF1565C0),
                //     ).copyWith(fontWeight: FontWeight.bold),
                //   ),
                // ),
              ],
            ),
          ),
          Gap(20.h),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            duration: const Duration(milliseconds: 1000),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocaleKey.dontHaveAccount.tr(),
                  style: AppTextStyle.bodyMedium(context, color: AppColor.blackTextColor(context)),
                ),
                TextButton(
                  onPressed: () => NavigatorMethods.pushReplacementNamed(
                    context,
                    RoutesName.registerScreen,
                  ),
                  child: Text(
                    AppLocaleKey.signUp.tr(),
                    style: AppTextStyle.bodyLarge(
                      context,
                      color: AppColor.primaryColor(context),
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Gap(20.h),
        ],
      ),
    );
  }
}
