import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class GetRecipes extends UseCase<List<Recipe>, GetRecipesParams> {
  final RecipesRepository repository;

  GetRecipes(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> call(GetRecipesParams params) async {
    return await repository.getRecipes(page: params.page);
  }
}

class GetRecipesParams extends Equatable {
  final int page;

  const GetRecipesParams({this.page = 1});

  @override
  List<Object> get props => [page];
}
