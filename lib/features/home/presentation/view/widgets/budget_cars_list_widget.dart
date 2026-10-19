import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/widgets/horizontal_car_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BudgetCarsListWidget extends StatelessWidget {
  static const double _financingFee = 3000;
  final int selectedBudgetIndex;

  const BudgetCarsListWidget({super.key, required this.selectedBudgetIndex});

  double get _maximumInstallment {
    switch (selectedBudgetIndex) {
      case 0:
        return 1000;
      case 1:
        return 1500;
      case 2:
        return 2000;
      case 3:
        return double.infinity;
      default:
        return 0;
    }
  }

  double? _monthlyInstallment(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized);
  }

  double? _cashPrice(GetBrandCarsDataModel car) {
    final value = car.price?.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    final price = double.tryParse(value ?? '');
    return price != null && price > 0 ? price : null;
  }

  double? _lowestInstallment(GetBrandCarsDataModel car, List<FinancingAdModel> financingOffers) {
    final cashPrice = _cashPrice(car);
    if (cashPrice == null) {
      return car.monthlyInstallment ?? _monthlyInstallment(car.installments);
    }
    final matchingOffers = financingOffers
        .where((offer) => offer.itemCode == null || offer.itemCode == car.itemCode)
        .toList();
    if (matchingOffers.isNotEmpty) {
      return matchingOffers
          .map((offer) => offer.monthlyInstallmentForPrice(
                cashPrice,
                financingFee: _financingFee,
                platesVal: car.paintingsVal ?? 0,
              ))
          .reduce((a, b) => a < b ? a : b);
    }

    return car.monthlyInstallment ?? _monthlyInstallment(car.installments);
  }

  Map<String, dynamic> _toCarMap(GetBrandCarsDataModel car, double monthlyInstallment) {
    final formattedMonthlyInstallment = '${monthlyInstallment.toStringAsFixed(0)} ر.س / شهر';

    return {
      ...car.toMap(),
      'cashPrice': '${car.price ?? '0'} ر.س',
      'installmentPrice': formattedMonthlyInstallment,
      'installments': formattedMonthlyInstallment,
      'monthlyInstallment': monthlyInstallment,
      'isTamaraAvailable': false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.allCarsStatus != current.allCarsStatus ||
          previous.normalFinancingStatus != current.normalFinancingStatus,
      builder: (context, state) {
        final financingOffers = state.normalFinancingStatus.data ?? const <FinancingAdModel>[];
        final cars = (state.allCarsStatus.data ?? [])
            .map((car) => (car: car, installment: _lowestInstallment(car, financingOffers)))
            .where((entry) {
              final installment = entry.installment;
              return installment != null && installment > 0 && installment <= _maximumInstallment;
            })
            .map((entry) => _toCarMap(entry.car, entry.installment!))
            .toList();

        if (state.allCarsStatus.isLoading) {
          return SizedBox(
            height: 150.h,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (cars.isEmpty) {
          return SizedBox(
            height: 150.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined, size: 42.sp, color: Colors.grey),
                SizedBox(height: 8.h),
                const Text('لا توجد سيارات متاحة'),
              ],
            ),
          );
        }

        return SizedBox(
          height: 250.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return HorizontalCarCardWidget(
                car: car,
                heroTag: 'budget_car_image_${HiveMethods.getCarUniqueId(car)}_$index',
              );
            },
          ),
        );
      },
    );
  }
}
