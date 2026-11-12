import 'dart:async';

import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/screen/main_layout.dart';
import 'package:car/features/home/presentation/view/widgets/ad_card_widget.dart';
import 'package:car/features/home/presentation/view/widgets/ads_dot_indicator.dart';
import 'package:car/features/home/presentation/view/widgets/section_title_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AdsSliderWidget extends StatefulWidget {
  const AdsSliderWidget({super.key});

  @override
  State<AdsSliderWidget> createState() => _AdsSliderWidgetState();
}

class _AdsSliderWidgetState extends State<AdsSliderWidget> {
  late final PageController _pageController;

  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _currentPage = 1000;

    _pageController = PageController(initialPage: _currentPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final cubit = context.read<HomeCubit>();

      if (cubit.state.financingAdsStatus.isInitial) {
        cubit.getFinancingAds();
      }
    });

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;

      _currentPage++;

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _onDotTapped(int i, int totalCount) {
    if (totalCount == 0) return;

    final realIndex = _currentPage % totalCount;
    final target = (_currentPage - realIndex) + i;

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onAdTap(FinancingAdModel ad) {
    if (ad.programId != null) {
      context.read<HomeCubit>().getFinancingAds(code: ad.programId.toString());
    } else {
      context.read<HomeCubit>().getFinancingAds();
    }
    MainLayout.tabIndex.value = 1;
  }

  void _showAllAdsSheet(BuildContext context, List<FinancingAdModel> allAds) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.90,
        minChildSize: 0.5,

        builder: (_, controller) => Container(
          padding: EdgeInsets.only(top: 12.h, bottom: 16.h),
          height: 300.h,
          decoration: BoxDecoration(
            color: AppColor.scaffoldColor(ctx),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColor.greyColor(ctx).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocaleKey.bankOffers.tr(),
                      style: AppTextStyle.titleMedium(
                        ctx,
                      ).copyWith(fontWeight: FontWeight.w900, color: AppColor.blackTextColor(ctx)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColor.borderColor(ctx),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 16.sp, color: AppColor.blackTextColor(ctx)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: allAds.length,
                  separatorBuilder: (_, __) => Gap(16.h),
                  itemBuilder: (_, index) {
                    final ad = allAds[index];
                    return SizedBox(
                      height: 230.h,
                      child: AdCardWidget(
                        ad: ad,
                        onTap: () {
                          Navigator.pop(ctx);
                          _onAdTap(ad);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) => previous.financingAdsStatus != current.financingAdsStatus,
      builder: (context, state) {
        if (!state.financingAdsStatus.isSuccess) {
          return const SizedBox.shrink();
        }

        final models = state.financingAdsStatus.data;

        if (models == null || models.isEmpty) {
          return const SizedBox.shrink();
        }
        final seenProgramIds = <int>{};
        final adsList = models.where((ad) {
          final programId = ad.programId;
          if (programId == null) return true;
          return seenProgramIds.add(programId);
        }).toList();

        // Limit slider to max 3 ads
        final displayAds = adsList.take(3).toList();
        final realIndex = _currentPage % displayAds.length;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitleWidget(
              title: AppLocaleKey.bankOffers.tr(),
              onSeeAll: adsList.length >= 3 ? () => _showAllAdsSheet(context, adsList) : null,
            ),
            Gap(10.h),
            SizedBox(
              height: 220.h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: displayAds.length * 2000,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });

                  _startTimer();
                },
                itemBuilder: (context, index) {
                  final ad = displayAds[index % displayAds.length];

                  return AnimatedScale(
                    scale: index == _currentPage ? 1.0 : 0.95,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    child: AdCardWidget(ad: ad, onTap: () => _onAdTap(ad)),
                  );
                },
              ),
            ),
            Gap(10.h),
            AdsDotIndicator(
              count: displayAds.length,
              currentIndex: realIndex,
              activeColor: const Color(0xFFFFC24B),
              onDotTapped: (i) => _onDotTapped(i, displayAds.length),
            ),
          ],
        );
      },
    );
  }
}
