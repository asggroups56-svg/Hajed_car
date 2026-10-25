# Financing offers on home — with skills

## Built
- `financing_offers_section_widget.dart`: section directly under the ads slider. Reads `HomeState.financingAdsStatus` through a scoped `BlocBuilder` (`buildWhen`). Shimmer loading, `NoDataWidget` empty state, `ExceptionWidget` failure state with retry through `HomeCubit.getFinancingAds`.
- `financing_offer_card_widget.dart`: horizontal card with bank logo/name, offer title fallbacks, monthly installment formatted per locale + `sar` label. Tap opens `RoutesName.financingScreen` through `NavigatorMethods`, passing `car`, `offer`, `offers`.
- `app_routers.dart`: financing route now forwards optional `offer`/`offers` (backwards compatible).
- 3 keys added to `AppLocaleKey`, `i18n/en.json`, `i18n/ar.json`: `financingOffersSectionTitle`, `financingOffersEmpty`, `financingOfferFallback`.

## Handoffs
No data-layer work: `EndPoints.getFinancingAds` -> `HomeRepo.getFinancingAds` -> `HomeCubit.getFinancingAds` and `financingAdsStatus` already existed and `refreshHomeData` loads it. No packages, DI, or route names added.

## Verification
`flutter analyze lib/features/home lib/core/routes`: 64 issues before and after, 0 new. No diagnostics in the new widgets, guest screen, or router.

## Not verified
No device/emulator run; light/dark, Arabic RTL and taps were checked by inspection. No widget test.
