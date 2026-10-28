import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/screen/main_layout.dart';
import 'package:car/features/home/presentation/view/widgets/ads_slider_widget.dart';
import 'package:car/features/home/presentation/view/widgets/categories_widget.dart';
import 'package:car/features/home/presentation/view/widgets/popular_cars_slider_widget.dart';
import 'package:car/features/home/presentation/view/widgets/section_title_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class HomeGuestScreen extends StatefulWidget {
  const HomeGuestScreen({super.key});
  @override
  State<HomeGuestScreen> createState() => _HomeGuestScreenState();
}

class _HomeGuestScreenState extends State<HomeGuestScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<HomeCubit>().refreshHomeData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HomeCubit>().refreshHomeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().refreshHomeData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(20.h),
                  // ── Search bar + Filter button ─────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate immediately to cars tab on tap
                            MainLayout.tabIndex.value = 1;
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: AppLocaleKey.searchForYourDreamCar.tr(),
                                hintStyle: AppTextStyle.bodySmall(
                                  context,
                                ).copyWith(color: AppColor.greyColor(context)),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: AppColor.primaryColor(context),
                                ),
                                filled: true,
                                fillColor: AppColor.secondAppColor(context),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: AppColor.dividerColor(context).withValues(alpha: .5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: AppColor.primaryColor(context),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Gap(10.w),
                      // ── Filter button ──────────────────────────────────
                      GestureDetector(
                        onTap: () => NavigatorMethods.pushNamed(context, RoutesName.filterScreen),
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: AppColor.blackColor(context),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: AppColor.whiteColor(context),
                            size: 22.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(15.h),
                  const AdsSliderWidget(),
                  Gap(15.h),
                  SectionTitleWidget(
                    title: AppLocaleKey.brands.tr(),
                    onSeeAll: () {
                      Navigator.pushNamed(context, 'allBrandsScreen');
                    },
                  ),
                  Gap(15.h),
                  const CategoriesWidget(),
                  Gap(15.h),
                  SectionTitleWidget(
                    title: AppLocaleKey.trending_now.tr(),
                    onSeeAll: () {
                      NavigatorMethods.pushNamed(context, RoutesName.popularCarsScreen);
                    },
                  ),
                  Gap(15.h),
                  const PopularCarsSlider(),
                  Gap(20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
