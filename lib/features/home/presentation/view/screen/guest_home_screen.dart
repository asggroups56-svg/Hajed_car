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

class _HomeGuestScreenState extends State<HomeGuestScreen>
    with WidgetsBindingObserver {
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
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(20.h),
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _searchCars,
                    decoration: InputDecoration(
                      hintText: AppLocaleKey.searchForYourDreamCar.tr(),
                      hintStyle: AppTextStyle.bodySmall(
                        context,
                      ).copyWith(color: AppColor.greyColor(context)),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColor.primaryColor(context),
                      ),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      filled: true,
                      fillColor: AppColor.secondAppColor(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                          color: AppColor.dividerColor(
                            context,
                          ).withValues(alpha: .5),
                        ),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
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
                    title: AppLocaleKey.recent.tr(),
                    onSeeAll: () {
                      NavigatorMethods.pushNamed(
                        context,
                        RoutesName.popularCarsScreen,
                      );
                    },
                  ),
                  Gap(15.h),
                  const PopularCarsSlider(),
                  Gap(20.h),
                  // ValueListenableBuilder(
                  //   valueListenable: Hive.box('app').listenable(keys: ['recentlyViewed']),
                  //   builder: (context, box, _) {
                  //     final list = box.get('recentlyViewed', defaultValue: []) as List<dynamic>;
                  //     if (list.isEmpty) return const SizedBox.shrink();
                  //     final displayList = list.take(3).toList();
                  //     return Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         SectionTitleWidget(
                  //           title: AppLocaleKey.recentlyViewed.tr(),
                  //           onSeeAll: () {
                  //             NavigatorMethods.pushNamed(context, RoutesName.recentlyViewedScreen);
                  //           },
                  //         ),
                  //         Gap(15.h),
                  //         RecentlyViewedWidget(cars: displayList),
                  //         Gap(20.h),
                  //       ],
                  //     );
                  //   },
                  // ),
                  // SectionTitleWidget(title: AppLocaleKey.searchByBudget.tr(), onSeeAll: null),
                  // Gap(15.h),
                  // const BanksSliderWidget(),
                  // Gap(15.h),
                  // BudgetSearchWidget(
                  //   initialIndex: _selectedBudgetIndex,
                  //   onChanged: (index) {
                  //     setState(() {
                  //       _selectedBudgetIndex = index;
                  //     });
                  //   },
                  // ),
                  // Gap(20.h),
                  // BudgetCarsListWidget(selectedBudgetIndex: _selectedBudgetIndex),
                  // Gap(30.h),
                  // SectionTitleWidget(title: AppLocaleKey.trendingNow.tr()),
                  // Gap(15.h),
                  // const OffersGridWidget(),
                  // Gap(40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchCars(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;
    MainLayout.carsSearchQuery.value = normalizedQuery;
    MainLayout.tabIndex.value = 1;
  }
}
