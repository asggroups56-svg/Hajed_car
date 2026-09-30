import 'package:car/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/network/contants.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/cars_models_response.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/widgets/app_header_popular_widget.dart';
import 'package:car/features/home/presentation/view/widgets/brand_header_widget.dart';
import 'package:car/features/home/presentation/view/widgets/empty_state_widget.dart';
import 'package:car/features/home/presentation/view/widgets/magazine_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class PopularCarsScreen extends StatefulWidget {
  const PopularCarsScreen({super.key});

  @override
  State<PopularCarsScreen> createState() => _PopularCarsScreenState();
}

class _PopularCarsScreenState extends State<PopularCarsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<HomeCubit>().state;
      if (state.selectedBrandId != null) {
        context.read<HomeCubit>().getBrandCars(state.selectedBrandId.toString());
      } else if (state.brands.isEmpty) {
        context.read<HomeCubit>().getCarsModels();
      }
      context.read<HomeCubit>().getNormalFinancing();
    });
  }

  Map<String, List<GetBrandCarsDataModel>> _filteredCarsMap(HomeState state) {
    if (state.selectedBrandId == null) {
      return Map<String, List<GetBrandCarsDataModel>>.from(state.allPopularCarsStatus.data ?? {});
    }
    final brands = state.brands;
    CarModel? selectedBrand;
    for (final b in brands) {
      if (b.groupCode == state.selectedBrandId) {
        selectedBrand = b;
        break;
      }
    }

    if (selectedBrand == null) return {};

    final brandName = selectedBrand.groupName;

    if (state.brandCarsStatus.isSuccess && state.brandCarsStatus.data != null) {
      final List<GetBrandCarsDataModel> brandCars = List<GetBrandCarsDataModel>.from(
        state.brandCarsStatus.data!,
      );
      return {brandName: brandCars};
    }

    final allCarsMap = state.allPopularCarsStatus.data ?? {};
    return {brandName: allCarsMap[brandName] ?? []};
  }

  Map<String, dynamic> _carToMap(GetBrandCarsDataModel car, String? selectedBrandName) {
    String imageUrl(String path) =>
        "${Constants.baseImage}${path.replaceAll("../../Img/Emp/", "")}";
    final brand = selectedBrandName ?? car.groupName;
    return {
      'unique_id': '${car.itemCode}_${car.chassisNo}',
      'name': car.itemName,
      'groupCode': car.groupCode.toString(),
      'itemCode': car.itemCode.toString(),
      'chassisNo': car.chassisNo,
      'image': car.fullCarImage,
      'extraImages': car.extraImages.map(imageUrl).toList(),
      'brand': brand,
      'price': car.price,
      'PRICE': car.price,
      'year': car.makeYear.toString(),
      'mileage': car.kilometerReading != null ? '${car.kilometerReading} كم' : '0 كم',
      'engine': '${car.cylinder} Cyl',
      'video_id': 'D7O8J5vVf-M',
      'isFavorite': false,
      'carStatus': car.carStatus,
      'carStatusText': car.carStatusText,
      'CHASSIS_NO': car.chassisNo,
      'MOTOR_NO': car.motorNo,
      'KILOMETER_READING': car.kilometerReading,
      'CYLINDER': car.cylinder,
      'POWER_HOURSE': car.powerHourse,
      'FUEL_CAPACITY': car.fuelCapacity,
      'SEAT_NO': car.seatNo,
      'DOOR_NO': car.doorNo,
      'Color': car.color,
      'BODY_COLOR': car.bodyColor,
      'color': car.color.isNotEmpty ? car.color : car.bodyColor,
      'FUEL_TYPE': car.fuelType,
      'TRANSMISSION': car.transmission,
      'MAKE_YEAR': car.makeYear,
      'GR_NAME': car.grName,
      'GROUP_NAME': car.groupName,
    };
  }

  bool _isCarsMapEmpty(Map<String, List<GetBrandCarsDataModel>> map) {
    return map.isEmpty || (map.length == 1 && map.values.first.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isBrandSelected = state.selectedBrandId != null;
        final status = isBrandSelected ? state.brandCarsStatus : state.allPopularCarsStatus;
        final carsMap = _filteredCarsMap(state);
        CarModel? selectedBrand;
        if (isBrandSelected) {
          for (final b in state.brands) {
            if (b.groupCode == state.selectedBrandId) {
              selectedBrand = b;
              break;
            }
          }
        }
        final screenTitle = selectedBrand != null
            ? selectedBrand.groupName
            : AppLocaleKey.popularCars.tr();

        return Scaffold(
          backgroundColor: AppColor.scaffoldColor(context),
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: RefreshIndicator(
              onRefresh: () async {
                if (isBrandSelected) {
                  await context.read<HomeCubit>().getBrandCars(state.selectedBrandId.toString());
                } else {
                  await context.read<HomeCubit>().getCarsModels();
                }
              },
              color: AppColor.primaryColor(context),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  AppHeader(title: screenTitle),
                  if (status.isLoading)
                    const SliverFillRemaining(child: Center(child: CustomLoading()))
                  else if (_isCarsMapEmpty(carsMap))
                    EmptyState(isBrandSelected: isBrandSelected)
                  else
                    ..._buildCarsSlivers(carsMap, isBrandSelected, selectedBrand?.groupName),
                  SliverToBoxAdapter(child: Gap(100.h)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCarsSlivers(
    Map<String, List<GetBrandCarsDataModel>> carsMap,
    bool isBrandSelected,
    String? selectedBrandName,
  ) {
    return carsMap.entries
        .where((e) => e.value.isNotEmpty)
        .expand(
          (entry) => [
            if (!isBrandSelected)
              SliverToBoxAdapter(
                child: BrandHeader(brandName: entry.key, count: entry.value.length),
              ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: isBrandSelected ? 16.h : 8.h,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final car = _carToMap(entry.value[index], selectedBrandName);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: MagazineCardWidget(
                      car: car,
                      heroTag: "popular_screen_car_image_${car["itemCode"] ?? car["name"]}",
                    ),
                  );
                }, childCount: entry.value.length),
              ),
            ),
          ],
        )
        .toList();
  }
}
