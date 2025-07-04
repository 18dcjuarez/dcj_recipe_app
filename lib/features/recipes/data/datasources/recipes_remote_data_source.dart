import 'package:dio/dio.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/data/xport_data.dart';

abstract class RecipesRemoteDataSource {
  Future<List<RecipeModel>> getRecipes({int page = 1});
  Future<RecipeModel> getRecipeById(String id);
  Future<List<RecipeModel>> searchRecipes(String query);
  Future<List<RecipeModel>> getRecipesByCategory(String category);
  Future<List<String>> getCategories();
  Future<List<RecipeModel>> getRandomRecipes({int count = 10});
}

class RecipesRemoteDataSourceImpl implements RecipesRemoteDataSource {
  final Dio dio;

  RecipesRemoteDataSourceImpl({required this.dio}) {
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  @override
  Future<List<RecipeModel>> getRecipes({int page = 1}) async {
    try {
      final response = await dio.get('/search.php?s=');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['meals'] != null) {
          return (data['meals'] as List)
              .map((meal) => RecipeModel.fromJson(meal))
              .toList();
        } else {
          return [];
        }
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'No internet connection');
      } else {
        throw ServerException(message: e.message);
      }
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  @override
  Future<RecipeModel> getRecipeById(String id) async {
    try {
      final response = await dio.get('/lookup.php?i=$id');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return RecipeModel.fromJson(data['meals'][0]);
        } else {
          throw NotFoundException(message: 'Recipe not found');
        }
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw UnexpectedException(message: e.toString());
    }
  }

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async {
    try {
      final response = await dio.get('${ApiConstants.searchByName}$query');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['meals'] != null) {
          return (data['meals'] as List)
              .map((meal) => RecipeModel.fromJson(meal))
              .toList();
        } else {
          return [];
        }
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw UnexpectedException(message: e.toString());
    }
  }

  @override
  Future<List<RecipeModel>> getRecipesByCategory(String category) async {
    try {
      final response =
          await dio.get('${ApiConstants.filterByCategory}$category');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['meals'] != null) {
          return (data['meals'] as List)
              .map((meal) => RecipeModel.fromSimplifiedJson(meal))
              .toList();
        } else {
          return [];
        }
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw UnexpectedException(message: e.toString());
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await dio.get(ApiConstants.allCategories);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['categories'] != null) {
          return (data['categories'] as List)
              .map((category) => category['strCategory'] as String)
              .toList();
        } else {
          return [];
        }
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw UnexpectedException(message: e.toString());
    }
  }

  @override
  Future<List<RecipeModel>> getRandomRecipes({int count = 10}) async {
    try {
      final List<RecipeModel> randomRecipes = [];

      final futures = List.generate(
        count,
        (_) => dio.get(ApiConstants.randomRecipe),
      );

      final responses = await Future.wait(futures);

      for (final response in responses) {
        if (response.statusCode == 200) {
          final data = response.data;
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            randomRecipes.add(RecipeModel.fromJson(data['meals'][0]));
          }
        }
      }

      return randomRecipes;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw NetworkException(message: 'Connection timeout');
    } else if (e.type == DioExceptionType.connectionError) {
      throw NetworkException(message: 'No internet connection');
    } else if (e.response?.statusCode == 404) {
      throw NotFoundException(message: 'Resource not found');
    } else {
      throw ServerException(message: e.message);
    }
  }
}
