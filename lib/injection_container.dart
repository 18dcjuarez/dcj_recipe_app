import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/data/xport_data.dart';
import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/bloc/xport_bloc_file.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Recipes
  // Bloc
  sl.registerFactory(
    () => RecipesBloc(
      getRecipes: sl(),
      searchRecipes: sl(),
      toggleFavorite: sl(),
      getFavoriteRecipes: sl(),
      getCategories: sl(),
      getRecipesByCategory: sl(),
      getRandomRecipes: sl(),
      getRecipeById: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRecipes(sl()));
  sl.registerLazySingleton(() => GetRecipeById(sl()));
  sl.registerLazySingleton(() => SearchRecipes(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));
  sl.registerLazySingleton(() => GetFavoriteRecipes(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetRecipesByCategory(sl()));
  sl.registerLazySingleton(() => GetRandomRecipes(sl()));

  // Repository
  sl.registerLazySingleton<RecipesRepository>(
    () => RecipesRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<RecipesRemoteDataSource>(
    () => RecipesRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<RecipesLocalDataSource>(
    () => RecipesLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  final dio = Dio();
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
  sl.registerLazySingleton(() => dio);

  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton(() => Connectivity());
}
