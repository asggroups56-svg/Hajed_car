import 'package:car/core/custom_widgets/buttons/custom_button.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/services/presentation/widgets/custom_monthly_installment_card_widget.dart';
import 'package:car/features/services/presentation/widgets/financing_calculator_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final offer = FinancingAdModel.fromJson(const {
    'ProgramID': 3,
    'ProgramName': 'Al Rajhi Bank Campaign',
    'BankName': 'Al Rajhi Bank',
    'FirstInstallmentPct': 20.0,
    'LastInstallmentPct': 10.0,
    'FirstInstallmentPctother': 10.0,
    'LastInstallmentPctother': 40.0,
    'AdminFeesPctother': 1.5,
    'InsurancePct': 1.0,
    'InsurancePctother': 3.5,
    'InterestRate': 2.8,
    'InterestRate_other': 4.25,
    'PaintingsVal': 1000.0,
    'TotalMonths': 60,
  });

  Widget buildTestWidget({
    required Locale locale,
    required Widget child,
  }) {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'i18n',
      fallbackLocale: const Locale('ar'),
      startLocale: locale,
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) => Builder(
          builder: (context) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: Scaffold(body: child),
          ),
        ),
      ),
    );
  }

  group('CustomMonthlyInstallmentCardWidget layout tests', () {
    for (final locale in const [Locale('ar'), Locale('en')]) {
      for (final width in const [320.0, 360.0, 390.0, 430.0]) {
        testWidgets('does not overflow in $locale at width $width', (tester) async {
          tester.view.devicePixelRatio = 1.0;
          tester.view.physicalSize = Size(width, 844);
          addTearDown(tester.view.reset);

          await tester.runAsync(() async {
            await tester.pumpWidget(
              buildTestWidget(
                locale: locale,
                child: CustomMonthlyInstallmentCardWidget(
                  fmt: NumberFormat('#,##0', 'en_US'),
                  monthly: 2542.18,
                  totalPrice: 245392.50,
                ),
              ),
            );
            await Future<void>.delayed(const Duration(milliseconds: 300));
          });
          await tester.pumpAndSettle();

          expect(find.byType(CustomMonthlyInstallmentCardWidget), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('FinancingCalculatorBottomSheet tests', () {
    testWidgets('renders properly and allows confirmation', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);

      Map<String, dynamic>? returnedResult;

      await tester.runAsync(() async {
        await tester.pumpWidget(
          buildTestWidget(
            locale: const Locale('ar'),
            child: Builder(
              builder: (ctx) => TextButton(
                onPressed: () async {
                  returnedResult = await showModalBottomSheet<Map<String, dynamic>>(
                    context: ctx,
                    builder: (_) => FinancingCalculatorBottomSheet(
                      priceWithVat: 176950,
                      initialDownPayment: 35390,
                      initialLastPayment: 17695,
                      initialDuration: 5,
                      offers: [offer],
                      initialOffer: offer,
                      userSalaryBank: 'SNB',
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(FinancingCalculatorBottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Scroll to confirm/buy button and tap it
      final buttonFinder = find.byType(CustomButton);
      expect(buttonFinder, findsOneWidget);
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Bottom sheet should have closed and returned calculation map
      expect(find.byType(FinancingCalculatorBottomSheet), findsNothing);
      expect(returnedResult, isNotNull);
      expect(returnedResult!['duration'], 5);
      expect(returnedResult!['down'], 35390.0);
      expect(returnedResult!['last'], 17695.0);
    });
  });
}
