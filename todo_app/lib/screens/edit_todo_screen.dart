import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/category_chip.dart';
import '../utils/constants.dart';

/// Screen for editing existing todos with pre-filled data and validation
///
/// PORTFOLIO NOTE: This screen demonstrates edit functionality with
/// pre-populated forms and state management - great for showing
/// CRUD operations in portfolio presentations
class EditTodoScreen extends StatefulWidget {
  final Todo todo;

  const EditTodoScreen({
    super.key,
    required this.todo,
  });

  @override
  State<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late TodoCategory _selectedCategory;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing todo data
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description);
    _selectedCategory = widget.todo.category;

    // Set up animations
    _animationController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Listen for changes
    _titleController.addListener(_checkForChanges);
    _descriptionController.addListener(_checkForChanges);

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.removeListener(_checkForChanges);
    _descriptionController.removeListener(_checkForChanges);
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Checks if any changes have been made to the form
  void _checkForChanges() {
    final hasChanges = _titleController.text.trim() != widget.todo.title ||
                      _descriptionController.text.trim() != widget.todo.description ||
                      _selectedCategory != widget.todo.category;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        final bool shouldPop = await _onWillPop() ?? false;
        if (context.mounted && shouldPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  /// Builds the app bar with back button and title
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Edit Todo'),
      leading: IconButton(
        onPressed: () => _handleBackPress(),
        icon: const Icon(Icons.close),
        tooltip: 'Cancel',
      ),
      actions: [
        if (_hasChanges)
          TextButton(
            onPressed: _isLoading ? null : _saveTodo,
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the main body with form
  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildTitleField(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildDescriptionField(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildCategorySelector(),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildStatusSection(),
                    const SizedBox(height: AppConstants.paddingXLarge),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the header with todo information
  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Column(
        children: [
          Icon(
            Icons.edit,
            size: 64,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'Edit Task',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Update your task details below',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the title input field
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Enter task title...',
            prefixIcon: Icon(Icons.title),
          ),
          textInputAction: TextInputAction.next,
          maxLength: AppConstants.maxTitleLength,
          validator: _validateTitle,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  /// Builds the description input field
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'Add more details... (optional)',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 4,
          maxLength: AppConstants.maxDescriptionLength,
          validator: _validateDescription,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  /// Builds the category selector
  Widget _buildCategorySelector() {
    return CategorySelector(
      selectedCategory: _selectedCategory,
      onCategorySelected: (category) {
        setState(() {
          _selectedCategory = category;
        });
        _checkForChanges();
      },
    );
  }

  /// Builds the status section showing completion status
  Widget _buildStatusSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: widget.todo.isCompleted
            ? colorScheme.primaryContainer.withOpacity(0.3)
            : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: widget.todo.isCompleted
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.todo.isCompleted ? Icons.check_circle : Icons.schedule,
            color: widget.todo.isCompleted
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.todo.isCompleted ? 'Completed' : 'Pending',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.todo.isCompleted
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
                if (widget.todo.isCompleted && widget.todo.completedAt != null)
                  Text(
                    'Completed on ${_formatDate(widget.todo.completedAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<TodoProvider>().toggleTodoCompletion(widget.todo.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.todo.isCompleted
                        ? AppConstants.todoUncompletedMessage
                        : AppConstants.todoCompletedMessage,
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              widget.todo.isCompleted ? 'Mark Pending' : 'Mark Complete',
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the bottom bar with action buttons
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: AppConstants.paddingLarge,
        right: AppConstants.paddingLarge,
        top: AppConstants.paddingMedium,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _handleBackPress,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading || !_hasChanges ? null : _saveTodo,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Validates the title field
  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.validationErrorTitle;
    }
    if (value.trim().length > AppConstants.maxTitleLength) {
      return AppConstants.validationErrorTitleTooLong;
    }
    return null;
  }

  /// Validates the description field
  String? _validateDescription(String? value) {
    if (value != null && value.length > AppConstants.maxDescriptionLength) {
      return AppConstants.validationErrorDescriptionTooLong;
    }
    return null;
  }

  /// Handles back button press with unsaved changes warning
  void _handleBackPress() {
    if (_hasChanges) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.pop(context);
    }
  }

  /// Shows dialog when there are unsaved changes
  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to leave without saving?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close edit screen
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  /// Handles back button system navigation
  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      _showUnsavedChangesDialog();
      return false;
    }
    return true;
  }

  /// Saves the todo and navigates back
  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<TodoProvider>().updateTodo(
        id: widget.todo.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.todoUpdatedMessage),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update todo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Formats date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}