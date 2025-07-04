import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String? thumbnail;
  final String? description;

  const CategoryModel({
    required this.id,
    required this.name,
    this.thumbnail,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['idCategory'] ?? '',
      name: json['strCategory'] ?? '',
      thumbnail: json['strCategoryThumb'],
      description: json['strCategoryDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategory': id,
      'strCategory': name,
      'strCategoryThumb': thumbnail,
      'strCategoryDescription': description,
    };
  }

  @override
  List<Object?> get props => [id, name, thumbnail, description];
}
