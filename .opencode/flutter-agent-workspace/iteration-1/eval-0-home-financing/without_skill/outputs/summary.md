# Financing offers on home — without skills

## Built
- `financing_offers_section_widget.dart`: horizontal section under the ads slider, driven by `HomeState.financingAdsStatus`, with shimmer loading, empty and error states, retry through `HomeCubit.getFinancingAds`, and offers deduplicated by `programId`.
- `financing_offer_card_widget.dart`: card with bank name/logo, offer title, monthly installment; opens the financing screen on tap.
- `guest_home_screen.dart`: section placed below the ads slider.
- `app_routers.dart`: financing route accepts optional `offer`/`offers`.
- Locale keys for title, empty, error, and fallback title.

## Verification
`flutter analyze` on touched Dart paths: no issues in the new widgets, guest screen, or route. Remaining diagnostics are pre-existing infos in `app_locale_keys.dart`.

## Not verified
No device run; RTL/dark mode not manually checked.
