import 'dart:io';

import 'package:car/core/theme/app_colors.dart';
import 'package:car/features/cars/presentation/screen/widget/premium_car_card_widget.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:car/features/home/presentation/cubit/home_cubit.dart';

class _FakeFavoritesCubit extends Cubit<FavoritesState>
    implements FavoritesCubit {
  _FakeFavoritesCubit() : super(FavoritesInitial());

  @override
  bool isFavorite(dynamic carIdentifier) => false;

  @override
  void toggleFavorite(dynamic carIdentifier) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHomeCubit extends Cubit<HomeState> implements HomeCubit {
  _FakeHomeCubit() : super(const HomeState());

  @override
  Future<void> getNormalFinancing({bool force = false}) async {}

  @override
  bool isCarLocallyReserved(String itemCode) => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    final tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('app')) {
      await Hive.openBox('app');
    }
  });

  GetBrandCarsDataModel createSampleCar({
    required String code,
    required String name,
    required String color,
  }) {
    return GetBrandCarsDataModel(
      groupCode: 1,
      groupName: 'Toyota',
      grName: 'Toyota',
      groupParent: 0,
      groupLevel: 1,
      itemCode: code,
      itemType: 1,
      itemName: name,
      groupCode1: 1,
      storeCode: '01',
      carStatus: 1,
      carType: 1,
      chassisNo: 'CH$code',
      bodyColor: color,
      transmission: 1,
      cylinder: '4',
      powerHourse: '150',
      fuelCapacity: '50',
      fuelType: 'Gasoline',
      seatNo: 5,
      doorNo: 4,
      addType: 1,
      colorCode: 1,
      makeYear: 2024,
      notifyType: 0,
      supplierCd: 1,
      buyDate: '2024-01-01',
      trNo: 1,
      reasonId: 1,
      mobileShow: true,
      color: color,
      carImage: '',
      extraImages: const [],
      price: '100000',
    );
  }

  testWidgets('PremiumCarCardWidget renders smoothly with multi-color and single color cars', (
    WidgetTester tester,
  ) async {
    final multiColorCar = createSampleCar(
      code: 'CAR001',
      name: 'Camry 2024 Two Tone',
      color: 'أبيض / أسود',
    );

    final singleColorCar = createSampleCar(
      code: 'CAR002',
      name: 'Corolla 2024 Silver',
      color: 'فضي',
    );

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'i18n',
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('ar'),
        saveLocale: false,
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, _) => MaterialApp(
            locale: const Locale('ar'),
            home: Scaffold(
              body: MultiBlocProvider(
                providers: [
                  BlocProvider<FavoritesCubit>(create: (_) => _FakeFavoritesCubit()),
                  BlocProvider<HomeCubit>(create: (_) => _FakeHomeCubit()),
                ],
                child: ListView(
                  children: [
                    PremiumCarCardWidget(
                      car: multiColorCar,
                      heroTag: 'hero_1',
                    ),
                    PremiumCarCardWidget(
                      car: singleColorCar,
                      heroTag: 'hero_2',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Camry 2024 Two Tone'), findsOneWidget);
    expect(find.text('Corolla 2024 Silver'), findsOneWidget);
  });
}
