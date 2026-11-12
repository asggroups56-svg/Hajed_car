import 'dart:async';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/network/contants.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/widgets/car_card_widget.dart';
import 'package:car/features/home/presentation/view/widgets/loading_and_empty_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PopularCarsSlider extends StatefulWidget {
  const PopularCarsSlider({super.key, this.bestSellersOnly = false});

  final bool bestSellersOnly;

  @override
  State<PopularCarsSlider> createState() => _PopularCarsSliderState();
}

class _PopularCarsSliderState extends State<PopularCarsSlider> {
  late final PageController _pageController;
  late final Timer _autoScrollTimer;

  int _currentPage = 0;
  bool _controllerInitialized = false;
  bool _showAllCars = false;

  static const _autoScrollInterval = Duration(seconds: 4);
  static const _animationDuration = Duration(milliseconds: 800);
  static const _maxDisplayedCars = 3;

  @override
  void initState() {
    super.initState();
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, _onTimerTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllerInitialized) {
      final double screenWidth = MediaQuery.of(context).size.width;
      _pageController = PageController(
        viewportFraction: screenWidth > 600 ? 0.45 : 0.85,
        initialPage: _currentPage,
      );
      _controllerInitialized = true;
    }
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onTimerTick(Timer timer) {
    if (!mounted || !_pageController.hasClients) return;

    final state = context.read<HomeCubit>().state;
    final totalCars = _buildDisplayedCars(state).length;
    final length = state.selectedBrandId != null
        ? totalCars
        : totalCars.clamp(0, _maxDisplayedCars);
    if (length == 0) return;

    final nextPage = (_currentPage + 1) % length;
    _pageController.animateToPage(
      nextPage,
      duration: _animationDuration,
      curve: Curves.easeInOutQuart,
    );
  }

  void _goToDetails(BuildContext context, Map<String, dynamic> car, String heroTag) {
    NavigatorMethods.pushNamed(
      context,
      RoutesName.carDetailsScreen,
      arguments: {'car': car, 'heroTag': heroTag},
    );
  }

  List<Map<String, dynamic>> _buildDisplayedCars(HomeState state) {
    final flatCars = <GetBrandCarsDataModel>[];
    if (state.selectedBrandId != null && state.brandCarsStatus.isSuccess) {
      // A selected model's GetprandcarsData response is authoritative for the
      // home carousel. Otherwise unrelated brands can push its best sellers
      // out of the first visible cards.
      flatCars.addAll(_carsFromResponse(state.brandCarsStatus.data));
    } else if (state.selectedBrandId == null) {
      // The full inventory is the primary source; the grouped map is a
      // fallback for older cached state.
      if (state.allCarsStatus.isSuccess) {
        flatCars.addAll(_carsFromResponse(state.allCarsStatus.data));
      } else if (state.allPopularCarsStatus.isSuccess) {
        flatCars.addAll(_carsFromResponse(state.allPopularCarsStatus.data));
      }
    }

    // The same inventory row can arrive from the aggregate, full inventory,
    // and selected-brand calls. Keep one copy while retaining distinct colors.
    final uniqueCars = <String, GetBrandCarsDataModel>{};
    for (final car in flatCars) {
      final key = car.chassisNo.isNotEmpty && car.chassisNo != 'null'
          ? car.chassisNo
          : '${car.groupCode}_${car.itemCode}_${car.makeYear}_${car.colorCode}_${car.price}';
      uniqueCars.putIfAbsent(key, () => car);
    }
    final cars = uniqueCars.values.toList();
    cars.sort((a, b) {
      final bestSellerOrder = (b.isBestSeller ? 1 : 0).compareTo(
        a.isBestSeller ? 1 : 0,
      );
      return bestSellerOrder != 0
          ? bestSellerOrder
          : _priceOf(a).compareTo(_priceOf(b));
    });
    return _applyBestSellerFilter(cars).map(_carToMap).toList();
  }

  List<GetBrandCarsDataModel> _carsFromResponse(dynamic data) {
    final cars = <GetBrandCarsDataModel>[];

    void addCar(dynamic value) {
      if (value is GetBrandCarsDataModel) {
        cars.add(value);
      } else if (value is Map) {
        cars.add(
          GetBrandCarsDataModel.fromJson(Map<String, dynamic>.from(value)),
        );
      }
    }

    if (data is Map) {
      for (final brandCars in data.values) {
        if (brandCars is Iterable) {
          for (final car in brandCars) {
            addCar(car);
          }
        }
      }
    } else if (data is Iterable) {
      for (final car in data) {
        addCar(car);
      }
    }
    return cars;
  }

