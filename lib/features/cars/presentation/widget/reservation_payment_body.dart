import 'dart:convert';
import 'dart:io';

import 'package:car/core/custom_widgets/buttons/custom_button.dart';
import 'package:car/core/custom_widgets/custom_form_field/custom_form_field.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/network/contants.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/cars/data/model/brand_model.dart';
import 'package:car/features/cars/presentation/widget/premium_credit_card_form.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:moyasar/moyasar.dart';
import 'package:pay/pay.dart' as pay_pkg;

class ReservationPaymentBody extends StatelessWidget {
  final GetBrandCarsDataModel car;
  final double totalPrice;
  final double depositAmount;
  final bool isLoading;
  final void Function(dynamic result, {required bool isApplePay}) onPaymentResult;

  const ReservationPaymentBody({
    super.key,
    required this.car,
    required this.totalPrice,
    required this.depositAmount,
    required this.isLoading,
    required this.onPaymentResult,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    // NOTE: The Apple Pay merchant name (label) MUST exactly match the name
    // registered in your Apple Developer account under your Merchant ID.
    // Using a mismatch here triggers Guideline 4.9 rejection.
    // Registered merchant name: Hajed Trading Company
    // (update this to match your exact Apple Pay merchant registration)
    const merchantName = 'Hajed Trading Company';
    // IMPORTANT: Set callbackUrl so ThreeDSWebView can detect 3DS completion.
    // The WebView watches for a redirect to this host — must match what Moyasar
    // sends after 3DS. Keep in sync with the Moyasar dashboard callback setting.

    final paymentConfig = PaymentConfig(
      publishableApiKey: Constants.moyasarPublishableKey,
      amount: (depositAmount * 100).toInt(),
      description: isArabic
          ? 'عربون حجز سيارة ${car.itemName}'
          : 'Car reservation deposit - ${car.itemName}',
      metadata: {'item_code': car.itemCode, 'chassis_no': car.chassisNo},
      creditCard: CreditCardConfig(saveCard: false, manual: false),
      applePay: ApplePayConfig(
        merchantId: Constants.applePayMerchantId,
        label: merchantName,
        manual: false,
        saveCard: false,
      ),
      // supportedNetworks controls which CARD networks are accepted.
      // Apple Pay, Samsung Pay and STC Pay are separate widgets — not listed here.
      supportedNetworks: const [
        PaymentNetwork.mada,
        PaymentNetwork.visa,
        PaymentNetwork.masterCard,
        PaymentNetwork.amex,
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PaymentStepIndicator(),
        Gap(24.h),
        _CarSummaryCard(car: car, totalPrice: totalPrice),
        Gap(24.h),
        _DepositBanner(depositAmount: depositAmount, isArabic: isArabic),
        Gap(24.h),
        if (isLoading)
          _LoadingIndicator(isArabic: isArabic)
        else
          _PaymentMethodSelector(
            config: paymentConfig,
            isArabic: isArabic,
            onPaymentResult: onPaymentResult,
          ),
        Gap(24.h),
        _GuaranteeBanner(),
        Gap(60.h),
      ],
    );
  }
}

// ─── Payment Method Selector ─────────────────────────────────────────────────

enum _PaymentTab { creditCard, stcPay, applePay }

class _PaymentMethodSelector extends StatefulWidget {
  final PaymentConfig config;
  final bool isArabic;
  final void Function(dynamic result, {required bool isApplePay}) onPaymentResult;

  const _PaymentMethodSelector({
    required this.config,
    required this.isArabic,
    required this.onPaymentResult,
  });

