import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar.dart';
import '../utils/constants.dart';
import 'add_todo_screen.dart';
import 'edit_todo_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

/// Home screen displaying the list of todos with search and filter functionality
///
/// PORTFOLIO NOTE: This screen showcases the main todo list interface,
/// perfect for demonstrating clean UI design, smooth animations,
/// and comprehensive functionality in portfolio screenshots
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _fabAnimationController.forward();

    // Load todos when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Builds the main body based on the selected bottom navigation tab
  Widget _buildBody() {
    switch (_currentBottomNavIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const StatisticsScreen();
      case 2:
        return const SettingsScreen();
      default:
        return _buildHomeTab();
    }
  }

  /// Builds the home tab with todo list
  Widget _buildHomeTab() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          _buildSliverAppBar(innerBoxIsScrolled),
        ];
      },
      body: Column(
        children: [
          _buildSearchSection(),
          _buildCategoryFilters(),
          Expanded(child: _buildTodoList()),
        ],
      ),
    );
  }

  /// Builds the sliver app bar with smooth animations
  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: innerBoxIsScrolled ? 4 : 0,
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedOpacity(
          opacity: innerBoxIsScrolled ? 1.0 : 0.0,
          duration: AppConstants.animationFast,
          child: const Text(AppConstants.appName),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Consumer<TodoProvider>(
                    builder: (context, todoProvider, child) {
                      final stats = todoProvider.getStatistics();
                      return Text(
                        '${stats['total']} tasks, ${stats['completed']} completed',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the search section
  Widget _buildSearchSection() {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return CustomSearchBar(
          onSearchChanged: todoProvider.setSearchQuery,
          initialValue: todoProvider.searchQuery,
        );
      },
    );
  }

  /// Builds the category filter chips
  Widget _buildCategoryFilters() {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        final categoryStats = todoProvider.getStatisticsByCategory();
        final categoryCounts = categoryStats.map(
          (category, stats) => MapEntry(category, stats['total'] ?? 0),
        );

        return Container(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
          child: CategoryFilterChips(
            selectedCategory: todoProvider.selectedCategory,
            onCategorySelected: todoProvider.setSelectedCategory,
            categoryCounts: categoryCounts,
          ),
        );
      },
    );
  }

  /// Builds the todo list with animations and empty states
  Widget _buildTodoList() {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        if (todoProvider.isLoading) {
          return _buildLoadingState();
        }

        if (todoProvider.errorMessage != null) {
          return _buildErrorState(todoProvider.errorMessage!);
        }

        final todos = todoProvider.todos;

        if (todos.isEmpty) {
          return _buildEmptyState();
        }

        return _buildTodoListView(todos);
      },
    );
  }

  /// Builds the loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppConstants.paddingMedium),
          Text('Loading todos...'),
        ],
      ),
    );
  }

  /// Builds the error state
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          ElevatedButton(
            onPressed: () => context.read<TodoProvider>().loadTodos(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Builds the empty state
  Widget _buildEmptyState() {
    final todoProvider = context.read<TodoProvider>();
    final hasFilters = todoProvider.searchQuery.isNotEmpty ||
                      todoProvider.selectedCategory != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.task_alt,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            hasFilters ? AppConstants.emptySearchMessage : AppConstants.emptyTodosMessage,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            TextButton(
              onPressed: todoProvider.clearFilters,
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the todo list view with animations
  Widget _buildTodoListView(List<Todo> todos) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 0,
        right: 0,
        top: AppConstants.paddingSmall,
        bottom: 100, // Space for FAB
      ),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(
          key: ValueKey(todo.id),
          todo: todo,
          onTap: () => _showTodoDetails(todo),
          onEdit: () => _editTodo(todo),
        );
      },
    );
  }

  /// Builds the bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentBottomNavIndex,
      onTap: (index) {
        setState(() {
          _currentBottomNavIndex = index;
        });
      },
      items: AppConstants.bottomNavItems,
    );
  }

  /// Builds the floating action button with animation
  Widget _buildFloatingActionButton() {
    if (_currentBottomNavIndex != 0) {
      return const SizedBox.shrink();
    }

    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton(
        onPressed: _addTodo,
        heroTag: 'add_todo_fab',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Shows todo details in a bottom sheet
  void _showTodoDetails(Todo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTodoDetailsSheet(todo),
    );
  }

  /// Builds the todo details bottom sheet
  Widget _buildTodoDetailsSheet(Todo todo) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    todo.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),

            // Description
            if (todo.description.isNotEmpty) ...[
              Text(
                todo.description,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
            ],

            // Category
            Row(
              children: [
                Icon(Icons.category, size: AppConstants.iconSizeSmall),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(todo.category.displayName),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            // Status
            Row(
              children: [
                Icon(
                  todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: AppConstants.iconSizeSmall,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(todo.isCompleted ? 'Completed' : 'Pending'),
              ],
            ),
            const SizedBox(height: AppConstants.paddingLarge),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editTodo(todo);
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<TodoProvider>().toggleTodoCompletion(todo.id);
                    },
                    child: Text(todo.isCompleted ? 'Mark Pending' : 'Mark Complete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to add todo screen
  void _addTodo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTodoScreen()),
    );
  }

  /// Navigates to edit todo screen
  void _editTodo(Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTodoScreen(todo: todo),
      ),
    );
  }
}