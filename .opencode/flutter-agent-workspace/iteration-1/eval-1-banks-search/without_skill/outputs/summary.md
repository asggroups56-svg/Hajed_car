# Bank search — without skills

## Built
- `home_cubit.dart`: 350 ms debounce, `_banksRequestId` stale-response guard, `onBanksSearchChanged`, `clearBanksSearch`, empty query restores all banks, debounce cancelled on `close()`.
- `home_state.dart`: added `banksSearchQuery`.
- `banks_search_widget.dart`: compact search field, clear button, loading spinner, translated empty/error states with retry, existing `BanksSliderWidget` underneath.
- `guest_home_screen.dart`: mounted the new section above the brands area.
- 5 locale keys in both JSON files and `AppLocaleKey`.

## Verification
`flutter analyze lib/features/home` and `app_locale_keys.dart`: no errors and no new issues in touched files.

## Notes
The banks slider already existed but was not mounted anywhere on home, so the new section also makes it visible as the anchor for the search field.

## Not verified
No device run; RTL/dark mode not checked. The request-id guard does not check `isClosed`.