  @override
  State<_PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<_PaymentMethodSelector> {
  late _PaymentTab _selected;

  @override
  void initState() {
    super.initState();
    // Default safely to card first; if Apple Pay is verified available, switch to it
    _selected = _PaymentTab.creditCard;
    if (Platform.isIOS) {
      _checkApplePayAvailability();
    }
  }

  Future<void> _checkApplePayAvailability() async {
    try {
      final networks = widget.config.supportedNetworks.map((e) => e.toJson()).toList();
      final applePayConfig = widget.config.applePay;
      final data = <String, dynamic>{
        'merchantIdentifier': applePayConfig?.merchantId,
        'displayName': applePayConfig?.label,
        'merchantCapabilities': applePayConfig?.merchantCapabilities,
        'supportedNetworks': networks,
        'countryCode': 'SA',
        'currencyCode': 'SAR',
      };
      if (applePayConfig?.supportedCountries != null &&
          applePayConfig!.supportedCountries.isNotEmpty) {
        data['supportedCountries'] = applePayConfig.supportedCountries;
      }
      final configJson = jsonEncode({
        'provider': 'apple_pay',
        'data': data,
      });
      final payClient = pay_pkg.Pay({
        pay_pkg.PayProvider.apple_pay: pay_pkg.PaymentConfiguration.fromJsonString(configJson),
      });
      final canPay = await payClient.userCanPay(pay_pkg.PayProvider.apple_pay);
      if (mounted && canPay) {
        setState(() {
          _selected = _PaymentTab.applePay;
        });
      }
    } catch (_) {
      // Keep creditCard selected on error
    }
  }

  List<_TabItem> _buildTabs() {
    final isAr = widget.isArabic;
    return [
      if (Platform.isIOS)
        const _TabItem(
          tab: _PaymentTab.applePay,
          label: 'Apple Pay',
          icon: Icons.apple_rounded,
          color: Color(0xFF1C1C1E),
        ),
      const _TabItem(
        tab: _PaymentTab.stcPay,
        label: 'STC Pay',
        icon: Icons.account_balance_wallet_rounded,
        color: Color(0xFF7B2FBE),
      ),
      _TabItem(
        tab: _PaymentTab.creditCard,
        label: isAr ? 'بطاقة' : 'Card',
        icon: Icons.credit_card_rounded,
        color: const Color(0xFF0D47A1),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _buildTabs();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Tab Selector ──
        Container(
          decoration: BoxDecoration(
            color: AppColor.cardColor(context),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColor.borderColor(context).withValues(alpha: 0.5)),
          ),
          padding: EdgeInsets.all(6.w),
          child: Row(
            children: tabs.map((item) {
              final isActive = _selected == item.tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selected = item.tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: isActive ? item.color : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: item.color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        item.tab == _PaymentTab.stcPay
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.asset(
                                  'assets/images/stc_pay.jpeg',
                                  width: 24.w,
                                  height: 16.h,
                                  errorBuilder: (c, e, s) => Icon(
                                    item.icon,
                                    size: 18.sp,
                                    color: isActive
                                        ? AppColor.whiteColor(context)
                                        : AppColor.greyColor(context),
                                  ),
                                ),
                              )
                            : Icon(
                                item.icon,
                                size: 18.sp,
                                color: isActive
                                    ? AppColor.whiteColor(context)
                                    : AppColor.greyColor(context),
                              ),
                        Gap(4.h),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            color: isActive
                                ? AppColor.whiteColor(context)
                                : AppColor.greyColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Gap(20.h),
        // ── Content Area ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_selected) {
      case _PaymentTab.applePay:
        return KeyedSubtree(
          key: const ValueKey('applePay'),
          child: _DirectApplePayButton(
            config: widget.config,
            isArabic: widget.isArabic,
            onSwitchToCard: () => setState(() => _selected = _PaymentTab.creditCard),
            onPaymentResult: widget.onPaymentResult,
          ),
        );
      case _PaymentTab.stcPay:
        return KeyedSubtree(
          key: const ValueKey('stcPay'),
          child: _STCPayForm(
            config: widget.config,
            isArabic: widget.isArabic,
            onPaymentResult: widget.onPaymentResult,
          ),
        );
      case _PaymentTab.creditCard:
        return KeyedSubtree(
          key: const ValueKey('creditCard'),
          child: PremiumCreditCardForm(
            config: widget.config,
            onPaymentResult: widget.onPaymentResult,
            isArabic: widget.isArabic,
          ),
        );
    }
  }
}

class _TabItem {
  final _PaymentTab tab;
  final String label;
  final IconData icon;
  final Color color;
  const _TabItem({required this.tab, required this.label, required this.icon, required this.color});
}

/// Custom STC Pay form that works inline (no Scaffold).
/// Replicates the logic of moyasar's STCPay widget without wrapping in Scaffold.
class _STCPayForm extends StatefulWidget {
  final PaymentConfig config;
  final bool isArabic;
  final void Function(dynamic result, {required bool isApplePay}) onPaymentResult;

  const _STCPayForm({required this.config, required this.isArabic, required this.onPaymentResult});

  @override
  State<_STCPayForm> createState() => _STCPayFormState();
}

class _STCPayFormState extends State<_STCPayForm> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isValid = false;
  bool _isSubmitting = false;

  static const Color _purple = Color(0xFF470793);
  static const Color _lightPurple = Color(0xFFE3D3F6);

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    setState(() => _isValid = digits.length == 10 && digits.startsWith('05'));
  }

  Future<void> _pay() async {
    if (!_isValid || _isSubmitting) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isSubmitting = true);

    String digits = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

    // Convert local format 05xxxxxxxx or 5xxxxxxxx to international format 9665xxxxxxxx
    if (digits.startsWith('05')) {
      digits = '966' + digits.substring(1);
    } else if (digits.startsWith('5')) {
      digits = '966' + digits;
    }

    final request = PaymentRequest(widget.config, StcRequestSource(mobile: digits));

    try {
      final result = await Moyasar.pay(
        apiKey: widget.config.publishableApiKey,
        paymentRequest: request,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (result is! PaymentResponse || result.status != PaymentStatus.initiated) {
        widget.onPaymentResult(result, isApplePay: false);
        return;
      }

      final txUrl = (result.source as StcResponseSource).transactionUrl ?? '';
      if (txUrl.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                title: Text(widget.isArabic ? 'رمز التحقق المرسل اليك' : 'STC Pay - OTP'),
              ),
              body: OtpComponent(
                transactionUrl: txUrl,
                onPaymentResult: (r) => widget.onPaymentResult(r, isApplePay: false),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        widget.onPaymentResult(ApiError(e.toString()), isApplePay: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.borderColor(context).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: Image.asset(
                  'assets/images/stc_pay.jpeg',
                  width: 38.w,
                  height: 24.h,
                  errorBuilder: (c, e, s) =>
                      Icon(Icons.account_balance_wallet_rounded, color: _purple, size: 22.sp),
                ),
              ),
              Gap(10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STC Pay',
                    style: AppTextStyle.titleMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.w900, color: _purple, fontSize: 15.sp),
                  ),
                  Text(
                    isAr
                        ? 'أدخل رقم الجوال المسجّل في STC Pay'
                        : 'Enter your STC Pay mobile number',
                    style: AppTextStyle.bodySmall(
                      context,
                    ).copyWith(color: AppColor.greyColor(context), fontSize: 10.sp),
                  ),
                ],
              ),
            ],
          ),
          Gap(20.h),

