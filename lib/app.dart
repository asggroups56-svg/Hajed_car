import 'package:bot_toast/bot_toast.dart';
import 'package:car/core/custom_widgets/internet_connectivity_wrapper.dart';
import 'package:car/core/custom_widgets/security_lock_wrapper.dart';
import 'package:car/core/services/notification_service.dart';
import 'package:car/core/services/services_locator.dart';
import 'package:car/core/theme/cubit/app_theme_cubit.dart';
import 'package:car/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:car/features/agent/presentation/cubit/agent_cubit.dart';
import 'package:car/features/auth/presentation/view/cubit/auth_cubit.dart';
import 'package:car/features/cart/presentation/view/cubit/cart_cubit.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/notifications/presentation/view/cubit/notifications_cubit.dart';
import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/routes/app_routers_import.dart';
import 'core/routes/routes_name.dart';
import 'core/theme/style.dart';

class CarApp extends StatefulWidget {
  const CarApp({super.key});
  @override
  State<CarApp> createState() => _CarAppState();
}

class _CarAppState extends State<CarApp> {
  @override
  Widget build(BuildContext context) {
    context.locale;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 600;
        final Size designSize =
            (isTablet && constraints.maxWidth.isFinite && constraints.maxHeight.isFinite)
            ? Size(constraints.maxWidth / 1.35, constraints.maxHeight / 1.35)
            : const Size(360, 690);
        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          useInheritedMediaQuery: true,
          builder: (_, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => AppThemeCubit()..initial()),
                BlocProvider(create: (context) => sl<AuthCubit>()),
                BlocProvider(create: (context) => sl<HomeCubit>()),
                BlocProvider(create: (context) => sl<FavoritesCubit>()),
                BlocProvider(create: (context) => sl<CartCubit>()),
                BlocProvider(
                  create: (context) {
                    final cubit = NotificationsCubit();
                    NotificationService.bindNotificationsCubit(cubit);
                    return cubit;
                  },
                ),
                BlocProvider(create: (context) => sl<AgentCubit>()),
                BlocProvider(create: (context) => sl<AdminCubit>()),
              ],
              child: BlocBuilder<AppThemeCubit, AppThemeState>(
                builder: (context, themeState) {
                  return MaterialApp(
                    onGenerateTitle: (context) => 'car_app'.tr(),
                    localizationsDelegates: [
                      ...context.localizationDelegates,
                      CountryLocalizations.delegate,
                    ],
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                    debugShowCheckedModeBanner: false,
                    theme: appThemeData(context),
                    darkTheme: appThemeData(context),
                    themeMode: ThemeMode.light,
                    initialRoute: RoutesName.splashScreen,
                    onGenerateRoute: AppRouters.onGenerateRoute,
                    navigatorKey: AppRouters.navigatorKey,
                    builder: (context, child) {
                      final botToastBuilder = BotToastInit();
                      return botToastBuilder(
                        context,
                        SecurityLockWrapper(child: InternetConnectivityWrapper(child: child!)),
                      );
                    },
                    navigatorObservers: [BotToastNavigatorObserver()],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
