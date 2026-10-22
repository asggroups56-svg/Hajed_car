import 'package:animate_do/animate_do.dart';
import 'package:car/core/custom_widgets/buttons/custom_button.dart';
import 'package:car/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:car/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/auth/presentation/view/cubit/auth_cubit.dart';
import 'package:car/features/auth/presentation/view/screen/widget/password_hint_chip_widget.dart';
import 'package:car/features/cars/presentation/widget/otp_bottom_sheet.dart';
import 'package:car/features/cars/presentation/widget/reservation_terms_checkbox_widget.dart';
import 'package:car/features/home/data/model/send_otp_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomRegisterFormWidget extends StatefulWidget {
  const CustomRegisterFormWidget({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.cubit,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final AuthCubit cubit;

  @override
  State<CustomRegisterFormWidget> createState() => _CustomRegisterFormWidgetState();
}

class _CustomRegisterFormWidgetState extends State<CustomRegisterFormWidget> {
  bool _isPhoneVerified = false;
  bool _isSendingOtp = false;
  bool _isTermsAccepted = false;
  String? _expectedOtp;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecial = false;
  bool _hasMinLength = false;
  bool _passwordTouched = false;

  void _onPasswordChanged(String val) {
    setState(() {
      _passwordTouched = val.isNotEmpty;
      _hasUppercase = val.contains(RegExp(r'[A-Z]'));
      _hasLowercase = val.contains(RegExp(r'[a-z]'));
      _hasDigit = val.contains(RegExp(r'[0-9]'));
      _hasSpecial = val.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\/\\;~`]'));
      _hasMinLength = val.length >= 8;
    });
  }

  bool get _isPasswordValid =>
      _hasUppercase && _hasLowercase && _hasDigit && _hasSpecial && _hasMinLength;

  void _sendOtp(BuildContext context) {
    final phone = widget.cubit.idNoController.text.trim();
    final isArabic = context.locale.languageCode == 'ar';

    if (phone.isEmpty) {
      CommonMethods.showToast(
        message: isArabic ? 'برجاء إدخال رقم الجوال' : 'Please enter phone number',
        type: ToastType.error,
      );
      return;
    }
    if (!phone.startsWith('05') || phone.length < 10) {
      CommonMethods.showToast(
        message: isArabic
            ? 'رقم الجوال يجب أن يبدأ بـ 05 ويتكون من 10 أرقام'
            : 'Phone number must start with 05 and be 10 digits',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isSendingOtp = true);
    context.read<HomeCubit>().sendOtp(SendOtpModel(mobileNumber: phone));
  }

  void _showOtpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: OtpBottomSheet(
            phoneNumber: widget.cubit.idNoController.text.trim(),
            homeCubit: context.read<HomeCubit>(),
            expectedOtp: _expectedOtp,
            onVerified: () {
              Navigator.pop(ctx);
              setState(() {
                _isPhoneVerified = true;
              });
              CommonMethods.showToast(
                message: context.locale.languageCode == 'ar'
                    ? 'تم التحقق من رقم الجوال بنجاح'
                    : 'Phone number verified successfully',
                type: ToastType.success,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) => previous.sendOtpStatus != current.sendOtpStatus,
      listener: (context, state) {
        final status = state.sendOtpStatus;
        if (_isSendingOtp) {
          if (status.isSuccess && status.data != null) {
            setState(() => _isSendingOtp = false);
            _expectedOtp = status.data!.message;
            _showOtpSheet(context);
          } else if (status.isFailure) {
            setState(() => _isSendingOtp = false);
            CommonMethods.showToast(
              message:
                  status.message ??
                  (isArabic ? 'حدث خطأ أثناء إرسال رمز التحقق' : 'Error sending verification code'),
              type: ToastType.error,
            );
          }
        }
      },
      child: Form(
        key: widget._formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(40.h),

            FadeInLeft(
              duration: const Duration(milliseconds: 600),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _isPhoneVerified
                          ? (isArabic ? 'الخطوة 2 من 2' : 'Step 2 of 2')
                          : (isArabic ? 'الخطوة 1 من 2' : 'Step 1 of 2'),
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.primaryColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gap(30.h),
            FadeInLeft(
              duration: const Duration(milliseconds: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isPhoneVerified
                        ? (isArabic ? 'إكمال البيانات الشخصية' : 'Complete Personal Details')
                        : AppLocaleKey.createAccount.tr(),
                    style: AppTextStyle.titleLarge(
                      context,
                      color: AppColor.blackTextColor(context),
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    _isPhoneVerified
                        ? (isArabic
                              ? 'أدخل بياناتك الشخصية لإتمام عملية إنشاء الحساب'
                              : 'Enter your personal details to complete registration')
                        : (isArabic
                              ? 'أدخل رقم جوالك أولاً لتلقي رمز التحقق OTP'
                              : 'Enter your phone number first to receive OTP'),
                    style: AppTextStyle.bodyMedium(
                      context,
                      color: AppColor.blackTextColor(context).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Gap(60.h),

            if (!_isPhoneVerified) ...[
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: CustomFormField(
                  controller: widget.cubit.idNoController,
                  hintText: AppLocaleKey.phoneNumber.tr(),
                  title: AppLocaleKey.phoneNumber.tr(),
                  prefixIcon: Icon(
                    Icons.phone_android_rounded,
                    color: AppColor.primaryColor(context),
                  ),
                  fillColor: AppColor.blackTextColor(context).withValues(alpha: 0.05),
                  textStyle: TextStyle(color: AppColor.blackTextColor(context)),
                  hintStyle: TextStyle(
                    color: AppColor.blackTextColor(context).withValues(alpha: 0.3),
                  ),
                  radius: 16,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  validator: (p0) {
                    if (p0 == null || p0.trim().isEmpty) {
                      return AppLocaleKey.idNumberRequired.tr();
                    }
                    if (!p0.startsWith('05') || p0.length < 10) {
                      return isArabic
                          ? 'رقم الجوال يجب أن يبدأ بـ 05 ويتكون من 10 أرقام'
                          : 'Phone number must start with 05 and be 10 digits';
                    }
                    return null;
                  },
                ),
              ),
              Gap(30.h),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 800),
                child: CustomButton(
                  radius: 12.r,
                  onPressed: _isSendingOtp ? null : () => _sendOtp(context),
                  child: _isSendingOtp
                      ? CustomLoading(color: AppColor.whiteColor(context))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sms_rounded,
                              color: AppColor.whiteColor(context),
                              size: 20.sp,
                            ),
                            Gap(10.w),
                            Text(
                              isArabic ? 'إرسال رمز التحقق' : 'Send OTP Code',
                              style: AppTextStyle.buttonStyle(context).copyWith(
                                color: AppColor.whiteColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ] else ...[
              // STEP 2: Verified Phone Badge & Personal Details Form
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColor.whiteColor(context),
                          size: 16.sp,
                        ),
                      ),
                      Gap(12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'رقم الجوال الموثق' : 'Verified Phone Number',
                              style: AppTextStyle.bodySmall(
                                context,
                              ).copyWith(color: Colors.green[800], fontWeight: FontWeight.bold),
                            ),
                            Gap(2.h),
                            Text(
                              widget.cubit.idNoController.text,
                              style: AppTextStyle.bodyMedium(context).copyWith(
                                color: AppColor.blackTextColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isPhoneVerified = false;
                          });
                        },
                        child: Text(
                          isArabic ? 'تغيير' : 'Change',
                          style: AppTextStyle.bodySmall(context).copyWith(
                            color: AppColor.primaryColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Gap(20.h),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 800),
                child: CustomFormField(
                  controller: widget.cubit.fullNameController,
                  hintText: AppLocaleKey.fullName.tr(),
                  title: AppLocaleKey.fullName.tr(),
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: AppColor.primaryColor(context),
                  ),
                  fillColor: AppColor.blackTextColor(context).withValues(alpha: 0.05),
                  textStyle: TextStyle(color: AppColor.blackTextColor(context)),
                  hintStyle: TextStyle(
                    color: AppColor.blackTextColor(context).withValues(alpha: 0.3),
                  ),
                  radius: 16,
                  keyboardType: TextInputType.name,
                  validator: (p0) {
                    if (p0 == null || p0.trim().isEmpty) {
                      return AppLocaleKey.fullNameRequired.tr();
                    }
                    return null;
                  },
                ),
              ),
              Gap(16.h),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 800),
                child: CustomFormField(
                  controller: widget.cubit.userNameController,
                  title: AppLocaleKey.userName.tr(),
                  hintText: AppLocaleKey.userName.tr(),
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: AppColor.primaryColor(context),
                  ),
                  fillColor: AppColor.blackTextColor(context).withValues(alpha: 0.05),
                  textStyle: TextStyle(color: AppColor.blackTextColor(context)),
                  hintStyle: TextStyle(
                    color: AppColor.blackTextColor(context).withValues(alpha: 0.3),
                  ),
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
              Gap(16.h),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 800),
                child: CustomFormField(
                  controller: widget.cubit.emailController,
                  hintText: AppLocaleKey.email.tr(),
                  title: AppLocaleKey.email.tr(),
                  prefixIcon: Icon(Icons.email_outlined, color: AppColor.primaryColor(context)),
                  fillColor: AppColor.blackTextColor(context).withValues(alpha: 0.05),
                  textStyle: TextStyle(color: AppColor.blackTextColor(context)),
                  hintStyle: TextStyle(
                    color: AppColor.blackTextColor(context).withValues(alpha: 0.3),
                  ),
                  radius: 16,
                  keyboardType: TextInputType.emailAddress,
                  validator: (p0) {
                    if (p0 == null || p0.trim().isEmpty) {
                      return AppLocaleKey.emailRequired.tr();
                    }
                    return null;
                  },
                ),
              ),
              Gap(16.h),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFormField(
                      controller: widget.cubit.registerPasswordController,
                      hintText: AppLocaleKey.password.tr(),
                      title: AppLocaleKey.password.tr(),
                      isPassword: true,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: AppColor.primaryColor(context),
                      ),
                      fillColor: AppColor.blackTextColor(context).withValues(alpha: 0.05),
                      textStyle: TextStyle(color: AppColor.blackTextColor(context)),
                      hintStyle: TextStyle(
                        color: AppColor.blackTextColor(context).withValues(alpha: 0.3),
                      ),
                      radius: 16,
                      onChanged: _onPasswordChanged,
                      validator: (p0) {
                        if (p0 == null || p0.trim().isEmpty) {
                          return AppLocaleKey.passwordRequired.tr();
                        }
                        if (!_isPasswordValid) {
                          return isArabic
                              ? 'كلمة المرور لا تستوفي الشروط المطلوبة'
                              : 'Password does not meet the required criteria';
                        }
                        return null;
                      },
                    ),
                    if (_passwordTouched) ...[
                      Gap(10.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children: [
                          PasswordHintChip(
                            label: isArabic ? 'حرف كبير (A-Z)' : 'Uppercase (A-Z)',
                            met: _hasUppercase,
                          ),
                          PasswordHintChip(
                            label: isArabic ? 'حرف صغير (a-z)' : 'Lowercase (a-z)',
                            met: _hasLowercase,
                          ),
                          PasswordHintChip(
                            label: isArabic ? 'رقم (0-9)' : 'Number (0-9)',
                            met: _hasDigit,
                          ),
                          PasswordHintChip(
                            label: isArabic ? 'رمز خاص (!@#...)' : 'Special char (!@#...)',
                            met: _hasSpecial,
                          ),
                          PasswordHintChip(
                            label: isArabic ? '٨ أحرف على الأقل' : 'Min 8 characters',
                            met: _hasMinLength,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Gap(20.h),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 800),
                child: ReservationTermsCheckboxWidget(
                  value: _isTermsAccepted,
                  onChanged: (val) {
                    setState(() {
                      _isTermsAccepted = val ?? false;
                    });
                  },
                ),
              ),
              Gap(24.h),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 800),
                child: CustomButton(
                  radius: 12.r,
                  text: AppLocaleKey.signUp.tr(),
                  cubitState: widget.cubit.state.registerStatus,
                  onPressed: () {
                    if (!widget._formKey.currentState!.validate()) return;
                    if (!_isTermsAccepted) {
                      CommonMethods.showToast(
                        message: isArabic
                            ? 'يرجى الموافقة على الشروط والأحكام أولاً لإتمام إنشاء الحساب'
                            : 'Please agree to the Terms & Conditions to complete registration',
                        type: ToastType.error,
                      );
                      return;
                    }
                    widget.cubit.register();
                  },
                ),
              ),
            ],

            Gap(30.h),
            FadeInUp(
              delay: const Duration(milliseconds: 700),
              duration: const Duration(milliseconds: 800),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocaleKey.alreadyHaveAccount.tr(),
                    style: AppTextStyle.bodyMedium(
                      context,
                      color: AppColor.blackTextColor(context).withValues(alpha: 0.6),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      NavigatorMethods.pushReplacementNamed(
                        context,
                        RoutesName.loginScreen,
                      );
                    },
                    child: Text(
                      AppLocaleKey.login.tr(),
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
      ),
    );
  }
}