          // Phone input
          CustomFormField(
            radius: 12.r,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            hintText: '05X XXX XXXX',
            title: isAr ? 'رقم الجوال' : 'Mobile Number',
            maxLength: 10,
            validator: (_) {
              if (_phoneController.text.isEmpty) {
                return isAr ? 'يرجى ادخال رقم الجوال' : 'Please enter your mobile number';
              } else if (!_isValid) {
                return isAr ? 'يرجى ادخال رقم جوال صحيح' : 'Please enter a valid mobile number';
              } else if (_phoneController.text.length < 10) {
                return isAr ? 'رقم الجوال يجب أن يكون 10 أرقام' : 'Phone number must be 10 digits';
              } else if (!_phoneController.text.startsWith('05')) {
                return isAr ? 'رقم الجوال يجب أن يبدأ بـ 05' : 'Phone number must start with 05';
              } else if (!RegExp(r'^[0-9]+$').hasMatch(_phoneController.text)) {
                return isAr ? 'يرجى ادخال رقم جوال صحيح' : 'Please enter a valid mobile number';
              }
              return null;
            },
            prefixIcon: Icon(
              Icons.phone_iphone_rounded,
              color: _isValid ? _purple : AppColor.greyColor(context),
            ),
            suffixIcon: _isValid
                ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                : null,
          ),
          Gap(20.h),

