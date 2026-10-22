import 'dart:developer';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/auth/presentation/view/cubit/auth_cubit.dart';
import 'package:car/features/auth/presentation/view/screen/widget/custom_register_form_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().clearRegisterFields();
  }

  void _onClose() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      HiveMethods.updateIsGuest(true);
      NavigatorMethods.pushReplacementNamed(context, RoutesName.mainLayout);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onClose();
        }
      },
      child: Scaffold(
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
                AppColor.primaryColor(context).withValues(alpha: (0.1)),
              ],
            ),
          ),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.registerStatus.isSuccess) {
                CommonMethods.showToast(
                  message: AppLocaleKey.registerSuccess.tr(),
                  type: ToastType.success,
                );
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  NavigatorMethods.pushReplacementNamed(
                    context,
                    RoutesName.loginScreen,
                  );
                }
              }
              if (state.registerStatus.isFailure) {
                log(state.registerStatus.error?.toString() ?? 'Registration failed');
                final error = state.registerStatus.error ?? 'Registration failed';
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
                        Align(
                          alignment: AlignmentDirectional.topStart,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _onClose,
                          ),
                        ),
                        CustomRegisterFormWidget(formKey: _formKey, cubit: cubit),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
