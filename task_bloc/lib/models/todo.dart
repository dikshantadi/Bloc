import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final int? userId;

  const Todo({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.userId,
  });

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? userId,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'],
      id: json['id'],
      title: json['title'] ?? '',
      isCompleted: json['completed'] ?? false,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'description': description,
      'completed': isCompleted,
    };
  }

  @override
  List<Object?> get props => [id, title, description, isCompleted, userId];
}
