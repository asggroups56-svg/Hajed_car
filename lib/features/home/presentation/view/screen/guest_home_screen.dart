import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
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

class _HomeGuestScreenState extends State<HomeGuestScreen> {


  @override
  void initState() {
    context.read<HomeCubit>().getCarsModels();
    context.read<HomeCubit>().getBanks();
    context.read<HomeCubit>().fetchAllCars();
    context.read<HomeCubit>().getNormalFinancing();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(20.h),
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
                  title: AppLocaleKey.popularCars.tr(),
                  onSeeAll: () {
                    NavigatorMethods.pushNamed(context, RoutesName.popularCarsScreen);
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
    );
  }
}
