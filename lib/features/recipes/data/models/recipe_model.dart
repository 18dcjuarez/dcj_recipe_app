// ignore_for_file: use_super_parameters

import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required String id,
    required String name,
    required String category,
    required String area,
    required String instructions,
    required String thumbnail,
    String? tags,
    String? youtube,
    required List<Ingredient> ingredients,
    bool isFavorite = false,
  }) : super(
          id: id,
          name: name,
          category: category,
          area: area,
          instructions: instructions,
          thumbnail: thumbnail,
          tags: tags,
          youtube: youtube,
          ingredients: ingredients,
          isFavorite: isFavorite,
        );

  factory RecipeModel.fromJson(Map<String, dynamic> json,
      {bool isFavorite = false}) {
    final List<Ingredient> ingredients = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;

      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredient,
          measure: measure ?? '',
        ));
      }
    }

    return RecipeModel(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      thumbnail: json['strMealThumb'] ?? '',
      tags: json['strTags'],
      youtube: json['strYoutube'],
      ingredients: ingredients,
      isFavorite: isFavorite,
    );
  }

  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      name: recipe.name,
      category: recipe.category,
      area: recipe.area,
      instructions: recipe.instructions,
      thumbnail: recipe.thumbnail,
      tags: recipe.tags,
      youtube: recipe.youtube,
      ingredients: recipe.ingredients,
      isFavorite: recipe.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbnail,
      'strTags': tags,
      'strYoutube': youtube,
    };

    for (int i = 0; i < ingredients.length; i++) {
      data['strIngredient${i + 1}'] = ingredients[i].name;
      data['strMeasure${i + 1}'] = ingredients[i].measure;
    }

    return data;
  }

  factory RecipeModel.fromSimplifiedJson(Map<String, dynamic> json,
      {bool isFavorite = false}) {
    return RecipeModel(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: '',
      thumbnail: json['strMealThumb'] ?? '',
      tags: null,
      youtube: null,
      ingredients: [],
      isFavorite: isFavorite,
    );
  }

  @override
  RecipeModel copyWith({
    String? id,
    String? name,
    String? category,
    String? area,
    String? instructions,
    String? thumbnail,
    String? tags,
    String? youtube,
    List<Ingredient>? ingredients,
    bool? isFavorite,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      area: area ?? this.area,
      instructions: instructions ?? this.instructions,
      thumbnail: thumbnail ?? this.thumbnail,
      tags: tags ?? this.tags,
      youtube: youtube ?? this.youtube,
      ingredients: ingredients ?? this.ingredients,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
