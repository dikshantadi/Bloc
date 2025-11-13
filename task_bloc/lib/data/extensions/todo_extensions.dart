import 'package:task_bloc/data/local_db/app_db.dart';
import '../models/todo.dart';
import 'package:drift/drift.dart';

extension TodoDriftX on Todo {
  TodoTableCompanion toCompanion({bool nullToAbsent = false}) {
    return TodoTableCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id!),
      title: Value(title),
      description: Value(description),
      isCompleted: Value(isCompleted),
      userId: Value(userId),
    );
  }
}
