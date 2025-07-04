// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:go_router/go_router.dart';

import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/bloc/xport_bloc_file.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/pages/recipes/widgets/xport_recipes_widgets.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/widgets/xport_widgets.dart';

class NoConnectionPage extends StatefulWidget {
  const NoConnectionPage({super.key});

  @override
  State<NoConnectionPage> createState() => _NoConnectionPageState();
}

class _NoConnectionPageState extends State<NoConnectionPage> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isDisplayingFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadCachedRecipes();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _loadCachedRecipes() {
    context.read<RecipesBloc>().add(const GetRecipesEvent());
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    if (result[0] != ConnectivityResult.none) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Internet connection restored!'),
            backgroundColor: CustomColors.green,
          ),
        );
      }
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.grey50,
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          _buildOfflineHeader(),
          Expanded(
            child: BlocBuilder<RecipesBloc, RecipesState>(
              builder: (context, state) {
                if (state is RecipesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: CustomColors.grey),
                  );
                }

                if (state is RecipesLoaded && state.recipes.isNotEmpty) {
                  return _buildOfflineRecipes(state.recipes);
                }

                if (state is FavoriteRecipesLoaded &&
                    state.recipes.isNotEmpty) {
                  return _buildOfflineRecipes(state.recipes);
                }

                return Center(
                  child: EmptyState(
                    icon: Icons.cloud_off,
                    title: 'No Cached Recipes',
                    message:
                        'Browse recipes online to save them for offline viewing.',
                    actionLabel: 'Check Connection',
                    onAction: () async {
                      final connectivityResult =
                          await _connectivity.checkConnectivity();
                      if (connectivityResult[0] != ConnectivityResult.none) {
                        context.go('/');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Still no internet connection'),
                            backgroundColor: CustomColors.red,
                            action: SnackBarAction(
                              label: 'Load Saved',
                              textColor: CustomColors.grey100,
                              onPressed: _loadCachedRecipes,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomColors.redOpacity10,
        border: Border(
          bottom: BorderSide(
            color: CustomColors.redOpacity30,
            width: 2,
          ),
          top: BorderSide(
            color: CustomColors.redOpacity30,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_outlined,
            color: CustomColors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Showing cached recipes and favorites',
                  style: TextStyle(
                    fontSize: 14,
                    color: CustomColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildOfflineRecipes(List<dynamic> recipes) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadCachedRecipes();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Offline (${recipes.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _isDisplayingFavorites
                          ? _loadCachedRecipes()
                          : context
                              .read<RecipesBloc>()
                              .add(GetFavoriteRecipesEvent());
                      _isDisplayingFavorites = !_isDisplayingFavorites;
                    },
                    icon: Icon(
                        _isDisplayingFavorites
                            ? Icons.save_outlined
                            : Icons.favorite,
                        size: 18),
                    label: Text(
                      _isDisplayingFavorites
                          ? 'Show Recipes'
                          : 'Show Favorites',
                    ),
                  ),
                ],
              ),
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
                      .fadeIn(delay: Duration(milliseconds: 50 * index))
                      .slideY(begin: 0.1, end: 0);
                },
                childCount: recipes.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}
