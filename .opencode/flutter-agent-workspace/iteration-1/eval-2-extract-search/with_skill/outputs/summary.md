# Extract home search — with skills

## Built
- `home_search_bar_widget.dart`: `HomeSearchBarWidget`, stateless, with `onSearchTap` / `onFilterTap` callbacks. Original styling and layout copied.
- `guest_home_screen.dart`: uses the widget with the same behavior: search sets `MainLayout.tabIndex.value = 1`; filter pushes `RoutesName.filterScreen`; hint uses `AppLocaleKey.searchForYourDreamCar.tr()`.
- Removed the unused `_searchController` (never attached to the read-only field) and now-unused theme imports.

## Verification
`flutter analyze` on both touched files: no issues. `flutter analyze lib/features/home`: 64 issues before and after, 0 new.

## Not verified
No device run; rendering/RTL checked by inspection. No tests.
