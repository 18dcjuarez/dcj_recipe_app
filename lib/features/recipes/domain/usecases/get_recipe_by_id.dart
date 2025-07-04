import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class GetRecipeById extends UseCase<Recipe, GetRecipeByIdParams> {
  final RecipesRepository repository;

  GetRecipeById(this.repository);

  @override
  Future<Either<Failure, Recipe>> call(GetRecipeByIdParams params) async {
    return await repository.getRecipeById(params.id);
  }
}

class GetRecipeByIdParams extends Equatable {
  final String id;

  const GetRecipeByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}
