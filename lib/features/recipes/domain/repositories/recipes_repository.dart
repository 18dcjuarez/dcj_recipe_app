import 'package:dartz/dartz.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

abstract class RecipesRepository {
  Future<Either<Failure, List<Recipe>>> getRecipes({int page = 1});
  Future<Either<Failure, Recipe>> getRecipeById(String id);
  Future<Either<Failure, List<Recipe>>> searchRecipes(String query);
  Future<Either<Failure, List<Recipe>>> getRecipesByCategory(String category);
  Future<Either<Failure, List<String>>> getCategories();
  Future<Either<Failure, Recipe>> toggleFavorite(Recipe recipe);
  Future<Either<Failure, List<Recipe>>> getFavoriteRecipes();
  Future<Either<Failure, List<Recipe>>> getRandomRecipes({int count = 10});
}
