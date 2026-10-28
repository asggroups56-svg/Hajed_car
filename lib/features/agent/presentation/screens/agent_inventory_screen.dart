import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/services/services_locator.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/admin/data/model/cars_response_model.dart';
import 'package:car/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:car/features/admin/presentation/cubit/admin_state.dart';
import 'package:car/features/agent/data/model/agent_models.dart';
import 'package:car/features/agent/presentation/screens/agent_car_details_screen.dart';
import 'package:car/features/agent/presentation/screens/widget/car_list_card_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/custom_header_agent_inventory_widget.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AgentInventoryScreen extends StatefulWidget {
  const AgentInventoryScreen({super.key});

  @override
  State<AgentInventoryScreen> createState() => AgentInventoryScreenState();
}

class AgentInventoryScreenState extends State<AgentInventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void refresh() {
    final status = _tabController.index + 1;
    context.read<AdminCubit>().getCarsStatus(status, null);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
    final homeCubit = context.read<HomeCubit>();
    if (homeCubit.state.brands.isEmpty) {
      homeCubit.getCarsModels();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      refresh();
    }
  }

  AgentCar _mapToAgentCar(CarModel car, {required int tabStatus}) {
    final homeCubit = context.read<HomeCubit>();
    final brandList = homeCubit.state.brands;
    String brandName = '';
    for (final b in brandList) {
      if (b.groupCode == car.groupCode) {
        brandName = b.groupName;
        break;
      }
    }

    CarAvailability availability;
    final int statusVal = (car.carStatus != null && car.carStatus! > 0)
        ? car.carStatus!
        : tabStatus;
    switch (statusVal) {
      case 1:
        availability = CarAvailability.available;
        break;
      case 2:
        availability = CarAvailability.reserved;
        break;
      case 3:
        availability = CarAvailability.sold;
        break;
      default:
        availability = CarAvailability.available;
    }
    final double basePrice = car.salePrice ?? car.costPrice ?? 0.0;
    final double vatPercentage =
        double.tryParse(HiveMethods.getVatNumber()?.toString() ?? '') ?? 15.0;
    final double priceWithVat = basePrice * (1 + vatPercentage / 100);
    return AgentCar(
      id: car.itemCode ?? '',
      name: car.itemName ?? '',
      brand: brandName.isNotEmpty ? brandName : priceWithVat.toString(),
      price: car.salePrice ?? car.costPrice ?? 0.0,
      imageUrl: car.imageUrls.isNotEmpty ? car.imageUrls.first : '',
      availability: availability,
      year: car.makeYear?.toString() ?? '—',
      mileage: car.chassisNo ?? '—',
      color: car.color ?? '—',
      bodyColor: car.bodyColor ?? '—',
      itemCode: car.itemCode ?? '',
      itemName: car.itemName ?? '',
      chassisNo: car.chassisNo ?? '',
      storeCode: car.storeCode ?? '',
      groupCode: car.groupCode?.toString() ?? '',
      colorCode: car.colorCode?.toString(),
      customerName: car.customerName ?? '',
      reservedName: car.reservedName ?? '',
      paintingsVal: car.paintingsVal,
      specificName: car.specificName,
      luxury: car.Luxury,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AdminCubit>(),
      child: Scaffold(
        backgroundColor: AppColor.scaffoldColor(context),
        body: Column(
          children: [
            CustomHeaderAgentInventoryWidget(tabController: _tabController),
            // Fixed Search Bar
            Container(
              color: AppColor.scaffoldColor(context),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.cardColor(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColor.borderColor(context).withValues(alpha: 0.5)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: context.locale.languageCode == 'ar'
                        ? 'البحث عن سيارة (الاسم، الماركة...)'
                        : 'Search car (name, brand...)',
                    hintStyle: AppTextStyle.hintStyle(
                      context,
                    ).copyWith(color: AppColor.hintColor(context)),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColor.hintColor(context)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: AppColor.hintColor(context)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<AdminCubit, AdminState>(
                builder: (context, state) {
                  final status = state.getCarsStatus;

                  if (status.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (status.isFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48.sp,
                            color: AppColor.redColor(context),
                          ),
                          Gap(12.h),
                          Text(status.error ?? 'حدث خطأ ما', style: AppTextStyle.bodyMedium(context)),
                          Gap(16.h),
                          TextButton(
                            onPressed: refresh,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  final carModels = status.data?.data ?? [];
                  final int tabStatus = _tabController.index + 1;
                  var agentCars = carModels
                      .map((car) => _mapToAgentCar(car, tabStatus: tabStatus))
                      .toList();

                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    agentCars = agentCars.where((car) {
                      return car.name.toLowerCase().contains(query) ||
                          car.brand.toLowerCase().contains(query) ||
                          car.year.toLowerCase().contains(query) ||
                          car.chassisNo.toLowerCase().contains(query);
                    }).toList();
                  }

                  return TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildList(
                        agentCars.where((c) => c.availability == CarAvailability.available).toList(),
                      ),
                      _buildList(
                        agentCars.where((c) => c.availability == CarAvailability.reserved).toList(),
                      ),
  
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<AgentCar> list) {
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => refresh(),
        color: AppColor.primaryColor(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 0.5.sh,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_filled_outlined,
                    size: 48.sp,
                    color: AppColor.hintColor(context),
                  ),
                  Gap(12.h),
                  Text(
                    AppLocaleKey.agentNoDataAvailable.tr(),
                    style: AppTextStyle.bodyMedium(
                      context,
                    ).copyWith(color: AppColor.hintColor(context), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => refresh(),
      color: AppColor.primaryColor(context),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 40.h),
        itemCount: list.length,
        itemBuilder: (_, i) => CarListCard(
          car: list[i],
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AgentCarDetailsScreen(car: list[i])),
            );
            if (mounted) {
              refresh();
            }
          },
        ),
      ),
    );
  }
}
