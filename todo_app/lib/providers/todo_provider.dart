import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';

/// Provider class for managing Todo state throughout the app
///
/// This provider handles all todo-related state management and
/// communicates with the TodoService for data persistence
class TodoProvider with ChangeNotifier {
  final TodoService _todoService = TodoService.instance;

  List<Todo> _todos = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TodoCategory? _selectedCategory;
  String? _errorMessage;

  // Getters
  List<Todo> get todos => _getFilteredTodos();
  List<Todo> get allTodos => _todos;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TodoCategory? get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;

  /// Gets filtered todos based on search query and selected category
  List<Todo> _getFilteredTodos() {
    List<Todo> filteredTodos = _todos;

    // Apply category filter
    if (_selectedCategory != null) {
      filteredTodos = _todoService.getTodosByCategory(filteredTodos, _selectedCategory!);
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredTodos = _todoService.searchTodos(filteredTodos, _searchQuery);
    }

    // Sort by creation date (newest first)
    filteredTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filteredTodos;
  }

  /// Loads todos from storage
  Future<void> loadTodos() async {
    try {
      _setLoading(true);
      _clearError();
      _todos = await _todoService.loadTodos();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load todos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new todo
  Future<void> addTodo({
    required String title,
    required String description,
    required TodoCategory category,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final newTodo = Todo(
        title: title.trim(),
        description: description.trim(),
        category: category,
      );

      _todos = await _todoService.addTodo(_todos, newTodo);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add todo: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing todo
  Future<void> updateTodo({
    required String id,
    required String title,
    required String description,
    required TodoCategory category,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final existingTodo = _todos.firstWhere((todo) => todo.id == id);
      final updatedTodo = existingTodo.copyWith(
        title: title.trim(),
        description: description.trim(),
        category: category,
      );

      _todos = await _todoService.updateTodo(_todos, updatedTodo);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update todo: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a todo
  Future<void> deleteTodo(String id) async {
    try {
      _setLoading(true);
      _clearError();
      _todos = await _todoService.deleteTodo(_todos, id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete todo: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggles the completion status of a todo
  Future<void> toggleTodoCompletion(String id) async {
    try {
      _clearError();
      _todos = await _todoService.toggleTodoCompletion(_todos, id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update todo: $e');
    }
  }

  /// Sets the search query for filtering todos
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Sets the selected category for filtering todos
  void setSelectedCategory(TodoCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Clears all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  /// Gets todo statistics
  Map<String, int> getStatistics() {
    return _todoService.getTodoStatistics(_todos);
  }

  /// Gets statistics by category
  Map<TodoCategory, Map<String, int>> getStatisticsByCategory() {
    final stats = <TodoCategory, Map<String, int>>{};

    for (final category in TodoCategory.values) {
      final categoryTodos = _todoService.getTodosByCategory(_todos, category);
      stats[category] = _todoService.getTodoStatistics(categoryTodos);
    }

    return stats;
  }

  /// Clears all todos
  Future<void> clearAllTodos() async {
    try {
      _setLoading(true);
      _clearError();
      final success = await _todoService.clearAllTodos();
      if (success) {
        _todos = [];
        notifyListeners();
      } else {
        _setError('Failed to clear todos');
      }
    } catch (e) {
      _setError('Failed to clear todos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Gets todo by ID
  Todo? getTodoById(String id) {
    try {
      return _todos.firstWhere((todo) => todo.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Clears the current error message
  void clearError() {
    _clearError();
    notifyListeners();
  }
}