import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final Map<String, Map<String, Color>> categoryColors;

  const CategoryTabs({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categoryColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              categoryColors.keys.map((category) {
                return GestureDetector(
                  onTap: () => onCategorySelected(category),
                  child: Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          selectedCategory == category
                              ? categoryColors[category]!["main"]
                              : categoryColors[category]!["sub"],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 20,
                        color:
                            selectedCategory == category
                                ? Colors.white
                                : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
