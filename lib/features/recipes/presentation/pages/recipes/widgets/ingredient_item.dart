import 'package:dcj_recipe_app/core/xport_core.dart';
import 'package:flutter/material.dart';

import 'package:dcj_recipe_app/features/recipes/domain/xport_domain.dart';

class IngredientItem extends StatefulWidget {
  final Ingredient ingredient;
  final int index;

  const IngredientItem({
    super.key,
    required this.ingredient,
    required this.index,
  });

  @override
  State<IngredientItem> createState() => _IngredientItemState();
}

class _IngredientItemState extends State<IngredientItem> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() {
        _isChecked = !_isChecked;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _isChecked ? CustomColors.greenOpacity10 : CustomColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isChecked ? CustomColors.green : CustomColors.grey300,
            width: 1,
          ),
        ),
        child: ListTile(
          leading: Checkbox(
            value: _isChecked,
            onChanged: (value) {
              setState(() {
                _isChecked = value ?? false;
              });
            },
            activeColor: CustomColors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Text(
            widget.ingredient.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: _isChecked ? TextDecoration.lineThrough : null,
              color: _isChecked ? CustomColors.grey : CustomColors.black87,
            ),
          ),
          trailing: Text(
            widget.ingredient.measure,
            style: TextStyle(
              fontSize: 14,
              color: _isChecked ? CustomColors.grey : CustomColors.mainColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      ),
    );
  }
}
