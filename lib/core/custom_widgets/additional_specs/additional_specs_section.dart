import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

/// One organised surface for a car's additional specifications.
///
/// The API returns the specifications as a flat list of phrases, so instead of
/// repeating a floating card per item this section groups them in a single
/// card, shows the total next to the title, and keeps long lists readable by
/// collapsing them behind a "Show all" toggle.
class AdditionalSpecsSection extends StatefulWidget {
  const AdditionalSpecsSection({
    super.key,
    required this.title,
    required this.specs,
    this.collapsedCount = 6,
    this.icon = Icons.auto_awesome_rounded,
  });

  /// Section heading, already localized by the caller.
  final String title;

  final List<String> specs;

  /// Number of rows shown before the "Show all" toggle appears.
  final int collapsedCount;

  final IconData icon;

  @override
  State<AdditionalSpecsSection> createState() => _AdditionalSpecsSectionState();
}

class _AdditionalSpecsSectionState extends State<AdditionalSpecsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.specs.isEmpty) return const SizedBox.shrink();

    final canCollapse = widget.specs.length > widget.collapsedCount;
    final visibleSpecs = canCollapse && !_isExpanded
        ? widget.specs.take(widget.collapsedCount).toList()
        : widget.specs;

    final border = AppColor.borderColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          title: widget.title,
          icon: widget.icon,
          count: widget.specs.length,
        ),
        Gap(12.h),
        Container(
          decoration: BoxDecoration(
            color: AppColor.cardColor(context),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: border.withValues(alpha: .45)),
            boxShadow: [
              BoxShadow(
                color: AppColor.blackColor(context).withValues(alpha: .035),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 620 ? 2 : 1;
                    final gap = 10.w;
                    final tileWidth =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;

                    return Column(
                      children: [
                        Wrap(
                          spacing: gap,
                          runSpacing: 10.h,
                          children: [
                            for (var index = 0;
                                index < visibleSpecs.length;
                                index++)
                              SizedBox(
                                width: tileWidth,
                                child: _SpecTile(
                                  text: visibleSpecs[index],
                                  index: index + 1,
                                ),
                              ),
                          ],
                        ),
                        if (canCollapse) ...[
                          Gap(10.h),
                          _ToggleRow(
                            isExpanded: _isExpanded,
                            onTap: () =>
                                setState(() => _isExpanded = !_isExpanded),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.icon,
    required this.count,
  });

  final String title;
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.primaryColor(context);

    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 18.sp, color: primary),
        ),
        Gap(10.w),
        Expanded(
          child: Text(
            title,
            style: AppTextStyle.titleMedium(context).copyWith(
              fontWeight: FontWeight.w800,
              color: AppColor.blackTextColor(context),
            ),
          ),
        ),
        Gap(8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$count',
            style: AppTextStyle.bodySmall(context).copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({required this.text, required this.index});

  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.primaryColor(context);

    return Container(
      constraints: BoxConstraints(minHeight: 56.h),
      padding: EdgeInsetsDirectional.fromSTEB(10.w, 10.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: AppColor.scaffoldColor(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColor.borderColor(context).withValues(alpha: .35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Text(
              '$index',
              style: AppTextStyle.bodySmall(context).copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
                color: primary,
              ),
            ),
          ),
          Gap(10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3.h),
              child: Text(
                text,
                style: AppTextStyle.bodyMedium(context).copyWith(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: AppColor.blackTextColor(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.isExpanded, required this.onTap});

  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.primaryColor(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              (isExpanded ? AppLocaleKey.showLess : AppLocaleKey.showAll).tr(),
              style: AppTextStyle.bodySmall(context).copyWith(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w800,
                color: primary,
              ),
            ),
            Gap(4.w),
            AnimatedRotation(
              turns: isExpanded ? .5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18.sp,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
