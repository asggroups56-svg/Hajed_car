# Feature Scaffold — copy-ready templates

These templates match the current conventions in `lib/features/home`. Replace `<Feature>` with the
PascalCase feature name and `<feature>` with the snake_case directory name.

## 1. Model — `data/model/<name>_model.dart`

```dart
import 'dart:convert';

import 'package:equatable/equatable.dart';

class <Name>Model extends Equatable {
  final int? code;
  final String? name;

  const <Name>Model({this.code, this.name});

  factory <Name>Model.fromJson(Map<String, dynamic> json) {
    return <Name>Model(
      code: json['CODE'],
      name: json['NAME']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'CODE': code, 'NAME': name};

  static List<<Name>Model> listFromResponse(dynamic data) {
    if (data == null) return [];
    final List<dynamic> jsonList = data is String ? jsonDecode(data) : data;
    return jsonList.map((e) => <Name>Model.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  List<Object?> get props => [code, name];
}
```

Only add `toJson`/`copyWith`/`toString` when the model is sent to the API or copied locally.

## 2. Repository — `data/repository/<feature>_repo.dart`

```dart
import 'package:car/core/error/failures.dart';
import 'package:car/core/network/end_points.dart';
import 'package:car/core/network/handle_dio_request.dart';
import 'package:dartz/dartz.dart';

abstract interface class <Feature>Repo {
  Future<Either<Failure, List<<Name>Model>>> getItems();
}

class <Feature>RepoImpl implements <Feature>Repo {
  final ApiConsumer apiConsumer;

  <Feature>RepoImpl(this.apiConsumer);

  @override
  Future<Either<Failure, List<<Name>Model>>> getItems() {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.getItems);
        return <Name>Model.listFromResponse(response['Data']);
      },
    );
  }
}
```

If you import both `failures.dart` and `handle_dio_request.dart`, hide the duplicate symbol:
`import 'package:car/core/error/failures.dart' hide handleDioRequest;` (precedent:
`lib/features/auth/data/repository/auth_repo.dart`).

## 3. Cubit — `presentation/cubit/<feature>_cubit.dart`

```dart
import 'package:car/core/network/status.state.dart';
import 'package:car/features/<feature>/data/model/<name>_model.dart';
import 'package:car/features/<feature>/data/repository/<feature>_repo.dart';
import 'package:equatable/equatable.dart';

part '<feature>_state.dart';

class <Feature>Cubit extends Cubit<<Feature>State> {
  final <Feature>Repo repo;

  <Feature>Cubit(this.repo) : super(const <Feature>State());

  Future<void> getItems() async {
    emit(state.copyWith(itemsStatus: const StatusState.loading()));

    final result = await repo.getItems();

    result.fold(
      (failure) => emit(
        state.copyWith(
          itemsStatus: StatusState.failure(
            failure.errMessage,
            statusCode: failure.statusCode,
          ),
        ),
      ),
      (items) => emit(state.copyWith(itemsStatus: StatusState.success(items))),
    );
  }
}
```

## 4. State — `presentation/cubit/<feature>_state.dart`

```dart
part of '<feature>_cubit.dart';

class <Feature>State extends Equatable {
  final StatusState<List<<Name>Model>> itemsStatus;

  const <Feature>State({this.itemsStatus = const StatusState.initial()});

  <Feature>State copyWith({StatusState<List<<Name>Model>>? itemsStatus}) {
    return <Feature>State(itemsStatus: itemsStatus ?? this.itemsStatus);
  }

  @override
  List<Object?> get props => [itemsStatus];
}
```

## 5. Screen — `presentation/view/screen/<feature>_screen.dart`

```dart
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/services/services_locator.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/<feature>/presentation/cubit/<feature>_cubit.dart';
import 'package:car/features/<feature>/presentation/view/widgets/<name>_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class <Feature>Screen extends StatelessWidget {
  const <Feature>Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<<Feature>Cubit>()..getItems(),
      child: Scaffold(
        backgroundColor: AppColor.scaffoldColor(context),
        appBar: CustomAppBar(
          context,
          title: Text(
            AppLocaleKey.<feature>Title.tr(),
            style: AppTextStyle.appBarStyle(context),
          ),
        ),
        body: const <Name>Widget(),
      ),
    );
  }
}
```

`AppHeader` is a home-feature widget (`presentation/view/widgets/app_header_popular_widget.dart`),
not a core one — use `CustomAppBar` for new screens outside home.

If the cubit is app-wide, omit `BlocProvider` and read it from the tree instead.

## 6. Registration points

`lib/core/services/services_locator_imports.dart`

```dart
sl.registerLazySingleton<<Feature>Repo>(() => <Feature>RepoImpl(sl()));
// only for app-wide cubits:
sl.registerLazySingleton<<Feature>Cubit>(() => <Feature>Cubit(sl()));
```

`lib/core/routes/routes_name.dart`

```dart
static const String <feature>Screen = '<feature>Screen';
```

`lib/core/routes/app_routers.dart`

```dart
case RoutesName.<feature>Screen:
  return MaterialPageRoute(builder: (_) => const <Feature>Screen());
```

`lib/app.dart` (only app-wide cubits)

```dart
BlocProvider(create: (context) => sl<<Feature>Cubit>()),
```

## 7. Test — `test/<feature>_cubit_test.dart`

Follow `test/notifications_cubit_test.dart`: fake the repo with a small class, construct the cubit,
assert emitted states with `blocTest` or by collecting `cubit.stream`.

## 8. Checklist before handing off

- [ ] Directory layout matches `home`.
- [ ] All files `snake_case.dart`; classes PascalCase; state is a `part` file.
- [ ] Repo takes `ApiConsumer` via constructor; no `Dio` inside.
- [ ] Cubit registered only if app-wide.
- [ ] Route name constant + `app_routers` case added.
- [ ] Imports use `package:car/...` across features.
- [ ] `flutter analyze` on the new folder reports no new issues.
