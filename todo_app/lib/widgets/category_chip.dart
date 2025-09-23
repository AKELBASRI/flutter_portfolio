import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/constants.dart';

/// Widget for displaying and selecting todo categories
///
/// This widget creates beautiful, interactive chips for category selection
/// with smooth animations and proper color coding
class CategoryChip extends StatefulWidget {
  final TodoCategory category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showCount;
  final int count;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.showCount = false,
    this.count = 0,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = Color(widget.category.colorValue);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: AppConstants.animationFast,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? categoryColor
                    : categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                border: Border.all(
                  color: widget.isSelected
                      ? categoryColor
                      : categoryColor.withOpacity(0.3),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: categoryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category icon
                  Icon(
                    _getCategoryIcon(),
                    size: AppConstants.iconSizeSmall,
                    color: widget.isSelected
                        ? Colors.white
                        : categoryColor,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),

                  // Category name
                  Text(
                    widget.category.displayName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: widget.isSelected
                          ? Colors.white
                          : categoryColor,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),

                  // Count badge (if enabled)
                  if (widget.showCount) ...[
                    const SizedBox(width: AppConstants.paddingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? Colors.white.withOpacity(0.2)
                            : categoryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.count.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: widget.isSelected
                              ? Colors.white
                              : categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Returns the appropriate icon for each category
  IconData _getCategoryIcon() {
    switch (widget.category) {
      case TodoCategory.work:
        return Icons.work_outline;
      case TodoCategory.personal:
        return Icons.person_outline;
      case TodoCategory.shopping:
        return Icons.shopping_cart_outlined;
    }
  }
}

/// Widget for displaying a row of category filter chips
///
/// This widget provides a horizontal scrollable list of category chips
/// for filtering todos by category
class CategoryFilterChips extends StatelessWidget {
  final TodoCategory? selectedCategory;
  final Function(TodoCategory?) onCategorySelected;
  final Map<TodoCategory, int>? categoryCounts;

  const CategoryFilterChips({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
    this.categoryCounts,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
      child: Row(
        children: [
          // "All" chip
          CategoryChip(
            category: TodoCategory.personal, // Using as dummy for "All"
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
            showCount: true,
            count: _getTotalCount(),
          ),
          const SizedBox(width: AppConstants.paddingSmall),

          // Category chips
          ...TodoCategory.values.map((category) {
            final count = categoryCounts?[category] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
              child: CategoryChip(
                category: category,
                isSelected: selectedCategory == category,
                onTap: () => onCategorySelected(category),
                showCount: true,
                count: count,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Gets the total count across all categories
  int _getTotalCount() {
    if (categoryCounts == null) return 0;
    return categoryCounts!.values.fold(0, (sum, count) => sum + count);
  }
}

/// Widget for category selection in forms
///
/// This widget provides a grid of category chips for selection
/// in add/edit todo forms
class CategorySelector extends StatelessWidget {
  final TodoCategory selectedCategory;
  final Function(TodoCategory) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Wrap(
          spacing: AppConstants.paddingSmall,
          runSpacing: AppConstants.paddingSmall,
          children: TodoCategory.values.map((category) {
            return CategoryChip(
              category: category,
              isSelected: selectedCategory == category,
              onTap: () => onCategorySelected(category),
            );
          }).toList(),
        ),
      ],
    );
  }
}