import '../local_db/todo_dao.dart';
import '../extensions/todo_extensions.dart';
import 'package:task_bloc/data/models/todo.dart';

class TodoRepo {
  final TodoDao _todoDao;

  TodoRepo(this._todoDao);

  Future<List<Todo>> fetchTodos({required int limit}) => _todoDao.getAllTodos();

  Stream<List<Todo>> watchTodos() => _todoDao.watchAllTodos();

  Future<Todo> addTodo(Todo todo) async {
    final companion = todo.toCompanion(nullToAbsent: true);
    final id = await _todoDao.insertTodo(companion);
    return todo.copyWith(id: id);
  }

  Future<Todo> updateTodo(Todo todo) async {
    final companion = todo.toCompanion();
    await _todoDao.updateTodoById(todo.id!, companion);
    return todo;
  }

  Future<void> deleteTodo(int id) => _todoDao.deleteTodoById(id);
}
