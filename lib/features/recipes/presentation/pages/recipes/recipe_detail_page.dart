import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/bloc/xport_bloc_file.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/pages/recipes/widgets/xport_recipes_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;
  final Recipe recipe;

  const RecipeDetailPage({
    super.key,
    required this.recipeId,
    required this.recipe,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Recipe _recipe;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildRecipeDetail(context, _recipe));
  }

  Widget _buildRecipeDetail(BuildContext context, Recipe recipe) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, recipe),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecipeInfo(recipe),
                const SizedBox(height: 24),
                _buildSectionTitle('Ingredients'),
                const SizedBox(height: 16),
                _buildIngredientsList(recipe.ingredients),
                const SizedBox(height: 24),
                _buildSectionTitle('Instructions'),
                const SizedBox(height: 16),
                _buildInstructions(recipe.instructions),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, Recipe recipe) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: CustomColors.mainColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: CustomColors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: CustomColors.white,
          ),
          onPressed: () {
            setState(() {
              _recipe = _recipe.copyWith(isFavorite: !_recipe.isFavorite);
            });
            context.read<RecipesBloc>().add(ToggleFavoriteEvent(recipe));
          },
        )
            .animate(target: recipe.isFavorite ? 1 : 0)
            .scaleXY(end: 1.2, duration: 200.ms)
            .then()
            .scaleXY(end: 1.0, duration: 200.ms),
        if (recipe.youtube != null && recipe.youtube!.isNotEmpty)
          IconButton(
            icon: const Icon(
              Icons.play_circle_outline,
              color: CustomColors.white,
            ),
            onPressed: () async {
              final Uri url = Uri.parse(recipe.youtube!);
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            },
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            recipe.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CustomColors.white,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'recipe-image-${recipe.id}',
              child: CachedNetworkImage(
                imageUrl: recipe.thumbnail,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: CustomColors.grey300,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: CustomColors.mainColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: CustomColors.grey300,
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: CustomColors.grey,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CustomColors.transparent,
                    CustomColors.blackOpacity70,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeInfo(Recipe recipe) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildInfoChip(Icons.category, recipe.category),
          const SizedBox(width: 16),
          _buildInfoChip(Icons.location_on, recipe.area),
          if (recipe.tags != null && recipe.tags!.isNotEmpty) ...[
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoChip(Icons.tag, recipe.tags!),
            ),
          ],
        ],
      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CustomColors.mainOpacity10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CustomColors.mainOpacity30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: CustomColors.mainColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: CustomColors.mainColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: CustomColors.black87,
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildIngredientsList(List<Ingredient> ingredients) {
    return Column(
      children: ingredients.asMap().entries.map((entry) {
        final index = entry.key;
        final ingredient = entry.value;
        return IngredientItem(
          ingredient: ingredient,
          index: index,
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 * index))
            .slideX(begin: -0.1, end: 0);
      }).toList(),
    );
  }

  Widget _buildInstructions(String instructions) {
    final steps =
        instructions.split('\r\n').where((step) => step.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CustomColors.grey100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CustomColors.grey300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: CustomColors.mainColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: CustomColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.trim(),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 * index))
            .slideY(begin: 0.1, end: 0);
      }).toList(),
    );
  }
}
