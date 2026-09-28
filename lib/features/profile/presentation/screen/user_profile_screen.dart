import 'package:animate_do/animate_do.dart';
import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/admin/presentation/screen/widgets/logout_button_widget.dart';
import 'package:car/features/agent/data/model/customer_profile_model.dart';
import 'package:car/features/agent/presentation/cubit/agent_cubit.dart';
import 'package:car/features/agent/presentation/cubit/agent_state.dart';
import 'package:car/features/auth/presentation/view/cubit/auth_cubit.dart';
import 'package:car/features/profile/presentation/screen/track_order_screen.dart';
import 'package:car/features/profile/presentation/screen/widget/action_tile_widget.dart';
import 'package:car/features/profile/presentation/screen/widget/financial_summary_widget.dart';
import 'package:car/features/profile/presentation/screen/widget/personal_details_section_widget.dart';
import 'package:car/features/profile/presentation/screen/widget/profile_header_banner_widget.dart';
import 'package:car/features/profile/presentation/screen/widget/section_widget.dart';
import 'package:car/features/settings/presentation/screen/widget/delete_account_button_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: HiveMethods.getUserName() ?? '');
    _phoneController = TextEditingController(text: HiveMethods.getSavedMobile());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final code = HiveMethods.getcode();
      final userCode = (code != null && code.isNotEmpty)
          ? code
          : (HiveMethods.getUserCode() ?? '1');
      context.read<AgentCubit>().getCustomerProfile(userCode);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<AgentCubit, AgentState>(
          builder: (context, agentState) {
            final profileStatus = agentState.customerProfileStatus;
            final CustomerProfileModel? profile = profileStatus.data;

            if (profile != null &&
                profile.customerName != null &&
                profile.customerName!.isNotEmpty) {
              if (_nameController.text.isEmpty) {
                _nameController.text = profile.customerName!;
              }
            }
            if (profile != null && profile.tel1 != null && profile.tel1!.isNotEmpty) {
              if (_phoneController.text.isEmpty) {
                _phoneController.text = profile.tel1!;
              }
            }

            return Scaffold(
              backgroundColor: AppColor.scaffoldColor(context),
              appBar: CustomAppBar(
                context,
                title: Text(
                  AppLocaleKey.profile.tr(),
                  style: AppTextStyle.bodyLarge(context).copyWith(
                    color: AppColor.appBarTextColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (profileStatus.isLoading)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: const Center(child: CustomLoading()),
                            ),

                          if (profile != null)
                            ProfileHeaderBannerWidget(
                              profile: profile,
                              nameController: _nameController,
                            ),

                          PersonalDetailsSectionWidget(
                            profile: profile,
                            nameController: _nameController,
                            phoneController: _phoneController,
                          ),

                          if (profile != null &&
                              (profile.balance != null || profile.creditLimit != null)) ...[
                            Gap(24.h),
                            FinancialSummaryWidget(profile: profile),
                          ],

                          Gap(24.h),
                          FadeInUp(
                            delay: const Duration(milliseconds: 100),
                            child: SectionWidget(
                              title: AppLocaleKey.accountSettings.tr(),
                              children: [
                                ActionTileWidget(
                                  icon: Icons.library_books_rounded,
                                  label: AppLocaleKey.trackOrder.tr(),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TrackOrderScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(16.h),
                          FadeInUp(
                            delay: const Duration(milliseconds: 150),
                            child: const DeleteAccountButtonWidget(),
                          ),
                          Gap(32.h),
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: const LogoutButtonWidget(),
                          ),
                          Gap(50.h),
                        ],
                      ),
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
}
