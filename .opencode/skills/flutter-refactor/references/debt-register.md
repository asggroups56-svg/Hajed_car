# Debt Register — verified inventory

Measured on the current tree. Re-measure before acting; the user's work-in-progress changes these
numbers.

## 1. Duplicate symbols (highest risk — they break imports)

| Symbol | Files | Reality |
| ------ | ----- | ------- |
| `handleDioRequest` | `core/error/failures.dart:131`, `core/network/handle_dio_request.dart:7` | Identical contract, different logging. `home_repo` uses the `failures.dart` one; `auth_repo` imports the network one and hides the other. |
| `FavoriteButton` | `.../widgets/favorite_button.dart`, `.../widgets/favorite_button_widget.dart` | Two classes with the same name. `favorite_button_widget.dart` has **no importers** — orphan. `favorite_button.dart` is used by `card_image_section.dart`. |
| `CardImageSection` | `.../widgets/card_image_section.dart` (Stateless, 51 lines), `.../widgets/card_image_section_widget.dart` (Stateful, 230 lines) | Two different implementations. `car_card_widget` imports the Stateful one; `offer_card_widget` imports the Stateless one. Importing both in one file is a compile error. |
| `FavoritesButton` | `.../widgets/favorites_button.dart` | Separate class used by `card_top_bar_widget`. Not a duplicate; do not merge with `FavoriteButton` without checking both UIs. |

Safety rule: never import two files that export the same class name. When consolidating, grep
`import .*<file>` and update every importer in the same change.

## 2. Size / responsibility

| File | Lines | Observation |
| ---- | ----- | ----------- |
| `features/home/data/repository/home_repo.dart` | 696 | Cars, banks, financing, notifications, FCM, WhatsApp, loans in one interface. |
| `features/home/presentation/cubit/home_cubit.dart` | 621 | 18 status fields, request de-duplication, reservation bookkeeping. |
| `features/home/presentation/view/widgets/` | 60+ files | `BanksSliderWidget` reads `banksStatus` but is not mounted on the home screen; several near-duplicate cards/buttons. |
| `features/home/presentation/view/widgets/ad_card_widget.dart` | 350 | Card composition plus formatting helpers; already split into sub-widgets, remaining size is layout. |
| `core/localization/app_locale_keys.dart` | 1789 | 76 snake_case constants mixed with camelCase. Not urgent; rename only with call-site updates. |

Split candidates in order of value:

1. `home_repo` → `CarsRepo`, `FinancingRepo`, `BookingRepo` (+ keep `HomeRepo` as a façade so nothing
   else changes in the same step).
2. `home_cubit` → per-domain cubits only after the repo split, and only if a screen actually benefits;
   otherwise keep one state and extract pure helpers.
3. `ad_card_widget` → only if a visual change requires it; splitting layout for its own sake adds
   parameters without reducing complexity.

## 3. Status abstractions

| Abstraction | Where | Used by |
| ----------- | ----- | ------- |
| `StatusState<T>` | `core/network/status.state.dart` | home, agent, admin, most newer screens |
| `CubitStatus` + `ApiResponseWidget` | `core/enum/cubit_state.dart`, `core/custom_widgets/api_response_widget/` | profile, services, older screens |

Unifying them is a cross-cutting change with high regression risk (loading/empty/offline rendering
differs). Convert one screen at a time, and only when that screen is already being changed for another
reason. New code always uses `StatusState`.

## 4. Localization

Run `.opencode/skills/flutter-localization/scripts/i18n_audit.py` for the live numbers. On
2026-10-23:

- 25 `AppLocaleKey` values missing from `en.json`, 21 from `ar.json` (mostly new agent/admin keys).
- `en.json` missing 5 keys that exist in `ar.json`: `cancelReservationNo`, `employees`,
  `representative`, `search_car_hint`, `suppliers`.
- `ar.json` missing 2 keys that exist in `en.json`: `agentDetails`, `split_payment`.
- `brands` in Arabic has leading/trailing spaces (`" الماركات "`).
- `brand_cars_data_model.dart` returns localized labels from the data layer (`.tr()` in a model).

## 5. Lints / deprecations (baseline ~406 issues)

Mostly non-blocking infos: `withOpacity` deprecation across custom widgets, `constant_identifier_names`
in `app_locale_keys.dart`, `file_names` for `fAQ_Item_widget.dart`, `use_build_context_synchronously`
in a few screens, unused local variables. `flutter analyze` (whole repo) reported 406 issues on
2026-10-23.

Do not chase these globally. Replace `withOpacity` in files you touch; treat a rename of
`fAQ_Item_widget.dart` as a separate mechanical change (two imports + file move).

## 6. Suggested order of attack

1. Delete `favorite_button_widget.dart` (0 importers) — smallest, provable.
2. Consolidate `CardImageSection` after deciding which behavior is correct — needs a visual check of
   both call sites.
3. Remove the duplicate `handleDioRequest` and the `hide` clause in `auth_repo`.
4. Fix i18n parity in a dedicated diff.
5. Only then consider the `home_repo` / `home_cubit` split, as a proposed multi-step plan.

## 7. Measurement commands

```bash
# who imports a widget file
grep -rn "import.*card_image_section" lib

# class defined twice?
grep -rn "^class FavoriteButton" lib

# size of the hot files
wc -l lib/features/home/data/repository/home_repo.dart \
      lib/features/home/presentation/cubit/home_cubit.dart

# i18n parity
python3 - <<'PY'
import json
ar=json.load(open('i18n/ar.json')); en=json.load(open('i18n/en.json'))
print('missing in en:', sorted(set(ar)-set(en)))
print('missing in ar:', sorted(set(en)-set(ar)))
PY
```

## 8. Not debt

- Context-based color/text getters (`AppColor.x(context)`) look verbose but are the dark-mode mechanism.
- The `lang`/`Authorization` headers in `AppInterceptors` belong there, not in repos.
- `EndPoints.sendWhatsAppPdf` and `EndPoints.sendPdf` share a path — legacy, harmless; do not add a
  third constant.
- The untyped `arguments` in routes is legacy; do not convert routes to typed arguments inside an
  unrelated task.
