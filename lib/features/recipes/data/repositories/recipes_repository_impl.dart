import 'package:dartz/dartz.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/data/xport_data.dart';
import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class RecipesRepositoryImpl implements RecipesRepository {
  final RecipesRemoteDataSource remoteDataSource;
  final RecipesLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  RecipesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Recipe>>> getRecipes({int page = 1}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRecipes = await remoteDataSource.getRecipes(page: page);

        final recipesWithFavorites = <RecipeModel>[];
        for (final recipe in remoteRecipes) {
          final isFav = await localDataSource.isFavorite(recipe.id);
          recipesWithFavorites.add(recipe.copyWith(isFavorite: isFav));
        }

        await localDataSource.cacheRecipes(recipesWithFavorites);

        return Right(recipesWithFavorites);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on UnexpectedException catch (e) {
        return Left(UnexpectedFailure(message: e.message));
      }
    } else {
      try {
        final localRecipes = await localDataSource.getCachedRecipes();
        return Right(localRecipes);
      } on CacheException catch (e) {
        return Left(NetworkFailure(
            message:
                'No internet connection and no cached data available: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, Recipe>> getRecipeById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRecipe = await remoteDataSource.getRecipeById(id);
        final isFav = await localDataSource.isFavorite(id);
        final recipeWithFavorite = remoteRecipe.copyWith(isFavorite: isFav);

        await localDataSource.cacheRecipe(recipeWithFavorite);

        return Right(recipeWithFavorite);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message));
      } on UnexpectedException catch (e) {
        return Left(UnexpectedFailure(message: e.message));
      }
    } else {
      try {
        final localRecipe = await localDataSource.getCachedRecipeById(id);
        if (localRecipe != null) {
          return Right(localRecipe);
        } else {
          return const Left(NetworkFailure(
              message: 'No internet connection and recipe not found in cache'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> searchRecipes(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRecipes = await remoteDataSource.searchRecipes(query);

        final recipesWithFavorites = <RecipeModel>[];
        for (final recipe in remoteRecipes) {
          final isFav = await localDataSource.isFavorite(recipe.id);
          recipesWithFavorites.add(recipe.copyWith(isFavorite: isFav));
        }

        return Right(recipesWithFavorites);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on UnexpectedException catch (e) {
        return Left(UnexpectedFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(
          message: 'No internet connection. Search requires online access.'));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByCategory(
      String category) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRecipes =
            await remoteDataSource.getRecipesByCategory(category);

        final recipesWithFavorites = <RecipeModel>[];
        for (final recipe in remoteRecipes) {
          final isFav = await localDataSource.isFavorite(recipe.id);
          recipesWithFavorites.add(recipe.copyWith(isFavorite: isFav));
        }

        return Right(recipesWithFavorites);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on UnexpectedException catch (e) {
        return Left(UnexpectedFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getCategories();
        return Right(categories);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on UnexpectedException catch (e) {
        return Left(UnexpectedFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Recipe>> toggleFavorite(Recipe recipe) async {
    try {
      if (recipe.isFavorite) {
        await localDataSource.removeFavoriteRecipe(recipe.id);
      } else {
        await localDataSource.addFavoriteRecipe(RecipeModel.fromEntity(recipe));
      }
      return Right(recipe.copyWith(isFavorite: !recipe.isFavorite));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getFavoriteRecipes() async {
    try {
      final favoriteRecipes = await localDataSource.getFavoriteRecipes();
      return Right(favoriteRecipes);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRandomRecipes(
      {int count = 10}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRecipes =
            await remoteDataSource.getRandomRecipes(count: count);

        final recipesWithFavorites = <RecipeModel>[];
        for (final recipe in remoteRecipes) {
          final isFav = await localDataSource.isFavorite(recipe.id);
          recipesWithFavorites.add(recipe.copyWith(isFavorite: isFav));
        }

        return Right(recipesWithFavorites);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on UnexpectedException catch (e) {
        return Left(UnexpectedFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(
          message:
              'No internet connection. Random recipes require online access.'));
    }
  }
}
