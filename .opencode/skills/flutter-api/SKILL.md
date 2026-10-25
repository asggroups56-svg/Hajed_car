---
name: flutter-api
description: Hajed_car API and data-layer workflow — adding endpoints, writing models that survive this server's JSON quirks, implementing repositories with Either/Failure, and wiring Cubit status states for loading, success, and error. Use this skill whenever a task involves calling an API, adding or changing a model, handling a server error, uploading files, or showing network-driven state in the UI, even if the user only says "make this screen show real data".
---

# API & Data Layer — Hajed_car

The server is a Delphi/ASP.NET-style API (`https://delta-asg.com:54513/`) that returns inconsistent
shapes. The job of this layer is to absorb that inconsistency so widgets only see typed data and
`StatusState`.

## 1. The chain

```
EndPoints constant → model (+ listFromResponse) → XRepo interface → XRepoImpl
      → XCubit method (StatusState) → widget (isLoading / isSuccess / isFailure)
```

Never skip a link. A widget must never call `ApiConsumer`, and a repo must never emit state.

## 2. Endpoints — `lib/core/network/end_points.dart`

- One `static const String` per operation, camelCase name, path only (base URL comes from
  `AppConfig.baseUrl` via `Constants.baseUrl`).
- Reuse an existing constant if the operation already exists. `sendWhatsAppPdf` and `sendPdf` already
  point at the same path — do not add a third.
- Never hardcode a URL in a repo or widget, and never put query strings in the endpoint constant.
- Language and auth are headers, not query parameters: `AppInterceptors` adds `lang` and
  `Authorization: Bearer <token>` automatically. Do not set either by hand.

## 3. `ApiConsumer` surface

`lib/core/network/api_consumer.dart` — all methods return the decoded body (`response.data`):

```dart
get(path, {queryParameters, body, headers, extra})
post/put/delete(path, {body, queryParameters, headers, extra, isFormData})
```

- `extra` flags consumed by interceptors: `'skipAuth': true`, `'allowUnauthorized': true`.
- `isFormData: true` converts a `Map` body into `FormData` (`DioConsumer._processBody`). For real
  files, build `FormData` yourself and pass `isFormData: true` (see `addLoanApplicationWithFiles`,
  which uses `file_0`, `file_1`, … keys and explicit `DioMediaType`).
- Default content type is `application/x-www-form-urlencoded` unless the body is `FormData`.
  This matters: plain JSON bodies are *not* sent as JSON by default.

## 4. Error handling

Wrap every request in `handleDioRequest` and return `Future<Either<Failure, T>>`:

```dart
return handleDioRequest(
  request: () async {
    final response = await apiConsumer.get(EndPoints.getBanks, queryParameters: {...});
    return BANKSDATAModel.listFromResponse(response['Data']);
  },
);
```

- `ServerFailure.fromDioError` already extracts a server `message`/`msg`/`error`/`title` field, then
  falls back per `DioExceptionType` and status code. Do not re-implement message extraction in a repo.
- The helper exists in **two** files: `core/error/failures.dart` and
  `core/network/handle_dio_request.dart`. `home_repo.dart` imports only `failures.dart`;
  `auth_repo.dart` imports `handle_dio_request.dart` plus `failures.dart hide handleDioRequest`.
  Pick one style per file and never import both without `hide`.
- Surface `failure.statusCode` in the cubit state when the UI branches on 401/404 (see
  `addBookingPermissionResponseModel` in `home_cubit.dart`).
- Do not swallow a failure to return fake data. The one deliberate exception is `fetchAllCars`, which
  parses `Data` out of a 500 response because this server returns inventory that way; if you copy that
  pattern, comment why.

## 5. Model rules

- `extends Equatable`, `const` constructor, nullable fields, `props` listing every field.
- Copy API keys **exactly** (`BANK_CODE`, `P_O_BOX`, `FUEL_TYPE`). Never "normalize" them.
- Always provide `static List<X> listFromResponse(dynamic data)` for list endpoints. It must tolerate:
  - `null` → `[]`
  - `List<dynamic>`
  - a JSON **string** (`jsonDecode` first — this server does it often)
- Envelope handling:
  - Usually `response['Data']`.
  - Some endpoints return lowercase `data` or a bare list; `getCustLoanApplications` and
    `getNotificationsData` scan case-insensitively. Reuse that helper style rather than guessing.
  - A response body may be `'null'` as a string — check `!= 'null'` before decoding.
- Numbers: cast defensively (`(json['X'] as num?)?.toDouble()`, `int.tryParse`).
- Request models add `toJson()`; response models do not need one.
- Do not put UI text or `.tr()` in new models. `brand_cars_data_model.dart` currently does this for
  status labels; leave it alone unless the task is to fix it, and never add more.

## 6. Repository rules

