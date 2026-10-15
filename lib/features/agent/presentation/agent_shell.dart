import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/services/services_locator.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:car/features/agent/presentation/screens/agent_dashboard_screen.dart';
import 'package:car/features/agent/presentation/screens/agent_external_quote_screen.dart';
import 'package:car/features/agent/presentation/screens/agent_inventory_screen.dart';
import 'package:car/features/agent/presentation/screens/agent_leads_screen.dart';
import 'package:car/features/agent/presentation/screens/widget/nav_meta_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgentShell extends StatefulWidget {
  const AgentShell({super.key});
  @override
  State<AgentShell> createState() => _AgentShellState();
}

class _AgentShellState extends State<AgentShell> {
  int _currentIndex = 0;
  final GlobalKey<AgentDashboardScreenState> _dashboardKey =
      GlobalKey<AgentDashboardScreenState>();
  final GlobalKey<AgentInventoryScreenState> _inventoryKey =
      GlobalKey<AgentInventoryScreenState>();

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      _dashboardKey.currentState?.refresh();
    } else if (index == 2) {
      _inventoryKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      AgentDashboardScreen(key: _dashboardKey),
      const AgentLeadsScreen(),
      BlocProvider.value(
        value: sl<AdminCubit>(),
        child: AgentInventoryScreen(key: _inventoryKey),
      ),
      const AgentExternalQuoteScreen(),
    ];
    final navItems = [
      NavMeta(icon: Icons.dashboard_rounded, label: AppLocaleKey.agentNavHome.tr()),
      NavMeta(icon: Icons.people_rounded, label: AppLocaleKey.agentNavCustomers.tr()),
      NavMeta(icon: Icons.directions_car_rounded, label: AppLocaleKey.agentNavInventory.tr()),
      NavMeta(icon: Icons.request_quote_rounded, label: AppLocaleKey.externalQuote.tr()),
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      key: ValueKey(context.locale.languageCode),
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColor.scaffoldColor(context),
        body: IndexedStack(index: _currentIndex, children: screens),
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          items: navItems,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
