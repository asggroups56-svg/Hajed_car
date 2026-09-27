import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/agent/presentation/screens/widget/icon_btn_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/premium_language_toggle_widget.dart';
import 'package:car/features/auth/presentation/view/cubit/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomHeaderInfoWidget extends StatelessWidget {
  const CustomHeaderInfoWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocaleKey.agentWelcomeName.tr(
                  namedArgs: {'name': HiveMethods.getUserName() ?? ''},
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodyMedium(
                  context,
                ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.w900),
              ),
              Text(
                AppLocaleKey.agentSalesConsultant.tr(),
                style: AppTextStyle.bodyMedium(
                  context,
                ).copyWith(color: AppColor.greyColor(context), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        IconBtn(
          icon: Icons.logout_rounded,
          onTap: () {
            context.read<AuthCubit>().logout();
            Navigator.pushNamedAndRemoveUntil(context, RoutesName.loginScreen, (route) => false);
          },
        ),
        Gap(10.w),
        const PremiumLanguageToggle(),
      ],
    );
  }
}
