import 'package:drift/drift.dart';
import 'app_db.dart';
import 'todo_table.dart';
import 'package:task_bloc/data/models/todo.dart';

part 'todo_dao.g.dart';

@DriftAccessor(tables: [TodoTable])
class TodoDao extends DatabaseAccessor<AppDatabase> with _$TodoDaoMixin {
  final AppDatabase db;
  TodoDao(this.db) : super(db);

  Future<List<Todo>> getAllTodos() async {
    final rows = await select(db.todoTable).get();
    return rows
        .map(
          (r) => Todo(
            id: r.id,
            title: r.title,
            description: r.description,
            isCompleted: r.isCompleted,
            userId: r.userId,
          ),
        )
        .toList();
  }

  Stream<List<Todo>> watchAllTodos() {
    return select(db.todoTable).watch().map(
      (rows) => rows
          .map(
            (r) => Todo(
              id: r.id,
              title: r.title,
              description: r.description,
              isCompleted: r.isCompleted,
              userId: r.userId,
            ),
          )
          .toList(),
    );
  }

  Future<int> insertTodo(TodoTableCompanion companion) =>
      into(db.todoTable).insert(companion);

  Future<int> updateTodoById(int id, TodoTableCompanion companion) =>
      (update(db.todoTable)..where((t) => t.id.equals(id))).write(companion);

  Future<int> deleteTodoById(int id) =>
      (delete(db.todoTable)..where((t) => t.id.equals(id))).go();
}
