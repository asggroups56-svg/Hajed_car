import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/agent/presentation/cubit/agent_cubit.dart';
import 'package:car/features/agent/presentation/cubit/agent_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SubmitFooter extends StatelessWidget {
  final VoidCallback onSubmit;
  final BuildContext context;
  const SubmitFooter({super.key, required this.onSubmit, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return BlocBuilder<AgentCubit, AgentState>(
      buildWhen: (p, c) => p.bookingPermissionStatus != c.bookingPermissionStatus,
      builder: (context, state) {
        final isLoading = state.bookingPermissionStatus.isLoading;
        final primary = AppColor.primaryColor(context);

        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
          decoration: BoxDecoration(
            color: AppColor.cardColor(context),
            border: Border(
              top: BorderSide(color: AppColor.borderColor(context).withValues(alpha: 0.12)),
            ),
          ),
          child: GestureDetector(
            onTap: isLoading ? null : onSubmit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 54.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLoading
                      ? [primary.withValues(alpha: 0.4), primary.withValues(alpha: 0.4)]
                      : [primary, primary.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: isLoading
                    ? CircularProgressIndicator(
                        color: AppColor.whiteColor(context),
                        strokeWidth: 2.5,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, color: AppColor.whiteColor(context), size: 20),
                          Gap(10.w),
                          Text(
                            AppLocaleKey.create_quotation.tr(),
                            style: AppTextStyle.bodyLarge(context).copyWith(
                              color: AppColor.whiteColor(context),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
