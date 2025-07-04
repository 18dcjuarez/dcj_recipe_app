import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class GetRandomRecipes extends UseCase<List<Recipe>, GetRandomRecipesParams> {
  final RecipesRepository repository;

  GetRandomRecipes(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> call(
      GetRandomRecipesParams params) async {
    return await repository.getRandomRecipes(count: params.count);
  }
}

class GetRandomRecipesParams extends Equatable {
  final int count;

  const GetRandomRecipesParams({this.count = 10});

  @override
  List<Object> get props => [count];
}
