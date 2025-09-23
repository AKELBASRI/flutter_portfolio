import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/category_chip.dart';
import '../utils/constants.dart';

/// Screen for adding new todos with form validation and smooth animations
///
/// PORTFOLIO NOTE: This screen demonstrates form handling, validation,
/// and beautiful UI design - excellent for portfolio screenshots showing
/// form layouts and user input interfaces
class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  TodoCategory _selectedCategory = TodoCategory.personal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// Builds the app bar with back button and title
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Add Todo'),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close),
        tooltip: 'Cancel',
      ),
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

  /// Builds the header with illustration and motivational text
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
            Icons.add_task,
            size: 64,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'Create New Task',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'What would you like to accomplish today?',
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
      },
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
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTodo,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Todo'),
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

  /// Saves the todo and navigates back
  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<TodoProvider>().addTodo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.todoAddedMessage),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add todo: $e'),
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
}