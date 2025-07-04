import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnail;
  final String? tags;
  final String? youtube;
  final List<Ingredient> ingredients;
  final bool isFavorite;

  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    this.tags,
    this.youtube,
    required this.ingredients,
    this.isFavorite = false,
  });

  Recipe copyWith({
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
    return Recipe(
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

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        area,
        instructions,
        thumbnail,
        tags,
        youtube,
        ingredients,
        isFavorite,
      ];
}

class Ingredient extends Equatable {
  final String name;
  final String measure;

  const Ingredient({
    required this.name,
    required this.measure,
  });

  @override
  List<Object> get props => [name, measure];
}
