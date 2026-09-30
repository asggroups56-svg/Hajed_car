import 'dart:developer';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/auth/presentation/view/cubit/auth_cubit.dart';
import 'package:car/features/auth/presentation/view/screen/widget/custom_FormL_login_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColor.secondAppColor(context),
              AppColor.gradientSecondaryColor(context),
              AppColor.primaryColor(context).withValues(alpha: 0.1),
            ],
          ),
        ),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.loginStatus.isSuccess) {
              CommonMethods.showToast(
                message: AppLocaleKey.loginSuccess.tr(),
                type: ToastType.success,
              );
              if (HiveMethods.isUserRole()) {
                NavigatorMethods.pushReplacementNamed(context, RoutesName.mainLayout);
              } else if (HiveMethods.isAgentRole()) {
                NavigatorMethods.pushReplacementNamed(context, RoutesName.agentDashboard);
              } else {
                NavigatorMethods.pushReplacementNamed(context, RoutesName.adminDashboard);
              }
            }
            if (state.loginStatus.isFailure) {
              log(state.loginStatus.error?.toString() ?? 'Login failed');
              final error = state.loginStatus.error ?? 'Login failed';
              CommonMethods.showToast(message: error, type: ToastType.error);
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (Navigator.canPop(context))
                        Align(
                          alignment: AlignmentDirectional.topStart,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      CustomFormLoginWidget(formKey: _formKey, cubit: cubit),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
