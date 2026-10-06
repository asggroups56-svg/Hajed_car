import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

/// Legal disclosure widget required by App Store Guideline 3.2.1(viii).
///
/// Apple requires that apps facilitating loan/credit applications for
/// multiple providers must:
/// 1. Disclose all financial institution partners upfront.
/// 2. Clarify the app's role (facilitator, not lender).
/// 3. Provide a link to terms & conditions and privacy policy.
/// 4. Inform the user their data will be shared with partners.
class FinancingLegalDisclosureWidget extends StatefulWidget {
  /// Called when the user checks/unchecks the consent checkbox.
  final ValueChanged<bool>? onConsentChanged;

  /// Whether to show the consent checkbox (required before submitting).
  final bool showConsentCheckbox;

  const FinancingLegalDisclosureWidget({
    super.key,
    this.onConsentChanged,
    this.showConsentCheckbox = true,
  });

  @override
  State<FinancingLegalDisclosureWidget> createState() =>
      _FinancingLegalDisclosureWidgetState();
}

class _FinancingLegalDisclosureWidgetState
    extends State<FinancingLegalDisclosureWidget> {
  bool _isExpanded = false;
  bool _consented = false;

  /// Update this list with your actual licensed financial institution partners.
  static const List<String> _partnerBanks = [
    'Al Rajhi Bank',
    'Riyad Bank',
    'Saudi National Bank (SNB)',
    'Banque Saudi Fransi',
    'Arab National Bank',
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColor.primaryColor(context).withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header (always visible) ───
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18.sp,
                    color: AppColor.primaryColor(context),
                  ),
                  Gap(8.w),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'إفصاح قانوني — خدمة التمويل'
                          : 'Legal Disclosure — Financing Service',
                      style: AppTextStyle.bodySmall(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColor.primaryColor(context),
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18.sp,
                    color: AppColor.greyColor(context),
                  ),
                ],
              ),
            ),
          ),

          // ─── Expandable Body ───
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildBody(context, isArabic),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),

          // ─── Consent Checkbox (always visible if enabled) ───
          if (widget.showConsentCheckbox) ...[
            Divider(height: 1, color: AppColor.dividerColor(context)),
            _buildConsentRow(context, isArabic),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isArabic) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 16.h, color: AppColor.dividerColor(context)),

          // Role clarification
          _SectionText(
            text: isArabic
                ? 'هاجد للسيارات هي وسيط تمويل مرخص ولا تُعدّ جهة إقراض. يتم تقديم طلب التمويل نيابةً عنك إلى البنوك والمؤسسات المالية الشريكة المرخصة من قِبل البنك المركزي السعودي (ساما).'
                : 'Hajed Cars is a licensed financing intermediary and is NOT a lender. Your loan application is submitted on your behalf to licensed partner banks and financial institutions regulated by the Saudi Central Bank (SAMA).',
          ),
          Gap(10.h),

          // Partner banks
          Text(
            isArabic ? 'الشركاء الماليون:' : 'Financial Partners:',
            style: AppTextStyle.bodySmall(context).copyWith(
              fontWeight: FontWeight.w700,
              color: AppColor.blackTextColor(context),
            ),
          ),
          Gap(6.h),
          ..._partnerBanks.map(
            (bank) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: AppTextStyle.bodySmall(context)
                        .copyWith(color: AppColor.primaryColor(context)),
                  ),
                  Expanded(
                    child: Text(
                      bank,
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: AppColor.blackTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap(10.h),

          // Data sharing notice
          _SectionText(
            text: isArabic
                ? 'بتقديم هذا الطلب، فإنك توافق على مشاركة بياناتك الشخصية والمالية مع الشركاء الماليين المذكورين أعلاه لأغراض دراسة طلب التمويل.'
                : 'By submitting this application, you consent to sharing your personal and financial data with the listed financial partners for the purpose of evaluating your financing request.',
          ),
          Gap(10.h),

          // Terms & Privacy link
          RichText(
            text: TextSpan(
              style: AppTextStyle.bodySmall(context).copyWith(
                color: AppColor.greyColor(context),
                fontSize: 11.sp,
              ),
              children: [
                TextSpan(
                  text: isArabic
                      ? 'لمزيد من المعلومات راجع '
                      : 'For more information, see our ',
                ),
                TextSpan(
                  text: isArabic ? 'الشروط والأحكام' : 'Terms & Conditions',
                  style: TextStyle(
                    color: AppColor.primaryColor(context),
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _launchUrl(
                          'https://hajed.com/terms', // TODO: replace with actual URL
                        ),
                ),
                TextSpan(text: isArabic ? ' و' : ' and '),
                TextSpan(
                  text: isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
                  style: TextStyle(
                    color: AppColor.primaryColor(context),
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _launchUrl(
                          'https://hajed.com/privacy', // TODO: replace with actual URL
                        ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentRow(BuildContext context, bool isArabic) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: Checkbox(
              value: _consented,
              onChanged: (v) {
                setState(() => _consented = v ?? false);
                widget.onConsentChanged?.call(v ?? false);
              },
              activeColor: AppColor.primaryColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          Gap(8.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _consented = !_consented);
                widget.onConsentChanged?.call(_consented);
              },
              child: Text(
                isArabic
                    ? 'أقرّ بأنني اطلعت على الإفصاح القانوني أعلاه وأوافق على مشاركة بياناتي مع الشركاء الماليين بهدف دراسة طلب التمويل.'
                    : 'I acknowledge that I have read the legal disclosure above and consent to sharing my data with the listed financial partners for the purpose of evaluating my financing application.',
                style: AppTextStyle.bodySmall(context).copyWith(
                  fontSize: 11.sp,
                  color: AppColor.blackTextColor(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyle.bodySmall(context).copyWith(
        color: AppColor.greyColor(context),
        fontSize: 11.sp,
        height: 1.5,
      ),
    );
  }
}
