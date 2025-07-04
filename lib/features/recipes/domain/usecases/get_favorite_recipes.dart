import 'package:dartz/dartz.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class GetFavoriteRecipes extends UseCase<List<Recipe>, NoParams> {
  final RecipesRepository repository;

  GetFavoriteRecipes(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> call(NoParams params) async {
    return await repository.getFavoriteRecipes();
  }
}
