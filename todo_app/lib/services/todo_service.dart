import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

/// Service class for handling Todo data persistence
///
/// This service manages all local storage operations for todos
/// using SharedPreferences for data persistence
class TodoService {
  static const String _todosKey = 'todos_key';
  static TodoService? _instance;

  TodoService._internal();

  /// Singleton pattern to ensure single instance
  static TodoService get instance {
    _instance ??= TodoService._internal();
    return _instance!;
  }

  /// Loads all todos from local storage
  ///
  /// Returns empty list if no todos are found or if an error occurs
  Future<List<Todo>> loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getString(_todosKey);

      if (todosJson == null) {
        return [];
      }

      final List<dynamic> todosList = json.decode(todosJson);
      return todosList.map((todoJson) => Todo.fromJson(todoJson)).toList();
    } catch (e) {
      // Log error in production app
      print('Error loading todos: $e');
      return [];
    }
  }

  /// Saves all todos to local storage
  ///
  /// Returns true if successful, false otherwise
  Future<bool> saveTodos(List<Todo> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = json.encode(todos.map((todo) => todo.toJson()).toList());
      return await prefs.setString(_todosKey, todosJson);
    } catch (e) {
      // Log error in production app
      print('Error saving todos: $e');
      return false;
    }
  }

  /// Adds a new todo and saves to storage
  ///
  /// Returns the updated list of todos
  Future<List<Todo>> addTodo(List<Todo> currentTodos, Todo newTodo) async {
    final updatedTodos = [...currentTodos, newTodo];
    final success = await saveTodos(updatedTodos);
    return success ? updatedTodos : currentTodos;
  }

  /// Updates an existing todo and saves to storage
  ///
  /// Returns the updated list of todos
  Future<List<Todo>> updateTodo(List<Todo> currentTodos, Todo updatedTodo) async {
    final updatedTodos = currentTodos.map((todo) {
      return todo.id == updatedTodo.id ? updatedTodo : todo;
    }).toList();

    final success = await saveTodos(updatedTodos);
    return success ? updatedTodos : currentTodos;
  }

  /// Deletes a todo and saves to storage
  ///
  /// Returns the updated list of todos
  Future<List<Todo>> deleteTodo(List<Todo> currentTodos, String todoId) async {
    final updatedTodos = currentTodos.where((todo) => todo.id != todoId).toList();
    final success = await saveTodos(updatedTodos);
    return success ? updatedTodos : currentTodos;
  }

  /// Toggles the completion status of a todo
  ///
  /// Returns the updated list of todos
  Future<List<Todo>> toggleTodoCompletion(List<Todo> currentTodos, String todoId) async {
    final updatedTodos = currentTodos.map((todo) {
      if (todo.id == todoId) {
        return todo.copyWith(
          isCompleted: !todo.isCompleted,
          completedAt: !todo.isCompleted ? DateTime.now() : null,
        );
      }
      return todo;
    }).toList();

    final success = await saveTodos(updatedTodos);
    return success ? updatedTodos : currentTodos;
  }

  /// Clears all todos from storage
  ///
  /// Returns true if successful
  Future<bool> clearAllTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_todosKey);
    } catch (e) {
      print('Error clearing todos: $e');
      return false;
    }
  }

  /// Gets statistics about todos
  ///
  /// Returns a map with counts of total, completed, and pending todos
  Map<String, int> getTodoStatistics(List<Todo> todos) {
    final completed = todos.where((todo) => todo.isCompleted).length;
    final pending = todos.length - completed;

    return {
      'total': todos.length,
      'completed': completed,
      'pending': pending,
    };
  }

  /// Gets todos by category
  ///
  /// Returns filtered list of todos for the specified category
  List<Todo> getTodosByCategory(List<Todo> todos, TodoCategory category) {
    return todos.where((todo) => todo.category == category).toList();
  }

  /// Searches todos by title and description
  ///
  /// Returns filtered list of todos matching the search query
  List<Todo> searchTodos(List<Todo> todos, String query) {
    if (query.isEmpty) return todos;

    final lowercaseQuery = query.toLowerCase();
    return todos.where((todo) {
      return todo.title.toLowerCase().contains(lowercaseQuery) ||
             todo.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}