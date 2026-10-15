import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/admin/data/model/cars_response_model.dart';
import 'package:car/features/agent/data/model/agent_models.dart';
import 'package:car/features/agent/presentation/screens/agent_car_details_screen.dart';
import 'package:car/features/agent/presentation/screens/widget/empty_state_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/loading_state_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/reserved_car_card_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/summary_kPIBanner_card_widget.dart';
import 'package:car/features/cart/presentation/view/cubit/cart_cubit.dart';
import 'package:car/features/cart/presentation/view/widget/cancel_confirm_dialog_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AgentMyBookingsScreen extends StatefulWidget {
  const AgentMyBookingsScreen({super.key});

  @override
  State<AgentMyBookingsScreen> createState() => _AgentMyBookingsScreenState();
}

class _AgentMyBookingsScreenState extends State<AgentMyBookingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshBookings() {
    context.read<CartCubit>().loadReservedCars(isAgent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(
        context,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.blackTextColor(context),
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocaleKey.agentClosedDeals.tr(),
          style: AppTextStyle.bodyLarge(
            context,
          ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.w900),
        ),
      ),
      body: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            CommonMethods.showToast(message: state.errorMessage!, type: ToastType.error);
          }
          if (state.cancellationMessage != null && state.cancellationMessage!.isNotEmpty) {
            CommonMethods.showToast(message: state.cancellationMessage!, type: ToastType.success);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return LoadingState(context: context);
          }

          final allReservedCars = state.reservedCars;
          final filteredCars = allReservedCars.where((car) {
            if (_searchQuery.trim().isEmpty) return true;
            final query = _searchQuery.toLowerCase().trim();
            final name = car.itemName?.toLowerCase() ?? '';
            final chassis = car.chassisNo?.toLowerCase() ?? '';
            final lpo = car.lpoNo?.toLowerCase() ?? '';
            final color = car.bodyColor?.toLowerCase() ?? '';
            final customer = car.customerName?.toLowerCase() ?? '';
            return name.contains(query) ||
                chassis.contains(query) ||
                lpo.contains(query) ||
                color.contains(query) ||
                customer.contains(query);
          }).toList();

          final double totalPrice = filteredCars.fold(
            0.0,
            (sum, car) => sum + (car.costPrice ?? 0.0),
          );

          return RefreshIndicator(
            onRefresh: () async => _refreshBookings(),
            color: AppColor.primaryColor(context),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                  child: Column(
                    children: [
                      Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: AppColor.cardColor(context),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: AppColor.borderColor(context).withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Gap(14.w),
                            Icon(
                              Icons.search_rounded,
                              color: AppColor.greyColor(context),
                              size: 20.sp,
                            ),
                            Gap(10.w),
                            Expanded(
                              child: TextFormField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                                style: AppTextStyle.bodyMedium(
                                  context,
                                ).copyWith(color: AppColor.blackTextColor(context)),
                                decoration: InputDecoration(
                                  hintText: AppLocaleKey.agentSearchBookingsHint.tr(),
                                  hintStyle: AppTextStyle.bodyMedium(
                                    context,
                                  ).copyWith(color: AppColor.hintColor(context), fontSize: 13.sp),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppColor.greyColor(context),
                                  size: 18.sp,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      Gap(12.h),
                      SummaryKPIBannerCardWidget(
                        filteredCars: filteredCars,
                        totalPrice: totalPrice,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredCars.isEmpty
                      ? EmptyState(
                          title: AppLocaleKey.agentNoBookingsFound.tr(),
                          subtitle: AppLocaleKey.agentNoBookingsFound.tr(),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                          itemCount: filteredCars.length,
                          itemBuilder: (context, index) {
                            final car = filteredCars[index];
                            return ReservedCarCard(
                              key: ValueKey(car.itemCode ?? index.toString()),
                              car: car,
                              onCancelTap: () => _handleCancelCar(context, car),
                              onDetailsTap: () => _navigateToDetails(context, car),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleCancelCar(BuildContext context, CarModel car) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          CancelConfirmDialog(carName: car.itemName ?? AppLocaleKey.agentUnnamedCar.tr()),
    );

    if (confirmed == true && context.mounted) {
      context.read<CartCubit>().cancelReservation(car);
    }
  }

  void _navigateToDetails(BuildContext context, CarModel car) {
    final agentCar = AgentCar(
      id: car.itemCode ?? '',
      name: car.itemName ?? '',
      brand: '—',
      bodyColor: car.bodyColor ?? '',
      price: car.costPrice ?? 0.0,
      imageUrl: car.imageUrls.isNotEmpty ? car.imageUrls.first : '',
      availability: CarAvailability.reserved,
      year: (car.makeYear ?? 0).toString(),
      mileage: '0',
      chassisNo: car.chassisNo ?? '',
      color: car.bodyColor ?? '',
      itemCode: car.itemCode ?? '',
      itemName: car.itemName ?? '',
      storeCode: car.storeCode ?? '',
      groupCode: car.groupCode?.toString() ?? '',
      colorCode: car.colorCode?.toString(),
      customerName: car.customerName ?? '',
      reservedName: car.reservedName ?? '',
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AgentCarDetailsScreen(car: agentCar)),
    );
  }
}