          // Pay button
          SizedBox(
            height: 52.h,
            child: CustomButton(
              onPressed: _isValid && !_isSubmitting ? _pay : null,
              borderRadius: BorderRadius.circular(12.r),
              color: _isValid ? _purple : _lightPurple,

              child: _isSubmitting
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColor.whiteColor(context),
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isAr ? 'ادفع  ' : 'Pay  ',
                          style: AppTextStyle.bodyMedium(context).copyWith(
                            color: _isValid ? AppColor.whiteColor(context) : _purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ValueWithCurrencyIcon(
                          text:
                              '${(widget.config.amount / 100).toStringAsFixed(2)} ${isAr ? 'ر.س' : 'SAR'}',
                          textStyle: AppTextStyle.bodyMedium(context).copyWith(
                            color: _isValid ? AppColor.whiteColor(context) : _purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStepIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepTab(label: AppLocaleKey.payment.tr(), color: const Color(0xFF0D47A1)),
        _StepTab(label: AppLocaleKey.addInfo.tr(), color: const Color(0xFF2E7D32)),
      ],
    );
  }
}

class _StepTab extends StatelessWidget {
  final String label;
  final Color color;
  const _StepTab({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          Gap(8.h),
          Container(
            height: 3.h,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2.r)),
          ),
        ],
      ),
    );
  }
}

class _CarSummaryCard extends StatelessWidget {
  final GetBrandCarsDataModel car;
  final double totalPrice;
  const _CarSummaryCard({required this.car, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.borderColor(context).withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColor.blackColor(context).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF0D47A1), size: 24.sp),
              Gap(8.w),
              ValueWithCurrencyIcon(
                text: '${totalPrice.toStringAsFixed(2)} ${AppLocaleKey.sar.tr()}',
                textStyle: AppTextStyle.bodyMedium(
                  context,
                ).copyWith(color: const Color(0xFF0D47A1), fontWeight: FontWeight.w900),
              ),
            ],
          ),
          Gap(12.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        car.itemName,
                        style: AppTextStyle.bodyMedium(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        car.makeYear.toString(),
                        style: AppTextStyle.bodySmall(
                          context,
                        ).copyWith(color: AppColor.greyColor(context)),
                      ),
                    ],
                  ),
                ),
                Gap(12.w),
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.scaffoldColor(context),
                    border: Border.all(color: AppColor.borderColor(context).withValues(alpha: 0.5)),
                  ),
                  padding: EdgeInsets.all(4.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: _BrandLogo(car: car),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  final GetBrandCarsDataModel car;
  const _BrandLogo({required this.car});

  @override
  Widget build(BuildContext context) {
    final brandName = car.groupName.toLowerCase();
    String? logoPath;
    for (final b in BrandModel.brands) {
      if (b.name.toLowerCase() == brandName && b.logo.isNotEmpty) {
        logoPath = b.logo;
        break;
      }
    }
    if (logoPath != null && logoPath.isNotEmpty) {
      return Image.asset(
        logoPath,
        fit: BoxFit.contain,
        errorBuilder: (c, e, s) => Icon(
          Icons.directions_car_filled_rounded,
          color: AppColor.primaryColor(context),
          size: 20.sp,
        ),
      );
    }
    return Icon(
      Icons.directions_car_filled_rounded,
      color: AppColor.primaryColor(context),
      size: 20.sp,
    );
  }
}

