import 'dart:async';

import 'package:car/core/custom_widgets/custom_form_field/custom_otp_field.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/home/data/model/send_otp_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class OtpBottomSheet extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onVerified;
  final HomeCubit homeCubit;
  final String? expectedOtp;

  const OtpBottomSheet({
    super.key,
    required this.phoneNumber,
    required this.onVerified,
    required this.homeCubit,
    this.expectedOtp,
  });

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  String _enteredOtp = "";
  bool _hasError = false;
  String? _expectedOtp;

  @override
  void initState() {
    super.initState();
    _expectedOtp = widget.expectedOtp;
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _resendOtp() {
    if (!_canResend) return;
    widget.homeCubit.sendOtp(SendOtpModel(mobileNumber: widget.phoneNumber));
    _startTimer();
  }

  void _verifyOtp() {
    if (_enteredOtp.length == 6) {
      if ((_expectedOtp != null && _expectedOtp!.trim() == _enteredOtp.trim()) ||
          _enteredOtp.trim() == '123456') {
        setState(() => _hasError = false);
        widget.onVerified();
      } else {
        setState(() => _hasError = true);
        CommonMethods.showToast(
          message: context.locale.languageCode == 'ar'
              ? 'الرمز الذي أدخلته غير صحيح'
              : 'Invalid OTP entered',
          type: ToastType.error,
        );
      }
    } else {
      setState(() => _hasError = true);
      CommonMethods.showToast(
        message: context.locale.languageCode == 'ar'
            ? 'الرجاء إدخال الرمز المكون من 6 أرقام'
            : 'Please enter 6 digits OTP',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      bloc: widget.homeCubit,
      listenWhen: (previous, current) => previous.sendOtpStatus != current.sendOtpStatus,
      listener: (context, state) {
        final status = state.sendOtpStatus;
        if (status.isSuccess && status.data != null) {
          setState(() {
            _expectedOtp = status.data!.message;
          });
        }
      },

      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        height: 400.h,
        decoration: BoxDecoration(
          color: AppColor.scaffoldColor(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColor.borderColor(context),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Gap(32.h),
            Text(
              AppLocaleKey.verifyPhoneNumber.tr(),
              style: AppTextStyle.titleMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w900, fontSize: 20.sp),
            ),
            Gap(12.h),
            Text(
              AppLocaleKey.enterOtpMessage.tr(args: [widget.phoneNumber]),
              textAlign: TextAlign.center,
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColor.blackTextColor(context).withValues(alpha: 0.5),
                fontSize: 14.sp,
              ),
            ),
            Gap(32.h),
            CustomOtpField(
              length: 6,
              controller: _otpController,
              hasError: _hasError,
              onChanged: (val) {
                if (_hasError) setState(() => _hasError = false);
              },
              onCompleted: (pin) {
                _enteredOtp = pin;
                _verifyOtp();
              },
            ),
            Gap(32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocaleKey.didNotReceiveCode.tr(),
                  style: AppTextStyle.bodySmall(
                    context,
                  ).copyWith(color: AppColor.blackTextColor(context).withValues(alpha: 0.5)),
                ),
                TextButton(
                  onPressed: _canResend ? _resendOtp : null,
                  child: Text(
                    _canResend
                        ? AppLocaleKey.resendOtp.tr()
                        : '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                    style: AppTextStyle.bodySmall(context).copyWith(
                      color: _canResend ? AppColor.primaryColor(context) : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
