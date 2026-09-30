import 'dart:async';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/network/contants.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/widgets/car_card_widget.dart';
import 'package:car/features/home/presentation/view/widgets/loading_and_empty_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PopularCarsSlider extends StatefulWidget {
  const PopularCarsSlider({super.key});

  @override
  State<PopularCarsSlider> createState() => _PopularCarsSliderState();
}

class _PopularCarsSliderState extends State<PopularCarsSlider> {
  late final PageController _pageController;
  late final Timer _autoScrollTimer;

  int _currentPage = 0;
  bool _controllerInitialized = false;

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

    final data = context.read<HomeCubit>().state.brandCarsStatus.data;
    final totalCars = (data is List) ? data.length : 0;
    final length = totalCars.clamp(0, _maxDisplayedCars);
    if (length == 0) return;

    final nextPage = (_currentPage + 1) % length;
    _pageController.animateToPage(
      nextPage,
      duration: _animationDuration,
      curve: Curves.easeInOutQuart,
    );
  }

  void _goToDetails(BuildContext context, Map<String, dynamic> car) {
    NavigatorMethods.pushNamed(
      context,
      RoutesName.carDetailsScreen,
      arguments: {'car': car, 'heroTag': 'popular_car_image_${car['itemCode'] ?? car['name']}'},
    );
  }

  List<Map<String, dynamic>> _buildDisplayedCars(HomeState state) {
    final isBrandSelected = state.selectedBrandId != null;
    final status = isBrandSelected ? state.brandCarsStatus : state.allPopularCarsStatus;

    if (!status.isSuccess || status.data == null) return [];

    final List<GetBrandCarsDataModel> flatCars = isBrandSelected
        ? (status.data as List<GetBrandCarsDataModel>).take(_maxDisplayedCars).toList()
        : (status.data as Map<String, List<GetBrandCarsDataModel>>).values
              .expand((cars) => cars.take(_maxDisplayedCars))
              .toList();

    return flatCars.map(_carToMap).toList();
  }

  Map<String, dynamic> _carToMap(GetBrandCarsDataModel car) {
    String imageUrl(String path) =>
        '${Constants.baseImage}${path.replaceAll('../../Img/Emp/', '')}';

    return {
      'unique_id': '${car.itemCode}_${car.chassisNo}',
      'name': car.itemName,
      'groupCode': car.groupCode.toString(),
      'itemCode': car.itemCode.toString(),
      'chassisNo': car.chassisNo,
      'image': '${Constants.baseImage}${car.carImage}',
      'extraImages': car.extraImages.map(imageUrl).toList(),
      'brand': car.groupName,
      'price': car.price,
      'PRICE': car.price,
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
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isBrandSelected = state.selectedBrandId != null;
        final status = isBrandSelected ? state.brandCarsStatus : state.allPopularCarsStatus;
        if (status.isLoading || status.isInitial) {
          return const LoadingPlaceholder();
        }
        final cars = _buildDisplayedCars(state);
        if (cars.isEmpty) return const EmptyState();
        if (_currentPage >= cars.length) _currentPage = 0;
        final displayCount = cars.length.clamp(0, _maxDisplayedCars);
        return SizedBox(
          height: MediaQuery.of(context).size.height / 2.1,
          child: PageView.builder(
            controller: _pageController,
            itemCount: displayCount,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              return CarCard(
                car: cars[index],
                isSelected: index == _currentPage,
                onTap: () => _goToDetails(context, cars[index]),
                onImageTap: () => _goToDetails(context, cars[index]),
                onOrderNow: () {
                  if (HiveMethods.getToken() == null) {
                    CommonMethods.showLoginRequiredDialog(context);
                  } else {
                    Navigator.pushNamed(
                      context,
                      RoutesName.carReservationScreen,
                      arguments: {'car': cars[index], 'isFromLink': false},
                    );
                  }
                },
                heroTag: 'popular_car_image_${cars[index]['itemCode'] ?? cars[index]['name']}',
              );
            },
          ),
        );
      },
    );
  }
}
