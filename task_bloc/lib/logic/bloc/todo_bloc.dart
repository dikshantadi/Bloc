import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_bloc/services/notification_service.dart';
import '../../data/repository/todo_repo.dart';
import 'todo_event.dart';
import 'todo_state.dart';
import '../../data/models/todo.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepo repository;

  TodoBloc({required this.repository}) : super(TodoInitial()) {
    on<fetchTodos>(_onFetchTodos);
    on<addTodo>(_onAddTodo);
    on<updateTodo>(_onUpdateTodo);
    on<deleteTodo>(_onDeleteTodo);
    on<toggleTodoCompletion>(_onToggleTodo);
  }

  Future<void> _onFetchTodos(fetchTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = await repository.fetchTodos(limit: event.limit);
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onAddTodo(addTodo event, Emitter<TodoState> emit) async {
    final current = state;

    emit(TodoLoading());
    try {
      final created = await repository.addTodo(event.todo);

      List<Todo> updated;
      if (current is TodoLoaded) {
        updated = List<Todo>.from(current.todos)..insert(0, created);
      } else {
        updated = [created];
      }

      emit(TodoLoaded(updated));

      await NotificationService.showInstantNotification(
        "New Task Added",
        created.title,
      );

      emit(AddTodoSuccess());
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onUpdateTodo(updateTodo event, Emitter<TodoState> emit) async {
    final current = state;
    if (current is! TodoLoaded) {
      emit(TodoError('No todos to update'));
      return;
    }
    await NotificationService.showInstantNotification(
      "Task Updated",
      event.todo.title,
    );
    emit(TodoLoading());
    try {
      final updatedFromApi = await repository.updateTodo(event.todo);
      final updatedList = current.todos.map((t) {
        if (t.id == updatedFromApi.id) return updatedFromApi;
        return t;
      }).toList();
      emit(TodoLoaded(updatedList));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onDeleteTodo(deleteTodo event, Emitter<TodoState> emit) async {
    final current = state;
    if (current is! TodoLoaded) {
      emit(TodoError('No todos to delete'));
      return;
    }
    await NotificationService.showInstantNotification(
      "Task Deleted",
      "A task was removed",
    );
    emit(TodoLoading());
    try {
      await repository.deleteTodo(event.id as int);
      final updated = current.todos.where((t) => t.id != event.id).toList();
      emit(TodoLoaded(updated));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onToggleTodo(
    toggleTodoCompletion event,
    Emitter<TodoState> emit,
  ) async {
    final current = state;
    if (current is! TodoLoaded) {
      emit(TodoError('No todos to toggle'));
      return;
    }

    final idx = current.todos.indexWhere((t) => t.id == event.id);
    if (idx == -1) {
      emit(TodoError('Todo not found'));
      return;
    }

    final toggled = current.todos[idx].copyWith(
      isCompleted: !current.todos[idx].isCompleted,
    );

    final newList = List<Todo>.from(current.todos);
    newList[idx] = toggled;
    emit(TodoLoaded(newList));

    try {
      if (toggled.id != null) {
        await repository.updateTodo(toggled);
      }
    } catch (e) {
      final reverted = List<Todo>.from(newList);
      reverted[idx] = reverted[idx].copyWith(
        isCompleted: !reverted[idx].isCompleted,
      );
      emit(TodoLoaded(reverted));
      emit(TodoError('Failed to persist toggle: ${e.toString()}'));
    }
  }
}
