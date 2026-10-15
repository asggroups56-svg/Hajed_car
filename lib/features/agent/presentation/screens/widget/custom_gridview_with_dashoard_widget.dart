import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/features/agent/data/model/agent_models.dart';
import 'package:car/features/agent/presentation/cubit/agent_cubit.dart';
import 'package:car/features/agent/presentation/cubit/agent_state.dart';
import 'package:car/features/agent/presentation/screens/agent_external_offers_screen.dart';
import 'package:car/features/agent/presentation/screens/agent_my_bookings_screen.dart';
import 'package:car/features/agent/presentation/screens/agent_offers_screen.dart';
import 'package:car/features/agent/presentation/screens/widget/agent_notification_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/premium_kpi_card_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/section_header_widget.dart';
import 'package:car/features/cart/presentation/view/cubit/cart_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class CustomGridviewWithDashoardWidget extends StatelessWidget {
  const CustomGridviewWithDashoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        return BlocBuilder<AgentCubit, AgentState>(
          builder: (context, state) {
            final offers = state.offersStatus.data ?? [];
            final externalOffers = state.externalOffersStatus.data ?? [];
            final offersCount = offers.length;
            final reservedCount = cartState.reservedCars.length;
            final kpis = getAgentKpis(
              closedDeals: reservedCount,
              sales: offersCount.toDouble(),
              externalQuotes: externalOffers.length,
            );
            return SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 30.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // const PremiumCommissionBanner(),
                  const AgentNotificationSlider(),
                  Gap(24.h),
                  SectionHeader(title: AppLocaleKey.agentKeyMetrics.tr()),
                  Gap(12.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: kpis.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 1.08,
                    ),
                    itemBuilder: (_, i) {
                      final kpiCard = PremiumKpiCard(kpi: kpis[i]);
                      void refreshHome() {
                        final userCode = HiveMethods.getUserCode() ?? '1';
                        final represNo = int.tryParse(userCode) ?? 1;
                        context.read<AgentCubit>().getOffers(null, represNo, null);
                        context.read<AgentCubit>().getExternalOffers(null, represNo, null);
                        context.read<CartCubit>().loadReservedCars(isAgent: true);
                      }

                      if (i == 0) {
                        return InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AgentMyBookingsScreen()),
                            );
                            if (context.mounted) {
                              refreshHome();
                            }
                          },
                          borderRadius: BorderRadius.circular(24.r),
                          child: kpiCard,
                        );
                      }
                      if (i == 1) {
                        return InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AgentOffersScreen()),
                            );
                            if (context.mounted) {
                              refreshHome();
                            }
                          },
                          borderRadius: BorderRadius.circular(24.r),
                          child: kpiCard,
                        );
                      }
                      if (i == 2) {
                        return InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AgentExternalOffersScreen()),
                            );
                            if (context.mounted) {
                              refreshHome();
                            }
                          },
                          borderRadius: BorderRadius.circular(24.r),
                          child: kpiCard,
                        );
                      }
                      return kpiCard;
                    },
                  ),
                  Gap(24.h),
                  // SectionHeader(title: AppLocaleKey.agentWeeklyActivity.tr()),
                  // Gap(12.h),
                  // PremiumWeeklyChart(data: _weeklyData, days: weekDays),
                  // Gap(24.h),
                  //SectionHeader(title: AppLocaleKey.agentQuickActions.tr()),
                  // Gap(12.h),
                  // GridView.count(
                  //   crossAxisCount: 3,
                  //   mainAxisSpacing: 12.h,
                  //   crossAxisSpacing: 12.w,
                  //   padding: EdgeInsets.zero,
                  //   shrinkWrap: true,
                  //   physics: const NeverScrollableScrollPhysics(),
                  //   children: [
                  //     PremiumQuickAction(
                  //       icon: Icons.person_add_alt_1_rounded,
                  //       label: AppLocaleKey.agentCustomer.tr(),
                  //       color: AppColor.blueColor(context),
                  //       onTap: () => Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (_) => const AgentAddLeadScreen()),
                  //       ),
                  //     ),
                  //     PremiumQuickAction(
                  //       icon: Icons.event_available_rounded,
                  //       label: AppLocaleKey.agentAppointment.tr(),
                  //       color: AppColor.orangeColor(context),
                  //       onTap: () => Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (_) => const AgentAddAppointmentScreen()),
                  //       ),
                  //     ),
                  //     PremiumQuickAction(
                  //       icon: Icons.note_add_rounded,
                  //       label: AppLocaleKey.agentNote.tr(),
                  //       color: AppColor.greenColor(context),
                  //       onTap: () => Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (_) => const AgentAddNoteScreen()),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ]),
              ),
            );
          },
        );
      },
    );
  }
}
