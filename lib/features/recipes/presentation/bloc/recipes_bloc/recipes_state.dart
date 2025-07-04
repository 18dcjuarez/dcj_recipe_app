import 'package:equatable/equatable.dart';

import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

abstract class RecipesState extends Equatable {
  const RecipesState();

  @override
  List<Object?> get props => [];
}

class RecipesInitial extends RecipesState {}

class RecipesLoading extends RecipesState {}

class RecipesLoadingMore extends RecipesState {
  final List<Recipe> currentRecipes;

  const RecipesLoadingMore(this.currentRecipes);

  @override
  List<Object> get props => [currentRecipes];
}

class RecipesLoaded extends RecipesState {
  final List<Recipe> recipes;
  final bool hasReachedMax;
  final int currentPage;

  const RecipesLoaded({
    required this.recipes,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  RecipesLoaded copyWith({
    List<Recipe>? recipes,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return RecipesLoaded(
      recipes: recipes ?? this.recipes,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [recipes, hasReachedMax, currentPage];
}

class RecipeLoaded extends RecipesState {
  final Recipe recipe;
  final List<Recipe>? previousRecipes;
  final bool? hasReachedMax;
  final int? currentPage;

  const RecipeLoaded(
    this.recipe, {
    this.previousRecipes,
    this.hasReachedMax,
    this.currentPage,
  });

  @override
  List<Object?> get props =>
      [recipe, previousRecipes, hasReachedMax, currentPage];
}

class SearchRecipesLoaded extends RecipesState {
  final List<Recipe> recipes;
  final String query;

  const SearchRecipesLoaded({
    required this.recipes,
    required this.query,
  });

  @override
  List<Object> get props => [recipes, query];
}

class CategoriesLoaded extends RecipesState {
  final List<String> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class FavoriteRecipesLoaded extends RecipesState {
  final List<Recipe> recipes;

  const FavoriteRecipesLoaded(this.recipes);

  @override
  List<Object> get props => [recipes];
}

class RecipesError extends RecipesState {
  final String message;

  const RecipesError(this.message);

  @override
  List<Object> get props => [message];
}

class RecipesNoConnection extends RecipesState {
  final String message;
  final List<Recipe>? cachedRecipes;

  const RecipesNoConnection({
    this.message = 'No internet connection',
    this.cachedRecipes,
  });

  @override
  List<Object?> get props => [message, cachedRecipes];
}

class RecipesEmpty extends RecipesState {
  final String message;

  const RecipesEmpty({
    this.message = 'No recipes found',
  });

  @override
  List<Object> get props => [message];
}

class SearchRecipesEmpty extends RecipesState {
  final String query;

  const SearchRecipesEmpty(this.query);

  @override
  List<Object> get props => [query];
}
