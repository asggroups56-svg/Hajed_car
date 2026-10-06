import 'dart:async';

import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/agent/presentation/cubit/agent_cubit.dart';
import 'package:car/features/agent/presentation/cubit/agent_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ExternalQuoteCustomerPickerSheet extends StatelessWidget {
  const ExternalQuoteCustomerPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.primaryColor(context);
    return _PickerSheetShell(
      title: AppLocaleKey.externalQuoteCustomerPickerTitle.tr(),
      hint: AppLocaleKey.externalQuoteCustomerSearchHint.tr(),
      onSearch: (query) => context.read<AgentCubit>().getCustomer(query.isEmpty ? null : query),
      child: BlocBuilder<AgentCubit, AgentState>(
        buildWhen: (previous, current) => previous.customersStatus != current.customersStatus,
        builder: (context, state) {
          final customers = state.customersStatus.data ?? [];
          if (state.customersStatus.isLoading && customers.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (customers.isEmpty) {
            return _pickerEmpty(context, AppLocaleKey.externalQuoteCustomerPickerEmpty.tr());
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(14.w, 2.h, 14.w, 20.h),
            itemCount: customers.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: AppColor.borderColor(context).withValues(alpha: 0.12)),
            itemBuilder: (context, index) {
              final customer = customers[index];
              final name = customer.customerName ?? AppLocaleKey.externalQuoteCustomerFallback.tr();
              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                onTap: () => Navigator.pop(context, customer),
                leading: CircleAvatar(
                  radius: 16.r,
                  backgroundColor: primary.withValues(alpha: 0.12),
                  child: Text(
                    name.isNotEmpty ? name[0] : '•',
                    style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 13.sp),
                  ),
                ),
                title: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    fontSize: 13.sp,
                    color: AppColor.blackTextColor(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  '${AppLocaleKey.externalQuoteCode.tr(namedArgs: {'code': '${customer.customerNo ?? '—'}'})}'
                  '${customer.customerMobile.isNotEmpty ? '  •  ${customer.customerMobile}' : ''}',
                  style: AppTextStyle.bodySmall(
                    context,
                  ).copyWith(fontSize: 11.sp, color: AppColor.greyColor(context)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ExternalQuoteColorPickerSheet extends StatelessWidget {
  final dynamic selectedCode;

  const ExternalQuoteColorPickerSheet({super.key, this.selectedCode});

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.primaryColor(context);
    return _PickerSheetShell(
      title: AppLocaleKey.externalQuoteColorPickerTitle.tr(),
      hint: AppLocaleKey.externalQuoteColorSearchHint.tr(),
      onSearch: (query) => context.read<AgentCubit>().getColors(query.isEmpty ? null : query),
      child: BlocBuilder<AgentCubit, AgentState>(
        buildWhen: (previous, current) => previous.colorsStatus != current.colorsStatus,
        builder: (context, state) {
          final colors = state.colorsStatus.data ?? [];
          if (state.colorsStatus.isLoading && colors.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (colors.isEmpty) {
            return _pickerEmpty(context, AppLocaleKey.externalQuoteColorPickerEmpty.tr());
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(14.w, 2.h, 14.w, 20.h),
            itemCount: colors.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: AppColor.borderColor(context).withValues(alpha: 0.12)),
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = selectedCode != null && selectedCode == color.code;
              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                onTap: () => Navigator.pop(context, color),
                leading: Container(
                  width: 26.w,
                  height: 26.w,
                  decoration: BoxDecoration(
                    color: color.displayColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 0.8),
                  ),
                ),
                title: Text(
                  color.name,
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    fontSize: 13.sp,
                    color: isSelected ? primary : AppColor.blackTextColor(context),
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  AppLocaleKey.externalQuoteCode.tr(namedArgs: {'code': '${color.code}'}),
                  style: AppTextStyle.bodySmall(
                    context,
                  ).copyWith(fontSize: 11.sp, color: AppColor.greyColor(context)),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: primary, size: 20.sp)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class _PickerSheetShell extends StatefulWidget {
  final String title;
  final String hint;
  final ValueChanged<String> onSearch;
  final Widget child;

  const _PickerSheetShell({
    required this.title,
    required this.hint,
    required this.onSearch,
    required this.child,
  });

  @override
  State<_PickerSheetShell> createState() => _PickerSheetShellState();
}

class _PickerSheetShellState extends State<_PickerSheetShell> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => widget.onSearch(query.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.scaffoldColor(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Gap(8.h),
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColor.greyColor(context).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              Gap(12.h),
              Text(
                widget.title,
                style: AppTextStyle.bodyMedium(context).copyWith(
                  fontSize: 15.sp,
                  color: AppColor.blackTextColor(context),
                  fontWeight: FontWeight.w900,
                ),
              ),
              Gap(10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Container(
                  height: 42.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: AppColor.cardColor(context),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColor.borderColor(context).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppColor.greyColor(context), size: 18.sp),
                      Gap(8.w),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: _onChanged,
                          style: AppTextStyle.bodyMedium(context).copyWith(fontSize: 13.sp),
                          decoration: InputDecoration(
                            hintText: widget.hint,
                            hintStyle: AppTextStyle.bodySmall(
                              context,
                            ).copyWith(fontSize: 12.sp, color: AppColor.hintColor(context)),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Gap(6.h),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _pickerEmpty(BuildContext context, String text) => Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.search_off_rounded, size: 36.sp, color: AppColor.greyColor(context)),
      Gap(8.h),
      Text(
        text,
        style: AppTextStyle.bodyMedium(
          context,
        ).copyWith(fontSize: 13.sp, color: AppColor.greyColor(context)),
      ),
    ],
  ),
);
