import 'package:dcj_recipe_app/core/theme/custom_colors.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/bloc/xport_bloc_file.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/pages/recipes/widgets/xport_recipes_widgets.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/widgets/xport_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  String? _selectedCategory;
  bool _showFavorites = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final currentState = context.read<RecipesBloc>().state;
    if (currentState is! RecipesLoaded) {
      context.read<RecipesBloc>().add(const GetRecipesEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !_showFavorites && _selectedCategory == null) {
      final state = context.read<RecipesBloc>().state;
      if (state is RecipesLoaded && !state.hasReachedMax) {
        context.read<RecipesBloc>().add(
              LoadMoreRecipesEvent(state.currentPage + 1),
            );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      _showFavorites = false;
    });

    if (category == null) {
      context.read<RecipesBloc>().add(const GetRecipesEvent(isRefresh: true));
    } else {
      context.read<RecipesBloc>().add(GetRecipesByCategoryEvent(category));
    }
  }

  void _toggleFavorites() {
    setState(() {
      _showFavorites = !_showFavorites;
      _selectedCategory = null;
    });

    if (_showFavorites) {
      context.read<RecipesBloc>().add(GetFavoriteRecipesEvent());
    } else {
      context.read<RecipesBloc>().add(const GetRecipesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.grey50,
      body: RefreshIndicator(
        onRefresh: () async {
          if (_showFavorites) {
            context.read<RecipesBloc>().add(GetFavoriteRecipesEvent());
          } else if (_selectedCategory != null) {
            context.read<RecipesBloc>().add(
                  GetRecipesByCategoryEvent(_selectedCategory!),
                );
          } else {
            context.read<RecipesBloc>().add(
                  const GetRecipesEvent(isRefresh: true),
                );
          }
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(),
            _buildCategoryFilter(),
            _buildContent(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      snap: true,
      backgroundColor: CustomColors.mainColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Recipe App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: CustomColors.white),
          onPressed: () => context.push('/search'),
        ).animate().fadeIn(delay: 300.ms).scale(),
        IconButton(
          icon: Icon(
            _showFavorites ? Icons.favorite : Icons.favorite_border,
            color: CustomColors.white,
          ),
          onPressed: _toggleFavorites,
        ).animate().fadeIn(delay: 400.ms).scale(),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SliverToBoxAdapter(
      child: CategoryFilter(
        selectedCategory: _selectedCategory,
        onCategorySelected: _onCategorySelected,
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<RecipesBloc, RecipesState>(
      builder: (context, state) {
        if (state is RecipesLoading) {
          return const SliverFillRemaining(
            child: LoadingGrid(),
          );
        }

        if (state is RecipesError) {
          return SliverFillRemaining(
            child: EmptyState(
              icon: Icons.error_outline,
              title: 'Oops! Something went wrong',
              message: state.message,
              actionLabel: 'Try Again',
              onAction: () {
                context.read<RecipesBloc>().add(const GetRecipesEvent());
              },
            ),
          );
        }

        if (state is RecipesNoConnection) {
          return SliverFillRemaining(
            child: EmptyState(
              icon: Icons.wifi_off,
              title: 'No Internet Connection',
              message: state.message,
              actionLabel: 'Go Offline',
              onAction: () => context.push('/no-connection'),
            ),
          );
        }

        if (state is RecipesEmpty || state is SearchRecipesEmpty) {
          final message = _showFavorites
              ? 'No favorite recipes yet.\nTap the heart icon on any recipe to add it to favorites!'
              : state is SearchRecipesEmpty
                  ? 'No recipes found for "${(state).query}"'
                  : 'No recipes available';

          return SliverFillRemaining(
            child: EmptyState(
              icon: _showFavorites
                  ? Icons.favorite_border
                  : Icons.restaurant_menu,
              title: _showFavorites ? 'No Favorites Yet' : 'No Recipes Found',
              message: message,
              actionLabel: _showFavorites ? 'Browse Recipes' : 'Refresh',
              onAction: () {
                if (_showFavorites) {
                  _toggleFavorites();
                } else {
                  context.read<RecipesBloc>().add(const GetRecipesEvent());
                }
              },
            ),
          );
        }

        if (state is RecipesLoaded ||
            state is FavoriteRecipesLoaded ||
            state is RecipesLoadingMore) {
          final recipes = state is RecipesLoaded
              ? state.recipes
              : state is FavoriteRecipesLoaded
                  ? state.recipes
                  : (state as RecipesLoadingMore).currentRecipes;

          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= recipes.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final recipe = recipes[index];
                  return RecipeCard(
                    recipe: recipe,
                    onTap: () => context.push(
                      '/recipe/${recipe.id}',
                      extra: recipe,
                    ),
                    onFavoriteToggle: () {
                      context.read<RecipesBloc>().add(
                            ToggleFavoriteEvent(recipe),
                          );
                    },
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: index * 50))
                      .slideY(begin: 0.1, end: 0);
                },
                childCount: state is RecipesLoadingMore
                    ? recipes.length + 1
                    : recipes.length,
              ),
            ),
          );
        }

        return const SliverFillRemaining(
          child: SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        context.read<RecipesBloc>().add(const GetRandomRecipesEvent(count: 10));
      },
      icon: const Icon(Icons.shuffle),
      label: const Text('Surprise Me!'),
    )
        .animate()
        .fadeIn(delay: 800.ms)
        .slideY(begin: 1, end: 0)
        .then()
        .shimmer(duration: 3.seconds, delay: 1.seconds);
  }
}
