part of 'services_locator.dart';

final sl = GetIt.instance;
Future<void> initDependencies() async {
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<AppInterceptors>(() => AppInterceptors());
  final Dio dio = Dio();
  await setupCert(dio);
  sl.registerLazySingleton<Dio>(() => dio);
  sl.registerFactory<ApiConsumer>(() => DioConsumer(client: sl()));
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl()));
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl()));
  sl.registerLazySingleton<FavoritesCubit>(() => FavoritesCubit());
  sl.registerLazySingleton<HomeRepo>(() => HomeRepoImpl(sl()));
  sl.registerLazySingleton<HomeCubit>(() => HomeCubit(sl()));
  sl.registerLazySingleton<AdminRepo>(() => AdminRepoImp(apiConsumer: sl()));
  sl.registerLazySingleton<AdminCubit>(() => AdminCubit(sl()));
  sl.registerLazySingleton<AgentRepo>(() => AgentImplRepo(sl()));
  sl.registerLazySingleton<AgentCubit>(() => AgentCubit(sl()));
  // CartCubit needs AdminRepo (to fetch reserved cars) and HomeRepo (to cancel reservations).
  sl.registerLazySingleton<CartCubit>(() => CartCubit(adminRepo: sl(), homeRepo: sl()));
}
