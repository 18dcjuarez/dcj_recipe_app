import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:dcj_recipe_app/features/recipes/presentation/bloc/xport_bloc_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CategoryFilter extends StatefulWidget {
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryFilter({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  final List<String> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _isLoading = true;
    });
    context.read<RecipesBloc>().add(GetCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecipesBloc, RecipesState>(
      listener: (context, state) {
        if (state is CategoriesLoaded) {
          setState(() {
            _categories.clear();
            _categories.addAll(state.categories);
            _isLoading = false;
          });
        } else if (state is RecipesError) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: _isLoading
            ? _buildLoadingCategories()
            : _categories.isEmpty
                ? const SizedBox.shrink()
                : _buildCategoryList(),
      ),
    );
  }

  Widget _buildLoadingCategories() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: CustomColors.grey300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryList() {
    final allCategories = ['All', ..._categories];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: allCategories.length,
      itemBuilder: (context, index) {
        final category = allCategories[index];
        final isSelected =
            (category == 'All' && widget.selectedCategory == null) ||
                category == widget.selectedCategory;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (selected) {
              widget.onCategorySelected(category == 'All' ? null : category);
            },
            backgroundColor: CustomColors.white,
            selectedColor: CustomColors.mainColor,
            labelStyle: TextStyle(
              color: isSelected ? CustomColors.white : CustomColors.grey700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? CustomColors.mainColor : CustomColors.grey300,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 50 * index))
              .slideX(begin: 0.2, end: 0),
        );
      },
    );
  }
}
