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
    this.description = '',
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

  @override
  List<Object?> get props => [id, title, description, isCompleted, userId];
}
