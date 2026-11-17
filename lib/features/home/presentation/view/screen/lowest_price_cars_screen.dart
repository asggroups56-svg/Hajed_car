import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/presentation/view/widgets/car_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LowestPriceCarsScreen extends StatelessWidget {
  const LowestPriceCarsScreen({super.key, required this.cars});

  final List<GetBrandCarsDataModel> cars;

  double _priceOf(GetBrandCarsDataModel car) {
    final value = car.effectivePrice ?? '';
    final normalized = value.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    final sortedCars = List<GetBrandCarsDataModel>.from(cars)
      ..sort((a, b) => _priceOf(a).compareTo(_priceOf(b)));

    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(
        context,
        centerTitle: false,
        automaticallyImplyLeading: true,
        title: Text(AppLocaleKey.lowestPrice.tr(), style: AppTextStyle.titleMedium(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ValueListenableBuilder<Box>(
                  valueListenable: Hive.box('app').listenable(keys: ['cars_view_mode_grid']),
                  builder: (context, box, _) {
                    final isGrid = box.get('cars_view_mode_grid', defaultValue: false);
                    return InkWell(
                      borderRadius: BorderRadius.circular(8.r),
                      onTap: () => box.put('cars_view_mode_grid', !isGrid),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColor.secondAppColor(context),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColor.blackTextColor(context).withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          isGrid ? Icons.view_agenda_rounded : Icons.grid_view_rounded,
                          size: 16.sp,
                          color: isGrid
                              ? AppColor.primaryColor(context)
                              : AppColor.blackTextColor(context),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box>(
              valueListenable: Hive.box('app').listenable(keys: ['cars_view_mode_grid']),
              builder: (context, box, _) {
                final isGrid = box.get('cars_view_mode_grid', defaultValue: false);

                if (isGrid) {
                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 28.h),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.48,
                    ),
                    itemCount: sortedCars.length,
                    itemBuilder: (context, index) {
                      final car = sortedCars[index];
                      final map = car.toMap();
                      final id = HiveMethods.getCarUniqueId(map);
                      final heroTag = 'lowest_price_grid_${id.isNotEmpty ? id : index}';
                      return CarCard(
                        car: map,
                        isSelected: true,
                        heroTag: heroTag,
                        padding: EdgeInsets.all(2.w),
                        onTap: () => NavigatorMethods.pushNamed(
                          context,
                          RoutesName.carDetailsScreen,
                          arguments: {'car': map, 'heroTag': heroTag},
                        ),
                      );
                    },
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 28.h),
                  itemCount: sortedCars.length,
                  separatorBuilder: (_, _) => Gap(16.h),
                  itemBuilder: (context, index) {
                    final car = sortedCars[index];
                    final map = car.toMap();
                    final id = HiveMethods.getCarUniqueId(map);
                    final heroTag = 'lowest_price_page_${id.isNotEmpty ? id : index}';
                    return SizedBox(
                      height: (MediaQuery.sizeOf(context).height / 1.9).clamp(380.0, 520.0),
                      child: CarCard(
                        car: map,
                        isSelected: true,
                        heroTag: heroTag,
                        onTap: () => NavigatorMethods.pushNamed(
                          context,
                          RoutesName.carDetailsScreen,
                          arguments: {'car': map, 'heroTag': heroTag},
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
