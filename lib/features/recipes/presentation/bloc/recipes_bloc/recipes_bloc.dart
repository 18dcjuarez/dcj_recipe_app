// ignore_for_file: type_literal_in_constant_pattern

import 'package:flutter_bloc/flutter_bloc.dart';
import 'recipes_event.dart';
import 'recipes_state.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  final GetRecipes getRecipes;
  final GetRecipeById getRecipeById;
  final SearchRecipes searchRecipes;
  final ToggleFavorite toggleFavorite;
  final GetFavoriteRecipes getFavoriteRecipes;
  final GetCategories getCategories;
  final GetRecipesByCategory getRecipesByCategory;
  final GetRandomRecipes getRandomRecipes;

  RecipesBloc({
    required this.getRecipes,
    required this.getRecipeById,
    required this.searchRecipes,
    required this.toggleFavorite,
    required this.getFavoriteRecipes,
    required this.getCategories,
    required this.getRecipesByCategory,
    required this.getRandomRecipes,
  }) : super(RecipesInitial()) {
    on<GetRecipesEvent>(_onGetRecipes);
    on<GetRecipeByIdEvent>(_onGetRecipeById);
    on<SearchRecipesEvent>(_onSearchRecipes);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<GetFavoriteRecipesEvent>(_onGetFavoriteRecipes);
    on<GetCategoriesEvent>(_onGetCategories);
    on<GetRecipesByCategoryEvent>(_onGetRecipesByCategory);
    on<GetRandomRecipesEvent>(_onGetRandomRecipes);
    on<LoadMoreRecipesEvent>(_onLoadMoreRecipes);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onGetRecipes(
    GetRecipesEvent event,
    Emitter<RecipesState> emit,
  ) async {
    if (state is RecipesLoaded && !event.isRefresh) {
      return;
    }

    if (event.isRefresh || state is! RecipesLoaded) {
      emit(RecipesLoading());
    }

    final failureOrRecipes = await getRecipes(
      GetRecipesParams(page: event.page),
    );

    failureOrRecipes.fold(
      (failure) {
        if (failure is NetworkFailure) {
          if (state is RecipesLoaded) {
            final currentState = state as RecipesLoaded;
            emit(RecipesNoConnection(
              message: failure.message ?? 'No internet connection',
              cachedRecipes: currentState.recipes,
            ));
          } else {
            emit(RecipesNoConnection(
              message: failure.message ?? 'No internet connection',
            ));
          }
        } else {
          emit(RecipesError(_mapFailureToMessage(failure)));
        }
      },
      (recipes) {
        if (recipes.isEmpty) {
          emit(const RecipesEmpty());
        } else {
          emit(RecipesLoaded(
            recipes: recipes,
            currentPage: event.page,
            hasReachedMax: recipes.length < 20,
          ));
        }
      },
    );
  }

  Future<void> _onGetRecipeById(
    GetRecipeByIdEvent event,
    Emitter<RecipesState> emit,
  ) async {
    List<Recipe>? previousRecipes;
    bool? hasReachedMax;
    int? currentPage;

    if (state is RecipesLoaded) {
      final currentState = state as RecipesLoaded;
      previousRecipes = currentState.recipes;
      hasReachedMax = currentState.hasReachedMax;
      currentPage = currentState.currentPage;
    }

    emit(RecipesLoading());

    final failureOrRecipe = await getRecipeById(
      GetRecipeByIdParams(id: event.id),
    );

    failureOrRecipe.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(RecipesNoConnection(
              message: failure.message ?? 'No internet connection'));
        } else {
          emit(RecipesError(_mapFailureToMessage(failure)));
        }
      },
      (recipe) => emit(RecipeLoaded(
        recipe,
        previousRecipes: previousRecipes,
        hasReachedMax: hasReachedMax,
        currentPage: currentPage,
      )),
    );
  }

  Future<void> _onSearchRecipes(
    SearchRecipesEvent event,
    Emitter<RecipesState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(RecipesInitial());
      return;
    }

    emit(RecipesLoading());

    final failureOrRecipes = await searchRecipes(
      SearchRecipesParams(query: event.query),
    );

    failureOrRecipes.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(RecipesNoConnection(
              message: failure.message ?? 'No internet connection'));
        } else {
          emit(RecipesError(_mapFailureToMessage(failure)));
        }
      },
      (recipes) {
        if (recipes.isEmpty) {
          emit(SearchRecipesEmpty(event.query));
        } else {
          emit(SearchRecipesLoaded(
            recipes: recipes,
            query: event.query,
          ));
        }
      },
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<RecipesState> emit,
  ) async {
    final currentState = state;

    final failureOrRecipe = await toggleFavorite(
      ToggleFavoriteParams(recipe: event.recipe),
    );

    failureOrRecipe.fold(
      (failure) => emit(RecipesError(_mapFailureToMessage(failure))),
      (updatedRecipe) {
        if (currentState is RecipesLoaded) {
          final updatedRecipes = currentState.recipes.map((recipe) {
            return recipe.id == updatedRecipe.id ? updatedRecipe : recipe;
          }).toList();

          emit(currentState.copyWith(recipes: updatedRecipes));
        } else if (currentState is RecipeLoaded &&
            currentState.recipe.id == updatedRecipe.id) {
          emit(RecipeLoaded(updatedRecipe));
        } else if (currentState is SearchRecipesLoaded) {
          final updatedRecipes = currentState.recipes.map((recipe) {
            return recipe.id == updatedRecipe.id ? updatedRecipe : recipe;
          }).toList();

          emit(SearchRecipesLoaded(
            recipes: updatedRecipes,
            query: currentState.query,
          ));
        } else if (currentState is FavoriteRecipesLoaded) {
          add(GetFavoriteRecipesEvent());
        }
      },
    );
  }

  Future<void> _onGetFavoriteRecipes(
    GetFavoriteRecipesEvent event,
    Emitter<RecipesState> emit,
  ) async {
    emit(RecipesLoading());

    final failureOrRecipes = await getFavoriteRecipes(NoParams());

    failureOrRecipes.fold(
      (failure) => emit(RecipesError(_mapFailureToMessage(failure))),
      (recipes) {
        if (recipes.isEmpty) {
          emit(const RecipesEmpty(message: 'No favorite recipes yet'));
        } else {
          emit(FavoriteRecipesLoaded(recipes));
        }
      },
    );
  }

  Future<void> _onGetCategories(
    GetCategoriesEvent event,
    Emitter<RecipesState> emit,
  ) async {
    emit(RecipesLoading());

    final failureOrCategories = await getCategories(NoParams());

    failureOrCategories.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(RecipesNoConnection(
              message: failure.message ?? 'No internet connection'));
        } else {
          emit(RecipesError(_mapFailureToMessage(failure)));
        }
      },
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  Future<void> _onGetRecipesByCategory(
    GetRecipesByCategoryEvent event,
    Emitter<RecipesState> emit,
  ) async {
    emit(RecipesLoading());

    final failureOrRecipes = await getRecipesByCategory(
      GetRecipesByCategoryParams(category: event.category),
    );

    failureOrRecipes.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(RecipesNoConnection(
              message: failure.message ?? 'No internet connection'));
        } else {
          emit(RecipesError(_mapFailureToMessage(failure)));
        }
      },
      (recipes) {
        if (recipes.isEmpty) {
          emit(RecipesEmpty(message: 'No recipes found in ${event.category}'));
        } else {
          emit(RecipesLoaded(recipes: recipes));
        }
      },
    );
  }

  Future<void> _onGetRandomRecipes(
    GetRandomRecipesEvent event,
    Emitter<RecipesState> emit,
  ) async {
    emit(RecipesLoading());

    final failureOrRecipes = await getRandomRecipes(
      GetRandomRecipesParams(count: event.count),
    );

    failureOrRecipes.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(RecipesNoConnection(
              message: failure.message ?? 'No internet connection'));
        } else {
          emit(RecipesError(_mapFailureToMessage(failure)));
        }
      },
      (recipes) => emit(RecipesLoaded(recipes: recipes)),
    );
  }

  Future<void> _onLoadMoreRecipes(
    LoadMoreRecipesEvent event,
    Emitter<RecipesState> emit,
  ) async {
    if (state is RecipesLoaded) {
      final currentState = state as RecipesLoaded;

      if (!currentState.hasReachedMax) {
        emit(RecipesLoadingMore(currentState.recipes));

        final failureOrRecipes = await getRecipes(
          GetRecipesParams(page: event.nextPage),
        );

        failureOrRecipes.fold(
          (failure) => emit(RecipesError(_mapFailureToMessage(failure))),
          (newRecipes) {
            if (newRecipes.isEmpty) {
              emit(currentState.copyWith(hasReachedMax: true));
            } else {
              emit(RecipesLoaded(
                recipes: [...currentState.recipes, ...newRecipes],
                currentPage: event.nextPage,
                hasReachedMax: newRecipes.length < 20,
              ));
            }
          },
        );
      }
    }
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<RecipesState> emit,
  ) {
    emit(RecipesInitial());
    add(const GetRecipesEvent());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message ?? 'Server error occurred';
      case CacheFailure:
        return (failure as CacheFailure).message ?? 'Cache error occurred';
      case NetworkFailure:
        return (failure as NetworkFailure).message ?? 'No internet connection';
      case NotFoundFailure:
        return (failure as NotFoundFailure).message ?? 'Recipe not found';
      default:
        return 'Unexpected error occurred';
    }
  }
}
