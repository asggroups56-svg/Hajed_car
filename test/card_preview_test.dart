import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:car/core/images/app_images.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:car/features/favorites/presentation/view/screen/widget/favorite_item_widget.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) continue;
    loader.addFont(
      Future.value(ByteData.sublistView(file.readAsBytesSync())),
    );
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init(Directory.systemTemp.createTempSync('hive_card_preview').path);
    await Hive.openBox('app');

    const sdkFonts =
        '/Users/asgsystems/flutter/bin/cache/artifacts/material_fonts';
    await _loadFont('Roboto', [
      '$sdkFonts/Roboto-Regular.ttf',
      '$sdkFonts/Roboto-Bold.ttf',
      '$sdkFonts/Roboto-Black.ttf',
    ]);
    await _loadFont('MaterialIcons', ['$sdkFonts/MaterialIcons-Regular.otf']);
    await _loadFont('Arial', [
      '/System/Library/Fonts/Supplemental/Arial.ttf',
      '/System/Library/Fonts/Supplemental/Arial Bold.ttf',
    ]);

    final en = json.decode(File('i18n/en.json').readAsStringSync());
    Localization.load(
      const Locale('en'),
      translations: Translations(en as Map<String, dynamic>),
    );
  });

  tearDownAll(() async {
    await Hive.close();
  });

  final car = <String, dynamic>{
    'unique_id': 'preview_chassis_1',
    'chassisNo': 'PREVIEW123',
    'name': 'Mercedes-Benz GLE 450 4MATIC AMG Line',
    'brand': 'Mercedes-Benz',
    'year': '2025',
    'color': 'White',
    'price': '415000',
    'PaintingsVal': 3500,
    'image': AppImages.assetsImagesCar,
  };

  Future<void> pumpCard(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => BlocProvider(
          create: (_) => FavoritesCubit(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Roboto', useMaterial3: true),
            home: Scaffold(
              backgroundColor: const Color(0xFFF1F5F9),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: FavoriteItemWidget(car: car),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(AppImages.assetsImagesCar),
        tester.element(find.byType(FavoriteItemWidget)),
      );
    });
    await tester.pumpAndSettle();
  }

  testWidgets('card preview 390', (tester) async {
    await pumpCard(tester, 390);
    await expectLater(
      find.byType(FavoriteItemWidget),
      matchesGoldenFile('card_390.png'),
    );
  });

  testWidgets('card preview 320', (tester) async {
    await pumpCard(tester, 320);
    await expectLater(
      find.byType(FavoriteItemWidget),
      matchesGoldenFile('card_320.png'),
    );
  });
}