- `abstract interface class XRepo` + `class XRepoImpl implements XRepo`.
- Constructor injection: `XRepoImpl(this.apiConsumer);` — `ApiConsumer` is provided by GetIt (`sl()`).
- One method per server operation, named for the operation (`getBanks`, `addBookingPermission`),
  returning `Either<Failure, T>`.
- Optional parameters mirror the query names the server expects, but name them idiomatically in Dart
  (`fromPrice`, not `fromprice`).
- Headers that are genuinely per-request (e.g. `'username': Uri.encodeComponent(userName)`) are allowed;
  auth/lang/JSON headers are not the repo's business.
- Register the repo in `services_locator_imports.dart`. Register the cubit there only if it is app-wide.

## 7. Cubit wiring

```dart
Future<void> getBanks({String? searchVal}) async {
  final requestId = ++_banksRequestId;
  emit(state.copyWith(banksStatus: const StatusState.loading()));
  final result = await repo.getBanks(searchVal);

  // Two different guards, both needed:
  // - requestId: a slow older response must not overwrite a newer query.
  // - isClosed: the app-wide cubit may outlive this screen.
  if (isClosed || requestId != _banksRequestId) return;

  result.fold(
    (failure) => emit(state.copyWith(banksStatus: StatusState.failure(failure.errMessage))),
    (banks) => emit(state.copyWith(banksStatus: StatusState.success(banks))),
  );
}
```

- One `<operation>Status` field per operation in the state class. Reuse an existing status when the
  operation is genuinely the same; do not add a second status that mirrors it.
- Emit `loading` before the `await`; guard the emit after the await. `requestId` prevents
  out-of-order responses; `isClosed` prevents emitting into a disposed cubit. They solve different
  failures, so a long-running or repeatable action usually needs both.
- Guard races when a user can tap faster than the network (see `_brandCarsRequestId` in
  `HomeCubit.getBrandCars`).
- Deduplicate in-flight requests when many widgets would otherwise trigger the same call (see
  `_normalFinancingRequest` in `HomeCubit.getNormalFinancing`).
- **A user filter is state, not a widget detail.** If a screen both auto-refreshes a list and lets the
  user filter it, a refresh must either reapply the active filter or clear it together with the
  field. Otherwise the field can show "Al Rajhi" while the list behind it is the unfiltered
  `refreshHomeData()` result. Store the active query in the state class and pass it to the refresh
  call; do not leave the query only in a `TextEditingController`. This exact mismatch appeared in the
  bank-search eval.
- Keep display formatting out of the cubit; keep it in the widget or a model helper.

## 8. Consuming state in the UI

New code:

```dart
BlocBuilder<HomeCubit, HomeState>(
  buildWhen: (p, c) => p.banksStatus != c.banksStatus,
  builder: (context, state) {
    if (state.banksStatus.isLoading) return const CustomLoading(size: 35);
    if (state.banksStatus.isFailure) {
      return ExceptionWidget(message: state.banksStatus.error, onReload: () => ...);
    }
    final banks = state.banksStatus.data ?? const [];
    if (banks.isEmpty) return const NoDataWidget();
    return BanksSliderWidget(banks: banks);
  },
)
```

Legacy screens use `CubitStatus` + `ApiResponseWidget(cubitStatus:, child:, isEmpty:, onReload:)`.
Do not add new `CubitStatus` usage.

For one-off feedback use `CommonMethods.showToast(message: ..., type: ToastType.success)`; it wraps
`BotToast` + `CustomToast`. Show server messages as-is (they are already localized by the `lang`
header) and localize only your own fallback strings.

## 9. Anti-patterns to reject

- `Dio()` or `http.get` inside a repo, cubit, or widget.
- `try/catch` around a repo call that returns `Either` — use `fold`.
- Returning `[]` on failure so the UI shows "no data" instead of the real error.
- Duplicating an endpoint string.
- Parsing the same response in both cubit and repo.
- Adding `Authorization`, `lang`, or `Content-Type` headers manually.
- New API calls in `initState` without a matching loading/failure path.

## 10. Verify

- [ ] Endpoint constant added/reused; no literal path in the repo.
- [ ] Model parses `null`, `List`, and JSON-string payloads.
- [ ] Repo returns `Either<Failure, T>` and is registered in GetIt.
- [ ] Cubit emits loading → success/failure, with `statusCode` where it matters.
- [ ] No stale-response or duplicate-request bug for repeatable actions.
- [ ] `flutter analyze` clean for the touched files.
- [ ] Manual check: success path, server error path, offline path (airplane mode or
      `AppInterceptors.isInternet` false).

## 11. Handoff

- ← `flutter-codebase`: the feature path, repo/cubit names, and state fields reserved for you.
- → `flutter-widgets`: the status field names, their data types, and the empty/error semantics the UI
  must render.
- → `flutter-localization`: any new message keys for empty/error states.
- → `flutter-refactor`: new or moved model/repo files, and any endpoint constant you replaced.

See `references/data-layer-checklist.md` for a worked example end to end.
