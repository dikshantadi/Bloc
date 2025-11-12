import 'package:equatable/equatable.dart';
import 'package:task_bloc/data/models/todo.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class fetchTodos extends TodoEvent {
  final int limit;

  const fetchTodos({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

class addTodo extends TodoEvent {
  final Todo todo;

  const addTodo(this.todo);

  @override
  List<Object?> get props => [todo];
}

class updateTodo extends TodoEvent {
  final Todo todo;

  const updateTodo(this.todo);

  @override
  List<Object?> get props => [todo];
}

class deleteTodo extends TodoEvent {
  final int? id;

  const deleteTodo(this.id);

  @override
  List<Object?> get props => [id];
}

class toggleTodoCompletion extends TodoEvent {
  final int? id;

  const toggleTodoCompletion(this.id);

  @override
  List<Object?> get props => [id];
}