  List<GetBrandCarsDataModel> _applyBestSellerFilter(
    List<GetBrandCarsDataModel> cars,
  ) => widget.bestSellersOnly
      ? cars.where((car) => car.isBestSeller).toList()
      : cars;

  double _priceOf(GetBrandCarsDataModel car) {
    final raw = car.SALE_PRICE != null && car.SALE_PRICE! > 0
        ? car.SALE_PRICE.toString()
        : car.price ?? '';
    final normalized = raw.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? double.infinity;
  }

  Map<String, dynamic> _carToMap(GetBrandCarsDataModel car) {
    String imageUrl(String path) =>
        '${Constants.baseImage}${path.replaceAll('../../Img/Emp/', '')}';
    final displayedPrice = car.SALE_PRICE != null && car.SALE_PRICE! > 0
        ? car.SALE_PRICE.toString()
        : car.price;

    final String uniqueId = car.chassisNo.isNotEmpty && car.chassisNo != 'null'
        ? 'chassis_${car.chassisNo}'
        : '${car.groupCode}_${car.itemName}_${car.makeYear}_${car.bodyColor}';

    return {
      'unique_id': uniqueId,
      'name': car.itemName,
      'groupCode': car.groupCode.toString(),
      'itemCode': car.itemCode.toString(),
      'chassisNo': car.chassisNo,
      'image': '${Constants.baseImage}${car.carImage}',
      'extraImages': car.extraImages.map(imageUrl).toList(),
      'brand': car.groupName,
      'price': displayedPrice,
      'PRICE': displayedPrice,
      'SALE_PRICE': car.SALE_PRICE,
      'year': car.makeYear.toString(),
      'mileage': '${car.kilometerReading ?? "0"} كم',
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
      'CUSTOMS_CARD_NO': car.customsCardNo,
      'TRANSMISSION': car.transmission,
      'MAKE_YEAR': car.makeYear,
      'GR_NAME': car.grName,
      'GROUP_NAME': car.groupName,
      // Keep the stock colour identifier when navigating from the home
      // carousel. The booking API validates this value, and rebuilding a car
      // from a map without it turns the colour code into 0.
      'COLOR_CODE': car.colorCode,
      'colorcode': car.colorCode,
      'PaintingsVal': car.paintingsVal,
      'PAINTINGS_VAL': car.paintingsVal,
      'paintingsVal': car.paintingsVal,
      // Offer terms travel with the car so details and the financing
      // calculator opened from this carousel still use the vehicle's offer.
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
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.selectedBrandId != current.selectedBrandId ||
          previous.brandCarsStatus != current.brandCarsStatus ||
          previous.allPopularCarsStatus != current.allPopularCarsStatus ||
          previous.allCarsStatus != current.allCarsStatus,
      builder: (context, state) {
        final cars = _buildDisplayedCars(state);
        final isLoadingSelectedBrand = state.selectedBrandId != null &&
            (state.brandCarsStatus.isLoading || state.brandCarsStatus.isInitial);
        final isLoadingAllCars = state.selectedBrandId == null &&
            cars.isEmpty &&
            (state.allPopularCarsStatus.isLoading ||
                state.allPopularCarsStatus.isInitial ||
                state.allCarsStatus.isLoading ||
                state.allCarsStatus.isInitial);
        if (isLoadingSelectedBrand || isLoadingAllCars) {
          return const LoadingPlaceholder();
        }
        if (cars.isEmpty) return const EmptyState();
        if (_currentPage >= cars.length) _currentPage = 0;
        final displayCount = state.selectedBrandId != null
            ? cars.length
            : cars.length.clamp(0, _maxDisplayedCars);
        return SizedBox(
          height: (MediaQuery.of(context).size.height / 1.9).clamp(380.0, 520.0),
          child: PageView.builder(
            controller: _pageController,
            itemCount: displayCount,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              final carId = HiveMethods.getCarUniqueId(cars[index]);
              final heroTag = 'popular_car_image_${carId.isNotEmpty ? carId : index}_$index';
              return CarCard(
                car: cars[index],
                isSelected: index == _currentPage,
                onTap: () => _goToDetails(context, cars[index], heroTag),
                onImageTap: () => _goToDetails(context, cars[index], heroTag),
                heroTag: heroTag,
              );
            },
          ),
        );
      },
    );
  }
}
