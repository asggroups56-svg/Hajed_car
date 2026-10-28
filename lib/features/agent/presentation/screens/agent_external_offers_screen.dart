import 'dart:typed_data';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/common_methods.dart';
import 'package:car/features/agent/data/model/offer_model.dart';
import 'package:car/features/agent/presentation/cubit/agent_cubit.dart';
import 'package:car/features/agent/presentation/cubit/agent_state.dart';
import 'package:car/features/agent/presentation/screens/car_quotation_preview_screen.dart';
import 'package:car/features/agent/presentation/screens/widget/empty_state_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/error_state_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/loading_state_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/offer_card_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/quotation_chassis_choice_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AgentExternalOffersScreen extends StatefulWidget {
  const AgentExternalOffersScreen({super.key});

  @override
  State<AgentExternalOffersScreen> createState() => _AgentExternalOffersScreenState();
}

class _AgentExternalOffersScreenState extends State<AgentExternalOffersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshOffers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshOffers() async {
    final represNo = int.tryParse(HiveMethods.getUserCode() ?? '1') ?? 1;
    await context.read<AgentCubit>().getExternalOffers(null, represNo, null);
    _searchController.clear();
  }

  void _onSearch(String value) {
    final represNo = int.tryParse(HiveMethods.getUserCode() ?? '1') ?? 1;
    context.read<AgentCubit>().getExternalOffers(value.isEmpty ? null : value, represNo, null);
  }

  Future<void> _showOffer(OfferModel offer, List<OfferModel> offers) async {
    final showChassis = await showQuotationChassisChoiceDialog(context);

    if (showChassis == null || !mounted) return;
    final printResult = await context.read<AgentCubit>().printOfferPrice(
      listNo: offer.listNo,
      listType: 2,
      withChassis: showChassis,
    );
    if (!mounted) return;
    final failure = printResult.fold((failure) => failure, (_) => null);
    if (failure != null) {
      CommonMethods.showToast(message: failure.errMessage, type: ToastType.error);
      return;
    }
    final pdfBytes = printResult.fold((_) => Uint8List(0), (bytes) => bytes);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarQuotationOffersPreviewScreen(
          offerId: offer.listNo,
          offers: offers,
          showChassis: showChassis,
          isExternalOffer: true,
          pdfBytes: pdfBytes,
        ),
      ),
    );
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
          AppLocaleKey.externalQuote.tr(),
          style: AppTextStyle.bodyLarge(
            context,
          ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColor.cardColor(context),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColor.borderColor(context).withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Gap(14.w),
                  Icon(Icons.search_rounded, color: AppColor.greyColor(context), size: 20.sp),
                  Gap(10.w),
                  Expanded(
                    child: CustomFormField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      hintText: AppLocaleKey.search.tr(),
                      hintStyle: AppTextStyle.bodyMedium(
                        context,
                      ).copyWith(color: AppColor.hintColor(context), fontSize: 14.sp),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (_, value, __) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColor.greyColor(context),
                          size: 18.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Gap(12.h),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshOffers,
              color: AppColor.primaryColor(context),
              child: BlocBuilder<AgentCubit, AgentState>(
                builder: (context, state) {
                  if (state.externalOffersStatus.isLoading) {
                    return LoadingState(context: context);
                  }
                  if (state.externalOffersStatus.isFailure) {
                    return ErrorState(
                      message: state.externalOffersStatus.error ?? AppLocaleKey.noData.tr(),
                      onRetry: _refreshOffers,
                    );
                  }

                  final offers = state.externalOffersStatus.data ?? [];
                  if (offers.isEmpty) {
                    return EmptyState(
                      title: AppLocaleKey.no_offers.tr(),
                      subtitle: AppLocaleKey.no_offers_desc.tr(),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return InkWell(
                        onTap: () => _showOffer(offer, offers),
                        borderRadius: BorderRadius.circular(20.r),
                        child: OfferCard(offer: offer),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
