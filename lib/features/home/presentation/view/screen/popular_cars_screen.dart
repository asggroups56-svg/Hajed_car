import 'package:car/core/cache/hive/hive_methods.dart';
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
  const PopularCarsScreen({super.key, this.bestSellersOnly = false});

  final bool bestSellersOnly;

  @override
  State<PopularCarsScreen> createState() => _PopularCarsScreenState();
}

class _PopularCarsScreenState extends State<PopularCarsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<HomeCubit>().state;
      if (widget.bestSellersOnly && !state.allPopularCarsStatus.isSuccess) {
        context.read<HomeCubit>().getCarsModels();
      } else if (state.selectedBrandId != null) {
        context.read<HomeCubit>().getBrandCars(
          state.selectedBrandId.toString(),
        );
      } else if (state.brands.isEmpty) {
        context.read<HomeCubit>().getCarsModels();
      }
      context.read<HomeCubit>().getNormalFinancing();
    });
  }

  Map<String, List<GetBrandCarsDataModel>> _filteredCarsMap(HomeState state) {
    if (widget.bestSellersOnly) {
      final cars = <GetBrandCarsDataModel>[];
      void addBestSellers(dynamic data) {
        void addItem(dynamic item) {
          if (item is GetBrandCarsDataModel && item.isBestSeller) {
            cars.add(item);
          } else if (item is Map) {
            final car = GetBrandCarsDataModel.fromJson(
              Map<String, dynamic>.from(item),
            );
            if (car.isBestSeller) cars.add(car);
          }
        }

        if (data is Map) {
          for (final value in data.values) {
            if (value is Iterable) {
              for (final item in value) {
                addItem(item);
              }
            }
          }
        } else if (data is Iterable) {
          for (final item in data) {
            addItem(item);
          }
        }
      }
      addBestSellers(state.allPopularCarsStatus.data);
      addBestSellers(state.allCarsStatus.data);
      addBestSellers(state.brandCarsStatus.data);
      final uniqueCars = <String, GetBrandCarsDataModel>{};
      for (final car in cars) {
        final key = car.chassisNo.isNotEmpty && car.chassisNo != 'null'
            ? car.chassisNo
            : '${car.groupCode}_${car.itemCode}_${car.makeYear}_${car.colorCode}_${car.price}';
        uniqueCars.putIfAbsent(key, () => car);
      }
      return uniqueCars.isEmpty
          ? {}
          : {AppLocaleKey.bestSellerCars.tr(): uniqueCars.values.toList()};
    }

    if (state.selectedBrandId == null) {
      return Map<String, List<GetBrandCarsDataModel>>.from(
        state.allPopularCarsStatus.data ?? {},
      );
    }
    final brands = state.brands.expand((brand) => [brand, ...brand.children]);
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
      final List<GetBrandCarsDataModel> brandCars =
          List<GetBrandCarsDataModel>.from(state.brandCarsStatus.data!);
      return {brandName: brandCars};
    }

    final allCarsMap = state.allPopularCarsStatus.data ?? {};
    return {brandName: allCarsMap[brandName] ?? []};
  }

  List<GetBrandCarsDataModel> _sortBestSellersFirst(
    List<GetBrandCarsDataModel> cars,
  ) => List<GetBrandCarsDataModel>.from(cars)
    ..sort((a, b) => (b.isBestSeller ? 1 : 0).compareTo(a.isBestSeller ? 1 : 0));

  Map<String, dynamic> _carToMap(
    GetBrandCarsDataModel car,
    String? selectedBrandName,
  ) {
    String imageUrl(String path) =>
        "${Constants.baseImage}${path.replaceAll("../../Img/Emp/", "")}";
    final brand = selectedBrandName ?? car.groupName;
    final displayedPrice = car.SALE_PRICE != null && car.SALE_PRICE! > 0
        ? car.SALE_PRICE.toString()
        : car.price;
    return {
      'unique_id': '${car.itemCode}_${car.chassisNo}',
      'name': car.itemName,
      'groupCode': car.groupCode.toString(),
      'itemCode': car.itemCode.toString(),
      'chassisNo': car.chassisNo,
      'image': car.fullCarImage,
      'extraImages': car.extraImages.map(imageUrl).toList(),
      'brand': brand,
      'price': displayedPrice,
      'PRICE': displayedPrice,
      'SALE_PRICE': car.SALE_PRICE,
      'year': car.makeYear.toString(),
      'mileage': car.kilometerReading != null
          ? '${car.kilometerReading} كم'
          : '0 كم',
      'engine': '${car.cylinder} Cyl',
      'video_id': 'D7O8J5vVf-M',
      'isFavorite': false,
      'carStatus': car.carStatus,
      'carStatusText': car.carStatusText,
      'isAvailable': car.carStatus == 1,
      'isPopular': true,
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
      'PaintingsVal': car.paintingsVal,
      'PAINTINGS_VAL': car.paintingsVal,
      'paintingsVal': car.paintingsVal,
      // A vehicle row can carry its own offer terms. They must survive the
      // map rebuild so the details page and calculator keep the offer instead
      // of falling back to the standard bank financing.
      'FirstInstallmentPct': car.firstInstallmentPct,
      'FirstInstallmentPctother': car.firstInstallmentPctOther,
      'LastInstallmentPct': car.lastInstallmentPct,
      'LastInstallmentPctother': car.lastInstallmentPctOther,
      'AdminFeesPct': car.adminFeesPct,
      'AdminFeesPctother': car.adminFeesPctOther,
      'InterestRate': car.interestRate,
      'InterestRate_other': car.interestRateOther,
      'InsurancePct': car.insurancePct,
      'InsurancePctother': car.insurancePctOther,
      'InsuranceVal': car.insuranceAmount,
      'BankOrProvider': car.bankCode,
      'BankName': car.bankName,
      'IsActive': car.isActive,
      'EndDate': car.endDate,
      'SPECIFIC_NAME': car.specificName,
      'specificName': car.specificName,
      'IsBestSeller': car.isBestSeller ? 1 : 0,
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
        final status = widget.bestSellersOnly
            ? state.allPopularCarsStatus
            : isBrandSelected
            ? state.brandCarsStatus
            : state.allPopularCarsStatus;
        final hasFallbackData =
            state.allCarsStatus.isSuccess || state.brandCarsStatus.isSuccess;
        final isLoading = widget.bestSellersOnly
            ? (status.isLoading || status.isInitial) && !hasFallbackData
            : status.isLoading || status.isInitial;
        final carsMap = _filteredCarsMap(state);
        CarModel? selectedBrand;
        if (isBrandSelected) {
          for (final b in state.brands.expand((brand) => [brand, ...brand.children])) {
            if (b.groupCode == state.selectedBrandId) {
              selectedBrand = b;
              break;
            }
          }
        }
        final screenTitle = widget.bestSellersOnly
            ? AppLocaleKey.bestSellerCars.tr()
            : selectedBrand != null
            ? selectedBrand.groupName
            : AppLocaleKey.popularCars.tr();

        return Scaffold(
          backgroundColor: AppColor.scaffoldColor(context),
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: RefreshIndicator(
              onRefresh: () async {
                if (widget.bestSellersOnly) {
                  await context.read<HomeCubit>().getCarsModels();
                } else if (isBrandSelected) {
                  await context.read<HomeCubit>().getBrandCars(
                    state.selectedBrandId.toString(),
                  );
                } else {
                  await context.read<HomeCubit>().getCarsModels();
                }
              },
              color: AppColor.primaryColor(context),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  AppHeader(title: screenTitle),
                  if (isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CustomLoading()),
                    )
                  else if (_isCarsMapEmpty(carsMap))
                    EmptyState(isBrandSelected: isBrandSelected && !widget.bestSellersOnly)
                  else
                    ..._buildCarsSlivers(
                      carsMap,
                      isBrandSelected || widget.bestSellersOnly,
                      widget.bestSellersOnly ? null : selectedBrand?.groupName,
                    ),
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
    final slivers = <Widget>[];
    for (final entry in carsMap.entries.where((entry) => entry.value.isNotEmpty)) {
      final cars = _sortBestSellersFirst(entry.value);
      final bestSellers = cars.where((car) => car.isBestSeller).toList();
      final otherCars = cars.where((car) => !car.isBestSeller).toList();

      if (bestSellers.isNotEmpty) {
        slivers.addAll([
          SliverToBoxAdapter(
            child: BrandHeader(
              brandName: AppLocaleKey.bestSellerCars.tr(),
              count: bestSellers.length,
            ),
          ),
          _buildCarsList(bestSellers, isBrandSelected, selectedBrandName),
        ]);
      }

      if (otherCars.isNotEmpty) {
        if (!isBrandSelected) {
          slivers.add(
            SliverToBoxAdapter(
              child: BrandHeader(brandName: entry.key, count: otherCars.length),
            ),
          );
        }
        slivers.add(_buildCarsList(otherCars, isBrandSelected, selectedBrandName));
      }
    }
    return slivers;
  }

  Widget _buildCarsList(
    List<GetBrandCarsDataModel> cars,
    bool isBrandSelected,
    String? selectedBrandName,
  ) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: isBrandSelected ? 16.h : 8.h,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final car = _carToMap(cars[index], selectedBrandName);
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: MagazineCardWidget(
              car: car,
              heroTag: 'popular_screen_car_image_${HiveMethods.getCarUniqueId(car)}_$index',
            ),
          );
        }, childCount: cars.length),
      ),
    );
  }
}
