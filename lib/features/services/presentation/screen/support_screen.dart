import 'package:animate_do/animate_do.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/services/presentation/widgets/contact_item_widget.dart';
import 'package:car/features/services/presentation/widgets/section_header_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180.h,
            pinned: true,
            backgroundColor: AppColor.appBarColor(context),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColor.whiteColor(context)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                AppLocaleKey.supportCenter.tr(),
                style: AppTextStyle.titleMedium(
                  context,
                ).copyWith(color: AppColor.whiteColor(context), fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor(context),
                      AppColor.primaryColor(context).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(
                      Icons.support_agent_rounded,
                      size: 120.sp,
                      color: AppColor.blackTextColor(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    child: Text(
                      AppLocaleKey.howCanWeHelp.tr(),
                      style: AppTextStyle.titleLarge(context).copyWith(
                        color: AppColor.blackTextColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Gap(8.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      AppLocaleKey.slogan.tr(),
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        color: AppColor.primaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Gap(24.h),
                  // COMPLAINTS & EVALUATION CARDS
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: FadeInLeft(
                  //         delay: const Duration(milliseconds: 200),
                  //         child: ActionCardWidget(
                  //           title: AppLocaleKey.complaints.tr(),
                  //           icon: Icons.report_problem_rounded,
                  //           bgColor: const Color(0xFFFEE2E2),
                  //           iconColor: AppColor.redColor(context),
                  //           onTap: () => Navigator.push(
                  //             context,
                  //             MaterialPageRoute(builder: (context) => const ComplaintsScreen()),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     Gap(12.w),
                  //     Expanded(
                  //       child: FadeInRight(
                  //         delay: const Duration(milliseconds: 200),
                  //         child: ActionCardWidget(
                  //           title: AppLocaleKey.serviceEvaluation.tr(),
                  //           icon: Icons.star_rate_rounded,
                  //           bgColor: const Color(0xFFFEF3C7),
                  //           iconColor: const Color(0xFFD97706),
                  //           onTap: () => Navigator.push(
                  //             context,
                  //             MaterialPageRoute(builder: (context) => const EvaluationScreen()),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Gap(24.h),

                  const ContactItemWidget(value: '920024446', icon: Icons.headset_mic_rounded),
                  Gap(20.h),
                  // GENERAL CONTACT
                  SectionHeaderWidget(
                    title: AppLocaleKey.landlineAndWhatsapp.tr(),
                    icon: Icons.phone_android_rounded,
                  ),
                  const ContactItemWidget(value: '920024446', icon: Icons.phone_rounded),
                  Gap(20.h),
                  SectionHeaderWidget(title: AppLocaleKey.emails.tr(), icon: Icons.email_rounded),
                  const ContactItemWidget(
                    value: 'info@binwazir.com',
                    icon: Icons.alternate_email_rounded,
                  ),
                  const ContactItemWidget(
                    value: 'media@binwazir.com',
                    icon: Icons.alternate_email_rounded,
                  ),
                  Gap(20.h),

                  // MANAGEMENT
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
