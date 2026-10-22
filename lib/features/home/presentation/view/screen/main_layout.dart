import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/routes/routes_name.dart';
import 'package:car/core/services/app_update_service.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/core/utils/navigator_methods.dart';
import 'package:car/features/cars/presentation/screen/car_comparison_screen.dart';
import 'package:car/features/favorites/presentation/view/screen/favorites_screen.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:car/features/home/presentation/view/widgets/notification_icon_widget.dart';
import 'package:car/features/notifications/presentation/view/cubit/notifications_cubit.dart';
import 'package:car/features/profile/presentation/screen/account_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../cars/presentation/screen/cars_screen.dart';
import '../widgets/main_bottom_nav_bar.dart';
import 'guest_home_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  static final ValueNotifier<int> tabIndex = ValueNotifier(0);
  static final ValueNotifier<String> carsSearchQuery = ValueNotifier('');
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void _onTabChanged() {
    final nextIndex = MainLayout.tabIndex.value;
    if (_currentIndex == 1 && nextIndex != 1) {
      context.read<HomeCubit>().clearProgramCarsFilter();
    }
    setState(() {
      _currentIndex = nextIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = MainLayout.tabIndex.value;
    MainLayout.tabIndex.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final code = HiveMethods.getcode() ?? '';
      final isAgent = HiveMethods.isAgentRole();

      final currentStatus = context.read<HomeCubit>().state.notificationsStatus;
      if (currentStatus.isSuccess && currentStatus.data != null) {
        context.read<NotificationsCubit>().loadFromApi(
          currentStatus.data!.map((n) => n.toMap()).toList(),
        );
      }

      context.read<HomeCubit>().getNotificationsData(
        currentUserId: code,
        userType: isAgent ? 2 : 1,
      );

      AppUpdateService.checkForUpdate(context);
    });
  }

  @override
  void dispose() {
    MainLayout.tabIndex.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeGuestScreen(key: ValueKey('home_${context.locale.languageCode}')),
      CarsScreen(key: ValueKey('cars_${context.locale.languageCode}')),
      FavoritesScreen(
        key: ValueKey('favorites_${context.locale.languageCode}'),
      ),
      const CarComparisonScreen(),
      const AccountScreen(),
    ];
    return PopScope(
      // Prevent default back navigation (which exits the app)
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentIndex != 0) {
          // If not on home tab, go to home tab
          MainLayout.tabIndex.value = 0;
        }
        // If already on home tab, do nothing (don't exit)
      },
      child: Scaffold(
        appBar: _currentIndex == 3 || _currentIndex == 4
            ? null
            : CustomAppBar(
                context,
                centerTitle: false,
                automaticallyImplyLeading: false,
                appBarColor: Colors.transparent,
                //  leading: const ProfileIconWidget(),
                title: ValueListenableBuilder(
                  valueListenable: Hive.box(
                    'app',
                  ).listenable(keys: ['userName', 'isGuest']),
                  builder: (context, box, _) {
                    final isGuest = box.get('isGuest', defaultValue: false);
                    final userName = HiveMethods.getUserName() ?? '';
                    final welcomeText = AppLocaleKey.welcomeToCarGroup.tr();
                    final separator = context.locale.languageCode == 'ar'
                        ? '،'
                        : ',';

                    if (_currentIndex == 1) {
                      return BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, state) {
                          final isFilteredByOffer =
                              state.programCarsStatus.isSuccess &&
                              state.programCarsStatus.data != null &&
                              state.programCarsStatus.data!.isNotEmpty;
                          final homeCubit = context.read<HomeCubit>();
                          final availableCarsCount = isFilteredByOffer
                              ? state.programCarsStatus.data!
                                    .where(
                                      (car) => !homeCubit.isCarLocallyReserved(
                                        car.itemCode ?? '',
                                      ),
                                    )
                                    .length
                              : (state.allCarsStatus.data ?? [])
                                    .where(
                                      (car) =>
                                          car.carStatus == 1 &&
                                          !homeCubit.isCarLocallyReserved(
                                            car.itemCode,
                                          ),
                                    )
                                    .length;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocaleKey.cars.tr(),
                                style: AppTextStyle.bodyLarge(context).copyWith(
                                  color: AppColor.blackTextColor(context),
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              Text(
                                context.locale.languageCode == 'ar'
                                    ? '$availableCarsCount سيارة متاحة'
                                    : '$availableCarsCount cars available',
                                style: AppTextStyle.bodySmall(context).copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }

                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        _currentIndex == 2
                            ? AppLocaleKey.favorites.tr()
                            : isGuest || userName.isEmpty
                            ? welcomeText
                            : '$welcomeText$separator $userName',
                        style: AppTextStyle.bodyLarge(context).copyWith(
                          color: AppColor.blackTextColor(context),
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    );
                  },
                ),
                actions: [
                  const NotificationIconWidget(),
                  Gap(10.w),
                  //  const CartIconWidget(),
                  // Gap(10.w),
                  // const TranslateIconWidget(),
                  //  Gap(5.w),
                ],
              ),
        body: BlocListener<HomeCubit, HomeState>(
          listenWhen: (prev, curr) =>
              prev.notificationsStatus != curr.notificationsStatus,
          listener: (context, state) {
            if (state.notificationsStatus.isSuccess) {
              final list = state.notificationsStatus.data ?? [];
              context.read<NotificationsCubit>().loadFromApi(
                list.map((n) => n.toMap()).toList(),
              );
            } else if (state.notificationsStatus.isFailure) {
              context.read<NotificationsCubit>().loadFromApi([]);
            }
          },
          child: screens[_currentIndex.clamp(0, screens.length - 1)],
        ),
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: _currentIndex,
          onItemSelected: (index) {
            MainLayout.tabIndex.value = index;
          },
        ),
      ),
    );
  }

  void _goToCars() {
    MainLayout.tabIndex.value = 1;
    NavigatorMethods.pushNamedAndRemoveUntil(context, RoutesName.mainLayout);
  }
}
