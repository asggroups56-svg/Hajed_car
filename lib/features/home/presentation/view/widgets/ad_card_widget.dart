import 'package:car/core/custom_widgets/custom_image/custom_network_image.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AdCardWidget extends StatelessWidget {
  final FinancingAdModel ad;
  final VoidCallback? onTap;

  const AdCardWidget({super.key, required this.ad, this.onTap});

  static const Color _navyTop = Color(0xFF171B3D);
  static const Color _navyBottom = Color(0xFF2C1B54);
  static const Color _gold = Color(0xFFFFC24B);

  double get _firstPct => ad.firstInstallmentPct ?? 0;
  double get _lastPct => ad.lastInstallmentPct ?? 0;
  double get _adminPct => ad.adminFeesPct ?? 0;
  double get _interest => ad.interestRate ?? 0;
  double get _insurancePct => ad.insurancePct ?? 0;
  double get _platesVal => ad.paintingsVal ?? 0;
  int get _year => ad.modelYear ?? ad.makeYear ?? 0;

  String _formattedPrice(BuildContext context) {
    // The plate fee is not subject to VAT, so it is added after the VAT price.
    final price = ad.priceWithVatAndPlates();
    if (price <= 0) return AppLocaleKey.priceOnRequest.tr();
    return NumberFormat('#,##0', context.locale.languageCode).format(price);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          // fallback color while the image loads / if it fails
          color: _navyTop,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ── the ad photo now IS the card background, full-bleed ────
            Positioned.fill(child: _buildCarImage()),

            // ── dark scrim over the photo so text stays legible ────────
            Positioned.fill(child: _buildScrim()),

            _buildGlow(),

            // ── foreground content, on top of the photo + scrim ────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopRow(context),
                  Gap(2.h),
                  _buildHero(context),
                  const Spacer(),
                  _buildStatsRow(context),
                  Gap(10.h),
                  _buildFooter(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarImage() {
    final imageUrl = ad.displayPicUrl;
    if (imageUrl.isEmpty) {
      return const DecoratedBox(decoration: BoxDecoration(color: _navyTop));
    }
    return CustomNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover);
  }

  Widget _buildScrim() {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  _navyTop.withValues(alpha: 0.92),
                  _navyBottom.withValues(alpha: 0.75),
                  _navyBottom.withValues(alpha: 0.15),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [_navyTop.withValues(alpha: 0.85), Colors.transparent],
                stops: const [0.0, 0.45],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlow() {
    return Positioned(
      right: -30.w,
      bottom: 20.h,
      child: IgnorePointer(
        child: Container(
          width: 160.w,
          height: 160.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [_gold.withValues(alpha: 0.15), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            AppLocaleKey.startsFrom.tr(),
            style: AppTextStyle.bodySmall(context).copyWith(
              color: AppColor.whiteColor(context).withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_year > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColor.whiteColor(context).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColor.whiteColor(context).withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              '$_year',
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColor.whiteColor(context),
                fontWeight: FontWeight.w700,
                fontSize: 10.sp,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    final pctLabel = _firstPct <= 0 ? '0' : _firstPct.toStringAsFixed(0);

    return SizedBox(
      width: 0.6.sw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueWithCurrencyIcon(
            text: '${_formattedPrice(context)} ${AppLocaleKey.sar.tr()}',
            textStyle: AppTextStyle.bodyMedium(context).copyWith(
              color: AppColor.whiteColor(context),
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
            ),
          ),
          Gap(2.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${AppLocaleKey.downPayment.tr()} ',
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    color: AppColor.whiteColor(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                  ),
                ),
                TextSpan(
                  text: '$pctLabel%',
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    color: _gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 34.sp,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          if (_lastPct > 0)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                AppLocaleKey.adLastPayment.tr(
                  namedArgs: {'value': _lastPct.toStringAsFixed(0)},
                ),
                style: AppTextStyle.bodySmall(context).copyWith(
                  color: AppColor.whiteColor(context).withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final chips = <Widget>[
      _StatChip(
        value: '${_adminPct.toStringAsFixed(0)}%',
        label: AppLocaleKey.adAdministrativeFees.tr(),
        gold: _gold,
      ),
      _StatChip(
        value: '${_interest.toStringAsFixed(1)}%',
        label: AppLocaleKey.adProfitRate.tr(),
        gold: _gold,
      ),
      if (_insurancePct > 0)
        _StatChip(
          value: '${_insurancePct.toStringAsFixed(1)}%',
          label: AppLocaleKey.adInsurancePct.tr(),
          gold: _gold,
        ),
      if (_platesVal > 0)
        _StatChip(
          value: NumberFormat('#,##0', 'en_US').format(_platesVal),
          label: AppLocaleKey.adPlatesFee.tr(),
          gold: _gold,
        ),
    ];

    return SizedBox(
      width: 0.6.sw,
      child: Row(
        children: [
          for (int i = 0; i < chips.length; i++) ...[
            if (i != 0) Gap(8.w),
            chips[i],
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.directions_car_filled_rounded,
          color: AppColor.whiteColor(context),
          size: 16.sp,
        ),
        Gap(6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocaleKey.adDealerName.tr(),
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColor.whiteColor(context),
                fontWeight: FontWeight.w800,
                fontSize: 11.sp,
              ),
            ),
            Text(
              AppLocaleKey.adDealerSubtitle.tr(),
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColor.whiteColor(context).withValues(alpha: 0.6),
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
        const Spacer(),
        if ((ad.endDate ?? '').isNotEmpty)
          Text(
            AppLocaleKey.adUntil.tr(namedArgs: {'date': ad.endDate ?? ''}),
            style: AppTextStyle.bodySmall(context).copyWith(
              color: AppColor.whiteColor(context).withValues(alpha: 0.6),
              fontSize: 9.sp,
            ),
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color gold;

  const _StatChip({
    required this.value,
    required this.label,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColor.whiteColor(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColor.whiteColor(context).withValues(alpha: 0.14),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyle.bodySmall(context).copyWith(
                color: gold,
                fontWeight: FontWeight.w800,
                fontSize: 12.sp,
              ),
            ),
            Text(
              label,
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColor.whiteColor(context).withValues(alpha: 0.7),
                fontSize: 8.5.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
