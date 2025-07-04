import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/data/xport_data.dart';

abstract class RecipesLocalDataSource {
  Future<List<RecipeModel>> getFavoriteRecipes();
  Future<void> addFavoriteRecipe(RecipeModel recipe);
  Future<void> removeFavoriteRecipe(String recipeId);
  Future<bool> isFavorite(String recipeId);
  Future<List<RecipeModel>> getCachedRecipes();
  Future<void> cacheRecipes(List<RecipeModel> recipes);
  Future<RecipeModel?> getCachedRecipeById(String id);
  Future<void> cacheRecipe(RecipeModel recipe);
  Future<void> clearCache();
}

class RecipesLocalDataSourceImpl implements RecipesLocalDataSource {
  static const String _favoriteRecipesKey = 'FAVORITE_RECIPES';
  static const String _cachedRecipesKey = 'CACHED_RECIPES';
  static const String _cachedRecipePrefix = 'CACHED_RECIPE_';

  final SharedPreferences sharedPreferences;

  RecipesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<RecipeModel>> getFavoriteRecipes() async {
    try {
      final jsonString = sharedPreferences.getString(_favoriteRecipesKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((jsonMap) => RecipeModel.fromJson(jsonMap, isFavorite: true))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw CacheException(
          message: 'Error getting favorite recipes: ${e.toString()}');
    }
  }

  @override
  Future<void> addFavoriteRecipe(RecipeModel recipe) async {
    try {
      final favorites = await getFavoriteRecipes();

      final exists = favorites.any((r) => r.id == recipe.id);
      if (!exists) {
        favorites.add(recipe.copyWith(isFavorite: true));
        final jsonString = json.encode(
          favorites.map((recipe) => recipe.toJson()).toList(),
        );
        await sharedPreferences.setString(_favoriteRecipesKey, jsonString);
      }
    } catch (e) {
      throw CacheException(
          message: 'Error adding favorite recipe: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFavoriteRecipe(String recipeId) async {
    try {
      final favorites = await getFavoriteRecipes();
      favorites.removeWhere((recipe) => recipe.id == recipeId);

      final jsonString = json.encode(
        favorites.map((recipe) => recipe.toJson()).toList(),
      );
      await sharedPreferences.setString(_favoriteRecipesKey, jsonString);
    } catch (e) {
      throw CacheException(
          message: 'Error removing favorite recipe: ${e.toString()}');
    }
  }

  @override
  Future<bool> isFavorite(String recipeId) async {
    try {
      final favorites = await getFavoriteRecipes();
      return favorites.any((recipe) => recipe.id == recipeId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<RecipeModel>> getCachedRecipes() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedRecipesKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final recipes = <RecipeModel>[];

        for (final jsonMap in jsonList) {
          final isFav = await isFavorite(jsonMap['idMeal']);
          recipes.add(RecipeModel.fromJson(jsonMap, isFavorite: isFav));
        }

        return recipes;
      } else {
        throw CacheException(message: 'No cached recipes found');
      }
    } catch (e) {
      throw CacheException(
          message: 'Error getting cached recipes: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheRecipes(List<RecipeModel> recipes) async {
    try {
      final jsonString = json.encode(
        recipes.map((recipe) => recipe.toJson()).toList(),
      );
      await sharedPreferences.setString(_cachedRecipesKey, jsonString);
    } catch (e) {
      throw CacheException(message: 'Error caching recipes: ${e.toString()}');
    }
  }

  @override
  Future<RecipeModel?> getCachedRecipeById(String id) async {
    try {
      final jsonString = sharedPreferences.getString('$_cachedRecipePrefix$id');

      if (jsonString != null) {
        final jsonMap = json.decode(jsonString);
        final isFav = await isFavorite(id);
        return RecipeModel.fromJson(jsonMap, isFavorite: isFav);
      } else {
        return null;
      }
    } catch (e) {
      throw CacheException(
          message: 'Error getting cached recipe: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheRecipe(RecipeModel recipe) async {
    try {
      final jsonString = json.encode(recipe.toJson());
      await sharedPreferences.setString(
        '$_cachedRecipePrefix${recipe.id}',
        jsonString,
      );
    } catch (e) {
      throw CacheException(message: 'Error caching recipe: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final keys = sharedPreferences.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachedRecipePrefix) || key == _cachedRecipesKey) {
          await sharedPreferences.remove(key);
        }
      }
    } catch (e) {
      throw CacheException(message: 'Error clearing cache: ${e.toString()}');
    }
  }
}