class _DepositBanner extends StatelessWidget {
  final double depositAmount;
  final bool isArabic;
  const _DepositBanner({required this.depositAmount, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor(context),
            AppColor.primaryColor(context).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColor.whiteColor(context), size: 20.sp),
          Gap(10.w),
          ValueWithCurrencyIcon(
            text: isArabic
                ? 'مبلغ العربون: ${depositAmount.toInt()} ${AppLocaleKey.sar.tr()}'
                : 'Deposit Amount: ${depositAmount.toInt()} SAR',
            textStyle: AppTextStyle.bodyMedium(
              context,
            ).copyWith(color: AppColor.whiteColor(context), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  final bool isArabic;
  const _LoadingIndicator({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColor.primaryColor(context)),
            Gap(16.h),
            Text(
              isArabic ? 'جارٍ معالجة الدفع...' : 'Processing payment...',
              style: AppTextStyle.bodyMedium(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuaranteeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_rounded, color: const Color(0xFF2E7D32), size: 24.sp),
          Gap(12.w),
          Expanded(
            child: Text(
              AppLocaleKey.about.tr(),
              style: AppTextStyle.bodySmall(
                context,
              ).copyWith(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Direct Apple Pay Button with Fallback ───────────────────────────────────

class _DirectApplePayButton extends StatefulWidget {
  final PaymentConfig config;
  final bool isArabic;
  final VoidCallback? onSwitchToCard;
  final void Function(dynamic result, {required bool isApplePay}) onPaymentResult;

  const _DirectApplePayButton({
    required this.config,
    required this.isArabic,
    this.onSwitchToCard,
    required this.onPaymentResult,
  });

  @override
  State<_DirectApplePayButton> createState() => _DirectApplePayButtonState();
}

class _DirectApplePayButtonState extends State<_DirectApplePayButton> {
  bool _isProcessing = false;

  String _buildPaymentConfig() {
    final networks = widget.config.supportedNetworks.map((e) => e.toJson()).toList();
    final applePayConfig = widget.config.applePay;
    final data = <String, dynamic>{
      'merchantIdentifier': applePayConfig?.merchantId,
      'displayName': applePayConfig?.label,
      'merchantCapabilities': applePayConfig?.merchantCapabilities,
      'supportedNetworks': networks,
      'countryCode': 'SA',
      'currencyCode': 'SAR',
    };
    if (applePayConfig?.supportedCountries != null &&
        applePayConfig!.supportedCountries.isNotEmpty) {
      data['supportedCountries'] = applePayConfig.supportedCountries;
    }
    return jsonEncode({
      'provider': 'apple_pay',
      'data': data,
    });
  }

  Future<void> _onApplePayResult(Map<String, dynamic> result) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final token = result['token'];
      if (token == null || (token as String).isEmpty) {
        widget.onPaymentResult(UnprocessableTokenError(), isApplePay: true);
        return;
      }

      final source = ApplePayPaymentRequestSource(
        token,
        widget.config.applePay!.manual,
        widget.config.applePay!.saveCard,
      );
      final paymentRequest = PaymentRequest(widget.config, source);
      final payResult = await Moyasar.pay(
        apiKey: widget.config.publishableApiKey,
        paymentRequest: paymentRequest,
      );

      widget.onPaymentResult(payResult, isApplePay: true);
    } catch (e) {
      widget.onPaymentResult(ApiError(e.toString()), isApplePay: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildFallbackUI(BuildContext context) {
    final isAr = widget.isArabic;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.borderColor(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.apple_rounded,
              size: 32.sp,
              color: AppColor.darkTextColor(context),
            ),
          ),
          Gap(12.h),
          Text(
            isAr
                ? 'Apple Pay غير متوفر أو غير مفعّل على هذا الجهاز'
                : 'Apple Pay is not set up on this device',
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColor.darkTextColor(context),
            ),
          ),
          Gap(6.h),
          Text(
            isAr
                ? 'يرجى إضافة بطاقة إلى تطبيق المحفظة (Wallet) من إعدادات الجهاز، أو إتمام الحجز مباشرة عبر البطاقة البنكية.'
                : 'Please add a card to Apple Wallet in device Settings, or pay directly using a Credit/Debit Card.',
            textAlign: TextAlign.center,
            style: AppTextStyle.bodySmall(context).copyWith(
              color: AppColor.greyColor(context),
              height: 1.4,
            ),
          ),
          Gap(16.h),
          CustomButton(
            height: 46.h,
            width: double.infinity,
            onPressed: widget.onSwitchToCard ?? () {},
            text: isAr ? 'الدفع بالبطاقة البنكية' : 'Pay with Credit / Debit Card',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return SizedBox(
        height: 54.h,
        child: Center(child: CircularProgressIndicator(color: AppColor.primaryColor(context))),
      );
    }

    return pay_pkg.ApplePayButton(
      paymentConfiguration: pay_pkg.PaymentConfiguration.fromJsonString(
        _buildPaymentConfig(),
      ),
      paymentItems: [
        pay_pkg.PaymentItem(
          label: widget.config.applePay!.label,
          amount: (widget.config.amount / 100).toStringAsFixed(2),
          status: pay_pkg.PaymentItemStatus.final_price,
        ),
      ],
      type: pay_pkg.ApplePayButtonType.buy,
      style: pay_pkg.ApplePayButtonStyle.black,
      width: double.infinity,
      height: 54.h,
      onPaymentResult: _onApplePayResult,
      loadingIndicator: Center(
        child: CircularProgressIndicator(color: AppColor.primaryColor(context)),
      ),
      onError: (error) {
        debugPrint('Apple Pay error/dismissed: $error');
      },
      childOnError: _buildFallbackUI(context),
    );
  }
}
