import 'package:animate_do/animate_do.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/custom_widgets/custom_loading/custom_loading.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/admin/data/model/cars_response_model.dart';
import 'package:car/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:car/features/admin/presentation/cubit/admin_state.dart';
import 'package:car/features/admin/presentation/screen/car_quotation_preview_screen.dart';
import 'package:car/features/admin/presentation/screen/widgets/car_filter_chips.dart';
import 'package:car/features/admin/presentation/screen/widgets/car_inventory_card.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import 'widgets/empty_state_widget.dart';

class ManageCarsScreen extends StatefulWidget {
  const ManageCarsScreen({super.key});

  @override
  State<ManageCarsScreen> createState() => _ManageCarsScreenState();
}

class _ManageCarsScreenState extends State<ManageCarsScreen> {
  String _selectedFilter = 'available';
  static const Map<String, int> _filterToStatus = {'available': 1, 'reserved': 2};

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().getCarsStatus(_filterToStatus['available']!, null);
    context.read<AdminCubit>().getCarsCountStatus();
    final homeCubit = context.read<HomeCubit>();
    // Always refresh brands and all cars to reflect latest price changes from DB
    homeCubit.getCarsModels();
    homeCubit.fetchAllCars();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;
    setState(() => _selectedFilter = filter);
    context.read<AdminCubit>().getCarsStatus(_filterToStatus[filter]!, null);
  }

  GetBrandCarsDataModel _toBrandCar(CarModel car) {
    final homeCubit = context.read<HomeCubit>();

    final brandList = homeCubit.state.brands;
    String brandName = '';
    for (final b in brandList) {
      if (b.groupCode == car.groupCode) {
        brandName = b.groupName;
        break;
      }
    }

    return GetBrandCarsDataModel(
      groupCode: car.groupCode ?? 0,
      groupName: brandName,
      grName: brandName.isNotEmpty ? "$brandName - ${car.itemName ?? ''}" : (car.itemName ?? ''),
      groupParent: 0,
      groupLevel: 0,
      price: car.salePrice?.toStringAsFixed(0),
      itemCode: car.itemCode ?? '',
      itemType: car.carType ?? 0,
      itemName: car.itemName ?? '',
      groupCode1: car.groupCode ?? 0,
      storeCode: car.storeCode ?? '',
      carStatus: car.carStatus ?? 0,
      carType: car.carType ?? 0,
      chassisNo: car.chassisNo ?? '',
      bodyColor: car.bodyColor ?? '',
      transmission: car.transmission ?? 0,
      cylinder: '',
      powerHourse: '',
      fuelCapacity: '',
      fuelType: car.fuelType ?? '',
      seatNo: 0,
      doorNo: 0,
      addType: 0,
      colorCode: car.colorCode ?? 0,
      makeYear: car.makeYear ?? 0,
      notifyType: 0,
      supplierCd: 0,
      buyDate: '',
      trNo: 0,
      reasonId: 0,
      mobileShow: car.mobileShow ?? false,
      carImage: car.imageUrls.isNotEmpty ? car.imageUrls.first : null,
      extraImages: car.imageUrls,
      color: car.bodyColor ?? '',
      customerName: car.customerName,
      reservedName: car.reservedName,
      paintingsVal: car.paintingsVal,
    );
  }

  void _showPrintDialog(GetBrandCarsDataModel car) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CarQuotationPreviewScreen(car: car)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(
        context,
        appBarColor: AppColor.scaffoldColor(context),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: null,
        centerTitle: true,
        title: Text(
          AppLocaleKey.cars.tr(),
          style: AppTextStyle.titleMedium(
            context,
          ).copyWith(fontWeight: FontWeight.w900, fontSize: 20.sp),
        ),
        actions: [
          // IconButton(
          //   onPressed: () => Navigator.pushNamed(context, RoutesName.addCar),
          //   icon: Container(
          //     padding: EdgeInsets.all(6.w),
          //     decoration: BoxDecoration(
          //       color: AppColor.primaryColor(context).withValues(alpha: 0.1),
          //       borderRadius: BorderRadius.circular(10.r),
          //     ),
          //     child: Center(
          //       child: Icon(Icons.add_rounded, color: AppColor.primaryColor(context), size: 20.sp),
          //     ),
          //   ),
          // ),
          Gap(10.w),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          final carsStatus = state.getCarsStatus;

          final List<GetBrandCarsDataModel> allCars =
              carsStatus.isSuccess && carsStatus.data != null
              ? carsStatus.data!.data.map(_toBrandCar).toList()
              : [];

          final List<GetBrandCarsDataModel> cars = _searchQuery.isEmpty
              ? allCars
              : allCars.where((car) {
                  final query = _searchQuery.toLowerCase();
                  return car.itemName.toLowerCase().contains(query) ||
                      car.makeYear.toString().contains(query) ||
                      car.chassisNo.toLowerCase().contains(query) ||
                      car.storeCode.toLowerCase().contains(query) ||
                      (car.price ?? '').toLowerCase().contains(query);
                }).toList();

          return Column(
            children: [
              // FleetStatsRow(stats: stats),
              Gap(10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.cardColor(context),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColor.borderColor(context).withValues(alpha: 0.5)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: AppLocaleKey.searchCarHint.tr(),
                      hintStyle: AppTextStyle.hintStyle(
                        context,
                      ).copyWith(color: AppColor.hintColor(context)),
                      prefixIcon: Icon(Icons.search_rounded, color: AppColor.hintColor(context)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, color: AppColor.hintColor(context)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    ),
                  ),
                ),
              ),
              Gap(10.h),
              CarFilterChips(selectedFilter: _selectedFilter, onFilterChanged: _onFilterChanged),
              Gap(4.h),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: carsStatus.isLoading
                      ? const Center(key: ValueKey('loading'), child: CustomLoading())
                      : carsStatus.isFailure
                      ? Center(
                          key: const ValueKey('error'),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 48.sp,
                                color: AppColor.redColor(context),
                              ),
                              Gap(12.h),
                              Text(
                                carsStatus.error ?? AppLocaleKey.tryAgain.tr(),
                                style: AppTextStyle.bodyMedium(context),
                                textAlign: TextAlign.center,
                              ),
                              Gap(16.h),
                              TextButton(
                                onPressed: () => context.read<AdminCubit>().getCarsStatus(
                                  _filterToStatus[_selectedFilter]!,
                                  null,
                                ),
                                child: Text(AppLocaleKey.tryAgain.tr()),
                              ),
                            ],
                          ),
                        )
                      : cars.isEmpty
                      ? const EmptyState(key: ValueKey('empty'))
                      : ListView.separated(
                          key: ValueKey('${_selectedFilter}_$_searchQuery'),
                          padding: EdgeInsets.all(16.w),
                          physics: const BouncingScrollPhysics(),
                          itemCount: cars.length,
                          separatorBuilder: (_, _) => Gap(10.h),
                          itemBuilder: (context, i) {
                            final car = cars[i];
                            return FadeInUp(
                              delay: Duration(milliseconds: i * 40),
                              duration: const Duration(milliseconds: 300),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.carDetailsScreen,
                                    arguments: {
                                      'car': car,
                                      'heroTag': 'admin_car_image_${car.itemCode}',
                                      'isFromAdmin': true,
                                    },
                                  );
                                },
                                child: CarInventoryCard(
                                  car: car,
                                  onEdit: () {},
                                  onWhatsApp: () {},
                                  onDelete: () {},
                                  onPrint: () => _showPrintDialog(car),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
