import 'package:uuid/uuid.dart';

/// Enumeration for todo categories with color coding
enum TodoCategory {
  work('Work', 0xFF1976D2),      // Blue
  personal('Personal', 0xFF388E3C), // Green
  shopping('Shopping', 0xFFFF7043); // Orange

  const TodoCategory(this.displayName, this.colorValue);

  final String displayName;
  final int colorValue;
}

/// Model class representing a Todo item
///
/// This class handles all todo data including serialization
/// for local storage and provides utility methods
class Todo {
  final String id;
  final String title;
  final String description;
  final TodoCategory category;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  Todo({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Creates a copy of this Todo with updated fields
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    TodoCategory? category,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Converts Todo to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'isCompleted': isCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates Todo from JSON data
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: TodoCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TodoCategory.personal,
      ),
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Todo{id: $id, title: $title, category: ${category.displayName}, isCompleted: $isCompleted}';
  }
}