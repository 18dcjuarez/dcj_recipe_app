import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class ToggleFavorite extends UseCase<Recipe, ToggleFavoriteParams> {
  final RecipesRepository repository;

  ToggleFavorite(this.repository);

  @override
  Future<Either<Failure, Recipe>> call(ToggleFavoriteParams params) async {
    return await repository.toggleFavorite(params.recipe);
  }
}

class ToggleFavoriteParams extends Equatable {
  final Recipe recipe;

  const ToggleFavoriteParams({required this.recipe});

  @override
  List<Object> get props => [recipe];
}
