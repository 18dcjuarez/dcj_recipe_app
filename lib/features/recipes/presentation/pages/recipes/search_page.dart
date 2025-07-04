import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/bloc/xport_bloc_file.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/pages/recipes/widgets/xport_recipes_widgets.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/widgets/xport_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      context.read<RecipesBloc>().add(ClearSearchEvent());
    } else {
      context.read<RecipesBloc>().add(SearchRecipesEvent(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.grey50,
      appBar: AppBar(
        backgroundColor: CustomColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CustomColors.black),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search recipes...',
            hintStyle: TextStyle(color: CustomColors.grey400),
            border: InputBorder.none,
            suffixIcon: _isSearching
                ? IconButton(
                    icon: const Icon(Icons.clear, color: CustomColors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                      _focusNode.requestFocus();
                    },
                  )
                : null,
          ),
          style: const TextStyle(fontSize: 18),
        ).animate().fadeIn(duration: 300.ms),
      ),
      body: BlocBuilder<RecipesBloc, RecipesState>(
        builder: (context, state) {
          if (!_isSearching) {
            return _buildSearchSuggestions();
          }

          if (state is RecipesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: CustomColors.mainColor),
            );
          }

          if (state is RecipesError) {
            return Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Search Error',
                message: state.message,
                actionLabel: 'Try Again',
                onAction: () {
                  _onSearchChanged(_searchController.text);
                },
              ),
            );
          }

          if (state is RecipesNoConnection) {
            return Center(
              child: EmptyState(
                icon: Icons.wifi_off,
                title: 'No Internet Connection',
                message: 'Search requires an internet connection',
              ),
            );
          }

          if (state is SearchRecipesEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.search_off,
                title: 'No Results',
                message:
                    'No recipes found for "${state.query}".\nTry searching with different keywords.',
              ),
            );
          }

          if (state is SearchRecipesLoaded) {
            return _buildSearchResults(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      'Chicken',
      'Pasta',
      'Beef',
      'Vegetarian',
      'Dessert',
      'Seafood',
      'Salad',
      'Soup',
      'Breakfast',
      'Asian',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CustomColors.grey800,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return ListTile(
                leading: const Icon(Icons.search, color: CustomColors.grey),
                title: Text(suggestion),
                onTap: () {
                  _searchController.text = suggestion;
                  _onSearchChanged(suggestion);
                },
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 50 * index))
                  .slideX(begin: -0.1, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(SearchRecipesLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Text(
              '${state.recipes.length} results for "${state.query}"',
              style: TextStyle(
                fontSize: 16,
                color: CustomColors.grey600,
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final recipe = state.recipes[index];
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
                    .fadeIn(delay: Duration(milliseconds: 50 * index))
                    .slideY(begin: 0.1, end: 0);
              },
              childCount: state.recipes.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }
}
