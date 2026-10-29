part of 'app_routers_import.dart';

class AppRouters {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// True when [map] is a serialized car rather than a route-arguments
  /// wrapper. Some cards pass the car map directly as the route arguments.
  static bool _looksLikeCarMap(Map<String, dynamic> map) {
    return map.containsKey('ITEM_CODE') ||
        map.containsKey('itemCode') ||
        map.containsKey('ITEM_NAME') ||
        map.containsKey('itemName') ||
        map.containsKey('CHASSIS_NO') ||
        map.containsKey('chassisNo');
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    dynamic args;
    if (settings.arguments != null) args = settings.arguments;
    switch (settings.name) {
      case RoutesName.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RoutesName.mainLayout:
        return MaterialPageRoute(builder: (_) => const MainLayout());
      case RoutesName.allBrandsScreen:
        return MaterialPageRoute(builder: (_) => const AllBrandsScreen());
      case RoutesName.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeGuestScreen());
      case RoutesName.onboardingScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case RoutesName.loginScreen:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case RoutesName.registerScreen:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case RoutesName.carDetailsScreen:
        GetBrandCarsDataModel? car;
        String? heroTag;
        FinancingAdModel? offer;
        List<FinancingAdModel> offers = const [];
        bool isFromAdmin = false;

        if (args is GetBrandCarsDataModel) {
          car = args;
        } else if (args is Map<String, dynamic>) {
          if (args['car'] is GetBrandCarsDataModel) {
            car = args['car'];
          } else if (args['car'] is Map<String, dynamic>) {
            car = GetBrandCarsDataModel.fromJson(args['car']);
          }
          heroTag = args['heroTag'];
          offer = args['offer'] is FinancingAdModel ? args['offer'] : null;
          offers =
              (args['offers'] as List?)
                  ?.whereType<FinancingAdModel>()
                  .toList() ??
              const [];
          isFromAdmin = args['isFromAdmin'] ?? false;
        }

        return MaterialPageRoute(
          builder: (_) => CarDetailsScreen(
            car: car ?? GetBrandCarsDataModel.fromJson(args),
            heroTag: heroTag,
            offer: offer,
            offers: offers,
            isFromAdmin: isFromAdmin,
          ),
        );

      case RoutesName.carReservationScreen:
        GetBrandCarsDataModel? car;
        bool isFromLink = false;
        if (args is Map<String, dynamic>) {
          if (args['car'] is GetBrandCarsDataModel) {
            car = args['car'];
          } else if (args['car'] is Map<String, dynamic>) {
            car = GetBrandCarsDataModel.fromJson(args['car']);
          }
          isFromLink = args['isFromLink'] ?? false;
        }
        return MaterialPageRoute(
          builder: (_) =>
              CarReservationScreen(car: car!, isFromLink: isFromLink),
        );
      case RoutesName.popularCarsScreen:
        return MaterialPageRoute(builder: (_) => const PopularCarsScreen());
      case RoutesName.filterScreen:
        return MaterialPageRoute(builder: (_) => const FilterScreen());
      case RoutesName.cartScreen:
        final selectedCarId = args is Map<String, dynamic>
            ? args['id']?.toString()
            : null;
        return MaterialPageRoute(
          builder: (ctx) => BlocProvider.value(
            value: ctx.read<CartCubit>(),
            child: CartScreen(selectedCarId: selectedCarId),
          ),
        );
      // case RoutesName.paymentScreen:
      //   return MaterialPageRoute(builder: (_) => PaymentScreen(totalPrice: args as double));
      case RoutesName.paymentSuccessScreen:
        return MaterialPageRoute(builder: (_) => const PaymentSuccessScreen());
      case RoutesName.notificationsScreen:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case RoutesName.faqScreen:
        return MaterialPageRoute(builder: (_) => const FAQScreen());
      case RoutesName.settingsScreen:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case RoutesName.changePasswordScreen:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case RoutesName.profileScreen:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());
      case RoutesName.trackOrderScreen:
        final orderId = args is String
            ? args
            : (args is Map<String, dynamic>
                  ? args['orderId']?.toString()
                  : null);
        return MaterialPageRoute(
          builder: (_) => TrackOrderScreen(selectedOrderId: orderId),
        );

