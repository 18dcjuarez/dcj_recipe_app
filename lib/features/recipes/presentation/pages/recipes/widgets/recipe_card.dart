import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CustomColors.blackOpacity10,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _buildImage(),
              _buildGradient(),
              _buildContent(),
              _buildFavoriteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Positioned.fill(
      child: Hero(
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
              size: 50,
              color: CustomColors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CustomColors.transparent,
              CustomColors.blackOpacity70,
            ],
            stops: const [0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              recipe.name,
              style: const TextStyle(
                color: CustomColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.category,
                  size: 14,
                  color: CustomColors.whiteOpacity80,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    recipe.category,
                    style: TextStyle(
                      color: CustomColors.whiteOpacity80,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: onFavoriteToggle,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CustomColors.whiteOpacity80,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: CustomColors.blackOpacity10,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: recipe.isFavorite ? CustomColors.red : CustomColors.grey700,
            size: 20,
          )
              .animate(target: recipe.isFavorite ? 1 : 0)
              .scaleXY(end: 1.2, duration: 200.ms)
              .then()
              .scaleXY(end: 1.0, duration: 200.ms),
        ),
      ),
    );
  }
}
