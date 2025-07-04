import 'package:dartz/dartz.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class GetCategories extends UseCase<List<String>, NoParams> {
  final RecipesRepository repository;

  GetCategories(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
