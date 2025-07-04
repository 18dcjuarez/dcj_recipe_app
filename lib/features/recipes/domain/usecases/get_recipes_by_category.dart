import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class GetRecipesByCategory
    extends UseCase<List<Recipe>, GetRecipesByCategoryParams> {
  final RecipesRepository repository;

  GetRecipesByCategory(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> call(
      GetRecipesByCategoryParams params) async {
    return await repository.getRecipesByCategory(params.category);
  }
}

class GetRecipesByCategoryParams extends Equatable {
  final String category;

  const GetRecipesByCategoryParams({required this.category});

  @override
  List<Object> get props => [category];
}
