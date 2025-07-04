import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';
import 'package:equatable/equatable.dart';

abstract class RecipesEvent extends Equatable {
  const RecipesEvent();

  @override
  List<Object?> get props => [];
}

class GetRecipesEvent extends RecipesEvent {
  final int page;
  final bool isRefresh;

  const GetRecipesEvent({
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object> get props => [page, isRefresh];
}

class GetRecipeByIdEvent extends RecipesEvent {
  final String id;

  const GetRecipeByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

class SearchRecipesEvent extends RecipesEvent {
  final String query;

  const SearchRecipesEvent(this.query);

  @override
  List<Object> get props => [query];
}

class GetRecipesByCategoryEvent extends RecipesEvent {
  final String category;

  const GetRecipesByCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class GetCategoriesEvent extends RecipesEvent {}

class GetFavoriteRecipesEvent extends RecipesEvent {}

class ToggleFavoriteEvent extends RecipesEvent {
  final Recipe recipe;

  const ToggleFavoriteEvent(this.recipe);

  @override
  List<Object> get props => [recipe];
}

class GetRandomRecipesEvent extends RecipesEvent {
  final int count;

  const GetRandomRecipesEvent({this.count = 10});

  @override
  List<Object> get props => [count];
}

class LoadMoreRecipesEvent extends RecipesEvent {
  final int nextPage;

  const LoadMoreRecipesEvent(this.nextPage);

  @override
  List<Object> get props => [nextPage];
}

class ClearSearchEvent extends RecipesEvent {}