      case RoutesName.recentlyViewedScreen:
        return MaterialPageRoute(builder: (_) => const RecentlyViewedScreen());
      case RoutesName.tradeInScreen:
        return MaterialPageRoute(builder: (_) => const TradeInScreen());
      // case RoutesName.requestCarScreen:
      //   return MaterialPageRoute(builder: (_) => const RequestCarScreen());
      case RoutesName.financingScreen:
        GetBrandCarsDataModel? car;
        FinancingAdModel? offer;
        List<FinancingAdModel> offers = const [];
        if (args is GetBrandCarsDataModel) {
          car = args;
        } else if (args is Map<String, dynamic>) {
          if (args['car'] is GetBrandCarsDataModel) {
            car = args['car'];
          } else if (args['car'] is Map<String, dynamic>) {
            car = GetBrandCarsDataModel.fromJson(args['car']);
          } else if (_looksLikeCarMap(args)) {
            // Some cards pass the car map directly as the route arguments.
            // Rebuild it so the calculator can use the offer terms carried on
            // the row instead of falling back to standard financing data.
            car = GetBrandCarsDataModel.fromJson(args);
          }
          offer = args['offer'] is FinancingAdModel ? args['offer'] : null;
          offers =
              (args['offers'] as List?)
                  ?.whereType<FinancingAdModel>()
                  .toList() ??
              const [];
        }
        return MaterialPageRoute(
          builder: (_) =>
              FinancingScreen(car: car, offer: offer, offers: offers),
        );
      // case RoutesName.bookingAppointmentScreen:
      //   return MaterialPageRoute(builder: (_) => const BookingAppointmentScreen());
      case RoutesName.serviceHistoryScreen:
        return MaterialPageRoute(builder: (_) => const ServiceHistoryScreen());
      case RoutesName.supportScreen:
        return MaterialPageRoute(builder: (_) => const SupportScreen());
      case RoutesName.complaintsScreen:
        return MaterialPageRoute(builder: (_) => const ComplaintsScreen());
      case RoutesName.aboutScreen:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case RoutesName.carComparisonScreen:
        return MaterialPageRoute(builder: (_) => const CarComparisonScreen());
      case RoutesName.carDetailingScreen:
        return MaterialPageRoute(builder: (_) => const CarDetailingScreen());
      // case RoutesName.shippingScreen:
      //   return MaterialPageRoute(builder: (_) => const ShippingScreen());
      case RoutesName.bespokeSelectionScreen:
        return MaterialPageRoute(
          builder: (_) => const BespokeSelectionScreen(),
        );
      case RoutesName.carValuationScreen:
        return MaterialPageRoute(builder: (_) => const CarValuationScreen());
      case RoutesName.importOnDemandScreen:
        return MaterialPageRoute(builder: (_) => const ImportOnDemandScreen());
      case RoutesName.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminMainLayout());
      case RoutesName.agentDashboard:
        return MaterialPageRoute(builder: (_) => const AgentShell());
      case RoutesName.agentMyBookingsScreen:
        return MaterialPageRoute(builder: (_) => const AgentMyBookingsScreen());
      case RoutesName.manageCars:
        return MaterialPageRoute(builder: (_) => const ManageCarsScreen());
      case RoutesName.manageBookings:
        return MaterialPageRoute(builder: (_) => const ManageBookingsScreen());
      case RoutesName.manageUsers:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<AdminCubit>(),
            child: const ManageUsersScreen(),
          ),
        );
      case RoutesName.revenueReport:
      case RoutesName.revenueReports:
        return MaterialPageRoute(builder: (_) => const RevenueReportScreen());
      case RoutesName.comparisonReports:
        return MaterialPageRoute(
          builder: (_) => const AccountComparisonReportsScreen(),
        );
      case RoutesName.addCar:
        return MaterialPageRoute(builder: (_) => const AddCarScreen());
      case RoutesName.inspectionReports:
        return MaterialPageRoute(
          builder: (_) => const InspectionReportsScreen(),
        );
      case RoutesName.adminSettings:
        return MaterialPageRoute(builder: (_) => const AdminSettingsScreen());
      case RoutesName.allActivities:
        return MaterialPageRoute(builder: (_) => const AllActivitiesScreen());
      case RoutesName.adminNotifications:
        return MaterialPageRoute(
          builder: (_) => const AdminNotificationsScreen(),
        );
      case RoutesName.securitySettings:
        return MaterialPageRoute(builder: (_) => const AdminSecurityScreen());
      case RoutesName.systemAlerts:
        return MaterialPageRoute(builder: (_) => const SystemAlertsScreen());
      case RoutesName.discountCoupons:
        return MaterialPageRoute(builder: (_) => const DiscountCouponsScreen());
      case RoutesName.termsSettings:
        return MaterialPageRoute(builder: (_) => const TermsSettingsScreen());
      case RoutesName.adminSupport:
        return MaterialPageRoute(builder: (_) => const AdminSupportScreen());
      case RoutesName.contactDeveloper:
        return MaterialPageRoute(
          builder: (_) => const ContactDeveloperScreen(),
        );
      case RoutesName.adminLoanApplications:
        return MaterialPageRoute(
          builder: (_) => const AdminLoanApplicationsScreen(),
        );

      case RoutesName.agentCustomerDetailsScreen:
        return MaterialPageRoute(
          builder: (_) =>
              AgentCustomerDetailsScreen(customer: args as CustomerModel),
        );
      case RoutesName.agentExternalQuoteScreen:
        return MaterialPageRoute(
          builder: (_) => const AgentExternalQuoteScreen(),
        );
      case RoutesName.financingProgramOffersScreen:
      case RoutesName.offersScreen:
      default:
        return null;
    }
  }
}
