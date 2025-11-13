import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'todo_table.dart';
import 'todo_dao.dart';

part 'app_db.g.dart';

@DriftDatabase(tables: [TodoTable], daos: [TodoDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(NativeDatabase db) : super(db);

  static AppDatabase? _instance;

  factory AppDatabase.instance() {
    if (_instance != null) return _instance!;
    throw Exception("AppDatabase not initialized. Call initDatabase first.");
  }

  static Future<void> initDatabase() async {
    final docs = await getApplicationDocumentsDirectory();
    final file = File(p.join(docs.path, 'todos.sqlite'));
    final db = NativeDatabase(file);
    _instance = AppDatabase._internal(db);
  }

  @override
  int get schemaVersion => 1;
}
