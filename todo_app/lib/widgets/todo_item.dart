import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../utils/constants.dart';

/// Widget for displaying individual todo items in the list
///
/// This widget provides a beautiful card layout with animations,
/// category indicators, and action buttons for edit/delete operations
class TodoItem extends StatefulWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const TodoItem({
    super.key,
    required this.todo,
    this.onTap,
    this.onEdit,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Card(
              elevation: widget.todo.isCompleted ? 1 : 3,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row with checkbox, title, and actions
                      Row(
                        children: [
                          // Completion checkbox
                          _buildCheckbox(context),
                          const SizedBox(width: AppConstants.paddingSmall),

                          // Title and category
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  widget.todo.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    decoration: widget.todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: widget.todo.isCompleted
                                        ? colorScheme.onSurface.withOpacity(0.6)
                                        : colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),

                                // Category chip
                                _buildCategoryChip(context),
                              ],
                            ),
                          ),

                          // Action buttons
                          _buildActionButtons(context),
                        ],
                      ),

                      // Description (if not empty)
                      if (widget.todo.description.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          widget.todo.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: widget.todo.isCompleted
                                ? colorScheme.onSurface.withOpacity(0.5)
                                : colorScheme.onSurface.withOpacity(0.7),
                            decoration: widget.todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Footer with date information
                      const SizedBox(height: AppConstants.paddingSmall),
                      _buildFooter(context, dateFormat),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the completion checkbox with animation
  Widget _buildCheckbox(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return AnimatedContainer(
          duration: AppConstants.animationFast,
          child: Checkbox(
            value: widget.todo.isCompleted,
            onChanged: (value) {
              if (value != null) {
                todoProvider.toggleTodoCompletion(widget.todo.id);
                _showCompletionFeedback(context, value);
              }
            },
          ),
        );
      },
    );
  }

  /// Builds the category chip with color coding
  Widget _buildCategoryChip(BuildContext context) {
    final categoryColor = Color(widget.todo.category.colorValue);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        widget.todo.category.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: categoryColor,
        ),
      ),
    );
  }

  /// Builds the action buttons (edit and delete)
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit button
        IconButton(
          onPressed: widget.onEdit,
          icon: const Icon(Icons.edit_outlined),
          iconSize: AppConstants.iconSizeSmall,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Edit todo',
        ),

        // Delete button
        IconButton(
          onPressed: () => _showDeleteConfirmation(context),
          icon: const Icon(Icons.delete_outline),
          iconSize: AppConstants.iconSizeSmall,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Delete todo',
        ),
      ],
    );
  }

  /// Builds the footer with date information
  Widget _buildFooter(BuildContext context, DateFormat dateFormat) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 14,
          color: colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 4),
        Text(
          'Created ${dateFormat.format(widget.todo.createdAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        if (widget.todo.isCompleted && widget.todo.completedAt != null) ...[
          const SizedBox(width: AppConstants.paddingMedium),
          Icon(
            Icons.check_circle,
            size: 14,
            color: colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            'Completed ${dateFormat.format(widget.todo.completedAt!)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  /// Shows completion feedback to the user
  void _showCompletionFeedback(BuildContext context, bool isCompleted) {
    final message = isCompleted
        ? AppConstants.todoCompletedMessage
        : AppConstants.todoUncompletedMessage;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Todo'),
          content: Text(
            'Are you sure you want to delete "${widget.todo.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTodo(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Deletes the todo with animation
  void _deleteTodo(BuildContext context) {
    // Animate out before deleting
    _animationController.reverse().then((_) {
      context.read<TodoProvider>().deleteTodo(widget.todo.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.todoDeletedMessage),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}