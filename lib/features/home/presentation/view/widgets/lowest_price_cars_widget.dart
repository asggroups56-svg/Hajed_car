import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/widgets/car_card_widget.dart';
import 'package:car/features/home/presentation/view/widgets/loading_and_empty_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LowestPriceCarsWidget extends StatefulWidget {
  const LowestPriceCarsWidget({super.key});

  @override
  State<LowestPriceCarsWidget> createState() => _LowestPriceCarsWidgetState();
}

class _LowestPriceCarsWidgetState extends State<LowestPriceCarsWidget> {
  late final PageController _pageController = PageController(viewportFraction: .86);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double _priceOf(GetBrandCarsDataModel car) {
    final value = car.effectivePrice ?? '';
    final normalized = value.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? double.infinity;
  }

  List<GetBrandCarsDataModel> _carsFromState(HomeState state) {
    List<GetBrandCarsDataModel> cars = [];
    if (state.allCarsStatus.isSuccess && state.allCarsStatus.data != null) {
      cars = List<GetBrandCarsDataModel>.from(state.allCarsStatus.data!);
    }
    if (cars.isEmpty &&
        state.selectedBrandId != null &&
        state.brandCarsStatus.isSuccess &&
        state.brandCarsStatus.data != null) {
      cars = List<GetBrandCarsDataModel>.from(state.brandCarsStatus.data!);
    }
    if (cars.isEmpty &&
        state.allPopularCarsStatus.isSuccess &&
        state.allPopularCarsStatus.data != null) {
      final map = Map<String, List<GetBrandCarsDataModel>>.from(state.allPopularCarsStatus.data!);
      cars = map.values.expand((list) => list).toList();
    }
    cars.sort((a, b) => _priceOf(a).compareTo(_priceOf(b)));
    return cars;
  }

  void _openCar(GetBrandCarsDataModel car, String heroTag) {
    NavigatorMethods.pushNamed(
      context,
      RoutesName.carDetailsScreen,
      arguments: {'car': car.toMap(), 'heroTag': heroTag},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cars = _carsFromState(state);
        if (cars.isEmpty) {
          if (state.allCarsStatus.isLoading || state.allCarsStatus.isInitial) {
            return const LoadingPlaceholder();
          }
          return const EmptyState();
        }

        final firstCars = cars.take(3).toList();
        if (_currentPage >= firstCars.length) _currentPage = 0;
        final cardHeight = (MediaQuery.of(context).size.height / 1.9).clamp(380.0, 520.0);

        return Column(
          children: [
            SizedBox(
              height: cardHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: firstCars.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final car = firstCars[index];
                  final map = car.toMap();
                  final id = HiveMethods.getCarUniqueId(map);
                  final heroTag = 'home_lowest_price_${id.isNotEmpty ? id : index}';
                  return CarCard(
                    car: map,
                    isSelected: index == _currentPage,
                    onTap: () => _openCar(car, heroTag),
                    onImageTap: () => _openCar(car, heroTag),
                    heroTag: heroTag,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
