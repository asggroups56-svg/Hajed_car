# Bank search — with skills

## Built
- `BanksSearchFieldWidget`: themed search field with localized hint and a clear button.
- `BanksSectionWidget`: owns the 400 ms debounce, calls `HomeCubit.searchBanks`, and renders loading, failure, empty and success states around the existing `BanksSliderWidget`.
- `guest_home_screen.dart`: mounts the section below the popular-cars slider; the existing slider file is untouched.
- `HomeCubit.searchBanks(String)`: reuses the existing `getBanks(searchVal:)` repository operation, normalises blank queries to restore all banks, and adds a `_banksRequestId` stale-response guard with an `isClosed` check.
- 3 keys in `AppLocaleKey` and both JSON files: `searchBanksHint`, `searchBanksClear`, `noBanksFound`.

## Verification
Touched home cubit/screen/new widgets: no issues. `app_locale_keys.dart`: 82 pre-existing infos, no new issues.

## Not verified
No device run; visual, RTL, keyboard and dark mode not manually checked. No tests.

## Known gap
`refreshHomeData()` still calls `getBanks()` without the active query while the field keeps its text, so an app-resume refresh can show the unfiltered list under a search term. The fix is to store the query in `HomeState` and pass it to refresh.
