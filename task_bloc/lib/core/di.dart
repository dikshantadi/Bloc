import 'package:get_it/get_it.dart';
import '../data/local_db/app_db.dart';
import '../data/local_db/todo_dao.dart';
import '../data/repository/todo_repo.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  await AppDatabase.initDatabase();
  getIt.registerSingleton<AppDatabase>(AppDatabase.instance());
  getIt.registerSingleton<TodoDao>(TodoDao(getIt<AppDatabase>()));
  getIt.registerSingleton<TodoRepo>(TodoRepo(getIt<TodoDao>()));
}
