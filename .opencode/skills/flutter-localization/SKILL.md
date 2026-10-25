---
name: flutter-localization
description: Hajed_car Arabic/English localization — adding keys to AppLocaleKey and both i18n JSON files, writing natural Arabic, interpolation, number formatting, RTL verification, and keeping ar/en key parity. Use this skill whenever text is added or changed in the UI, when a key is missing, when Arabic renders wrong, or when a screen must be checked in both languages.
---

# Localization — Hajed_car

The app ships Arabic and English through `easy_localization`. Arabic is the primary product language:
never treat it as an afterthought or a machine translation.

## 1. How strings work

```
lib/core/localization/app_locale_keys.dart   →  class AppLocaleKey {
                                                  static const String aboutCompany = 'about_company';
                                                }
i18n/ar.json, i18n/en.json                   →  { "about_company": "…" }
widget                                        →  Text(AppLocaleKey.aboutCompany.tr())
```

- **`.tr()` looks up the constant's value, not its Dart name.** `AppLocaleKey.aboutCompany` reads
  `about_company` from the JSON; if you add the constant but not that exact JSON key, the screen shows
  the raw key. This is the most common localization bug in this repo.
- `MaterialApp` wires `context.localizationDelegates` / `supportedLocales` in `lib/app.dart`.
- The selected language is persisted via Hive and also drives the `lang` header sent by
  `AppInterceptors` (`en-GB` or `ar`), so server messages arrive localized already.
- The file mixes snake_case and camelCase values (about 1,050 vs 600 at the time of writing).
  Dart names are always lowerCamelCase. JSON values follow the **neighbouring section**: if the keys
  around your insertion point are snake_case, use snake_case; if they are camelCase, you may use the
  same camelCase name as the Dart constant. Do not rename existing keys just to normalize them, and
  do not assume the Dart name and JSON value are identical.
- Keys live in themed sections of `app_locale_keys.dart` (`// Cart Screen`, `// Financing Overhaul`,
  `// Agent UI Text Keys`, …). Add the new constant inside the closest section, not at the file end.
- `context.apiTr(ar: ..., en: ...)` exists and is used by older core widgets. It bypasses the JSON
  files. Do not use it for new feature text; use `AppLocaleKey` + both JSON files so translators and
  the parity audit can see the string.

## 2. Adding a string (the only correct sequence)

1. Choose the key from the feature and meaning: `bookingCancelledTitle`, not `text1`. Pick the JSON
   value style from the nearest section (`booking_cancelled_title` or `bookingCancelledTitle`).
2. Add the constant to `AppLocaleKey` inside that section:
   `static const String bookingCancelledTitle = 'booking_cancelled_title';`
3. Add `"booking_cancelled_title": "…"` to **`i18n/en.json`**.
4. Add the same key to **`i18n/ar.json`** with natural Arabic.
5. Use `AppLocaleKey.bookingCancelledTitle.tr()` at the call site.
6. Run the audit and confirm **zero new** missing keys (pre-existing debt is listed separately):

   ```bash
   python3 .opencode/skills/flutter-localization/scripts/i18n_audit.py
   ```

A change is not done with one locale updated. There is no fallback that makes a missing Arabic key
acceptable.

## 3. Arabic quality rules

- Modern Standard Arabic, concise product tone. No dialect, no diacritics.
- Match the vocabulary already in the file: السيارة، الحجز، التمويل، القسط، الدفعة الأولى، العرض،
  الماركة، الوكيل، الفحص، الضمان، التوصيل، ر.س.
- Keep established Latin terms where the product uses them: `PDF`, `VIP`, `OTP`, `QR`, `Apple Pay`.
- Brand names stay as-is (تويوتا / Toyota — follow the surrounding file; do not invent transliterations).
- Do not translate API values, enum names, or status codes that are matched in code.
- Keep the same meaning and level of detail as the English string; do not shorten warnings or legal
  text. If English says "within 24 hours", Arabic must say that too.
- Money and counters stay Western Arabic numerals (`1,200`) to match existing screens; currency is
  `ر.س`.
- Preserve placeholders exactly: `{}`, `{0}`, `%s` — a missing or renamed placeholder breaks `.tr(args:)`.

