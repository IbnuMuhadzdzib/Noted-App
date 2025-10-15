import 'package:flutter/material.dart';
import '../core/extension.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  // Data dummy
  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.list},
    {'name': 'Pinned', 'icon': Icons.pin_invoke},
    {'name': 'Simple Notes', 'icon': Icons.notes},
    {'name': 'To-Do-List', 'icon': Icons.check},
    {'name': 'Income', 'icon': Icons.money},
  ];

  String selectedCategory = 'Technology';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['name'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category['name'];
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.color.primary
                    : context.color.secondary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? context.color.primary
                      : context.color.secondary,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'],
                    size: 20,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : Colors.grey[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
