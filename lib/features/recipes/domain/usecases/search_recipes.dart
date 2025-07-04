import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class SearchRecipes extends UseCase<List<Recipe>, SearchRecipesParams> {
  final RecipesRepository repository;

  SearchRecipes(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> call(SearchRecipesParams params) async {
    if (params.query.isEmpty) {
      return const Right([]);
    }
    return await repository.searchRecipes(params.query);
  }
}

class SearchRecipesParams extends Equatable {
  final String query;

  const SearchRecipesParams({required this.query});

  @override
  List<Object> get props => [query];
}