## 4. Interpolation and formatting

Existing precedent (`lib/features/cars/presentation/widget/otp_bottom_sheet.dart`):

```dart
Text(AppLocaleKey.enterOtpMessage.tr(args: [widget.phoneNumber]))
```

- JSON: `"enterOtpMessage": "Enter the code sent to {}"` / `"أدخل الرمز المرسل إلى {}"`.
- Money and counters: the design uses Latin digits in both languages. Format prices/installments with
  `NumberFormat('#,##0', 'en_US')` (or `'#,##0.##'` when decimals matter), as the majority of the
  app does. `NumberFormat(..., context.locale.languageCode)` produces Arabic-Indic digits (١٢٣) for
  `ar` and will not match the cards around it. Dates may use the active locale; currency text goes
  through `CustomSarText` or the `sar` key, never a hand-written string.
- If the surrounding widget already formats a number a certain way, copy that widget rather than
  introducing a second convention.
- Plurals: `easy_localization` supports `plural`; define all forms the language needs (Arabic has
  zero/one/two/few/many/other). If the string has a count, do not fake it with `"items"`.

## 5. What must never be literal

Text, `hintText`, `labelText`, `helperText`, `errorText`, `tooltip`, `Semantics.label`,
`SnackBar`/`BotToast` messages, empty-state titles, dialog buttons, app bar titles, and tab labels.

Allowed literals: `'car'`-style debug logs, API keys, route names, test data, and non-user-facing
internal identifiers.

## 6. Server and error messages

- `ServerFailure.errMessage` already prefers the server's localized `message` (the `lang` header does
  the rest). Display it as-is.
- Localize only your own fallbacks (offline, unexpected, validation) — `tryAgain`,
  `noInternetConnection`, `pleaseCheckYourInternet` already exist.
- Do not wrap a server message in `.tr()`; it will look up a key that does not exist and render the
  raw key.

## 7. RTL is part of translation work

When you touch a screen for localization, check:

- Layout flips correctly (no clipped text, no overlapping icons).
- Directional arrows/chevrons flip (see `flutter-widgets` §7).
- Latin input fields stay LTR.
- Long Arabic labels do not overflow fixed-height containers.
- `AppLocaleKey.seeAll`-style short strings still fit.

Use the in-app language switcher (or `context.setLocale(const Locale('ar'))`) to verify; do not assume.

## 8. Audit commands

Use the bundled audit script instead of ad-hoc greps. It resolves `AppLocaleKey` constants to their
JSON values, so it catches the "constant exists but JSON key does not" bug that a name-only grep
misses:

```bash
python3 .opencode/skills/flutter-localization/scripts/i18n_audit.py
python3 .opencode/skills/flutter-localization/scripts/i18n_audit.py --json   # machine-readable
```

It reports, in order:

1. `AppLocaleKey` values missing from `en.json` and `ar.json`
2. keys present in one locale but not the other
3. duplicate JSON keys (a silent override)

Exit code is non-zero when anything is missing. Known debt at the time of writing (2026-10-23):

- 25 `AppLocaleKey` values missing from `en.json`; 21 missing from `ar.json` — the script prints the
  exact list. Some are new agent/admin keys that have never had translations.
- 5 keys in `ar.json` missing from `en.json`: `cancelReservationNo`, `employees`, `representative`,
  `search_car_hint`, `suppliers`.
- 2 keys in `en.json` missing from `ar.json`: `agentDetails`, `split_payment`.
- `brands` in Arabic has leading/trailing spaces (`" الماركات "`).

Only fix gaps that your change touches. Bulk-adding 20 unrelated translations is a separate review
pass; note it in the report instead.

## 9. Handoff

- ← `flutter-widgets`: the list of visible strings and their context (button, hint, error).
- → `flutter-widgets`: the exact key names and whether the label length changed materially.
- → `flutter-refactor`: any key you renamed or removed, with all call sites.
- → `flutter-codebase`: if a new section/feature needs a new block in `app_locale_keys.dart`.

See `references/i18n-workflow.md` for the glossary, formatting script, and worked example.
