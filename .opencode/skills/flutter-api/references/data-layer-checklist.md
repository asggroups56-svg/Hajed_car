# Data Layer Checklist — worked example

Goal: add "search banks" to the home feature. Follow the same order every time.

## Step 0 — Confirm the contract

You need three facts before writing code:

1. HTTP method and path. Example: `GET DeltagroupService/Cars/FillPopup` exists as
   `EndPoints.customer`.
2. Query/body parameter names and casing. Example: `Searchval`, `TableName`.
3. Response shape. In this repo the safe assumption is `{"Data": <list | json-string | null>}`,
   but confirm by reading a sibling method or the server response.

If any of the three is unknown, ask the user or inspect an existing call. Do not invent keys — this
server silently returns empty data for wrong casing.

## Step 1 — Endpoint

Reuse if present:

```dart
static const String customer = 'DeltaGroup/Search/FillPopup';
```

Otherwise add a camelCase constant next to the related ones. No base URL, no query string.

## Step 2 — Model

`lib/features/home/data/model/bank_search_result_model.dart`

```dart
import 'dart:convert';

import 'package:equatable/equatable.dart';

class BankSearchResultModel extends Equatable {
  final int? code;
  final String? name;

  const BankSearchResultModel({this.code, this.name});

  factory BankSearchResultModel.fromJson(Map<String, dynamic> json) {
    return BankSearchResultModel(
      code: json['BANK_CODE'],
      name: json['BANK_NAME']?.toString(),
    );
  }

  static List<BankSearchResultModel> listFromResponse(dynamic data) {
    if (data == null) return [];
    final List<dynamic> jsonList = data is String ? jsonDecode(data) : data;
    return jsonList
        .map((e) => BankSearchResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<Object?> get props => [code, name];
}
```

## Step 3 — Repo method

Interface first, then implementation. Return `Either`, never throw.

```dart
// in HomeRepo
Future<Either<Failure, List<BankSearchResultModel>>> searchBanks(String query);

// in HomeRepoImpl
@override
Future<Either<Failure, List<BankSearchResultModel>>> searchBanks(String query) {
  return handleDioRequest(
    request: () async {
      final response = await apiConsumer.get(
        EndPoints.customer,
        queryParameters: {'Searchval': query, 'TableName': 'sp_BANKS_DATA_search_sel'},
      );
      return BankSearchResultModel.listFromResponse(response['Data']);
    },
  );
}
```

Do **not** add a `try/catch`; `handleDioRequest` maps `DioException` into `ServerFailure` and keeps
the server message.

## Step 4 — Cubit method

```dart
Future<void> searchBanks(String query) async {
  emit(state.copyWith(bankSearchStatus: const StatusState.loading()));
  final result = await repo.searchBanks(query);
  if (isClosed) return;
  result.fold(
    (failure) => emit(state.copyWith(
      bankSearchStatus: StatusState.failure(
        failure.errMessage,
        statusCode: failure.statusCode,
      ),
    )),
    (banks) => emit(state.copyWith(bankSearchStatus: StatusState.success(banks))),
  );
}
```

Add `final StatusState<List<BankSearchResultModel>> bankSearchStatus;` to the state class, its
constructor default, `copyWith`, and `props`.

If the search fires on every keystroke, add a debounce in the widget and a request-id guard in the
cubit (copy `_brandCarsRequestId` from `getBrandCars`).

## Step 5 — Widget

- `BlocBuilder` with `buildWhen` on the single status field.
- Loading → `CustomLoading(size: 24)` inside the search area.
- Failure → `ExceptionWidget(message: state.bankSearchStatus.error, onReload: ...)`.
- Success + empty → `NoDataWidget(message: AppLocaleKey.noResults.tr())` (key added to both locales).
- Success → the list widget, extracted into its own file.

## Step 6 — Files touched

```
lib/core/network/end_points.dart                          (only if new)
lib/features/home/data/model/bank_search_result_model.dart  (new)
lib/features/home/data/repository/home_repo.dart            (interface + impl)
lib/features/home/presentation/cubit/home_cubit.dart        (method)
lib/features/home/presentation/cubit/home_state.dart        (status field)
lib/features/home/presentation/view/widgets/...             (consumer)
lib/core/localization/app_locale_keys.dart                  (new key)
i18n/ar.json, i18n/en.json                                  (same key)
```

## Response-shape reference

| Server sends                                  | Handling |
| --------------------------------------------- | -------- |
| `{"Data": [ {...} ]}`                         | `listFromResponse(response['Data'])` |
| `{"Data": "[{...}]"}` (stringified JSON)      | `listFromResponse` decodes it |
| `{"data": [...]}` (lowercase)                 | scan keys case-insensitively (`getNotificationsData`) |
| `{"Data": "null"}` / `{"Data": null}`         | return `[]` |
| `{"Data": {...}}` single object               | `XModel.fromJson(response['Data'])` |
| 500 with a valid `Data` payload               | deliberately handled only in `fetchAllCars`; add a comment if repeated |
| CSV-ish or HTML error page                    | let `ServerFailure` produce a fallback message; do not parse |

## Auth and locale reference

`AppInterceptors.onRequest` injects:

```
lang: 'en-GB' | 'ar'
Authorization: Bearer <Hive token>     (unless extra['skipAuth'] == true)
Content-Type: x-www-form-urlencoded    (unless body is FormData)
```

`AppInterceptors.onError` refreshes the token once on 401 via `EndPoints.refreshToken`, updates Hive,
and retries the original request. Repos and cubits must not implement refresh logic.
