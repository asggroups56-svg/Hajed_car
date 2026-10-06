import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/features/agent/presentation/cubit/agent_cubit.dart';
import 'package:car/features/agent/presentation/screens/widget/custom_gridview_with_dashoard_widget.dart';
import 'package:car/features/agent/presentation/screens/widget/custom_header_info_widget.dart';
import 'package:car/features/cart/presentation/view/cubit/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});
  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userCode = HiveMethods.getUserCode() ?? '1';
      final represNo = int.tryParse(userCode) ?? 1;
      context.read<AgentCubit>().getOffers(null, represNo, null);
      context.read<AgentCubit>().getExternalOffers(null, represNo, null);
      context.read<CartCubit>().loadReservedCars(isAgent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBarColor(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80.h,
            pinned: true,
            backgroundColor: AppColor.appBarColor(context),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: AppColor.appBarColor(context),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                    bottomRight: Radius.circular(30.r),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [CustomHeaderInfoWidget()],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const CustomGridviewWithDashoardWidget(),
        ],
      ),
    );
  }
}
