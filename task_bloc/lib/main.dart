import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_bloc/core/di.dart';
import 'data/models/todo.dart';
import 'data/repository/todo_repo.dart';
import 'logic/bloc/todo_bloc.dart';
import 'logic/bloc/todo_event.dart';
import 'logic/bloc/todo_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies(); // Registers TodoRepo, AppDatabase via GetIt
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final todoRepo = getIt<TodoRepo>();
    return MaterialApp(
      title: 'Flutter BLoC Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => TodoBloc(repository: todoRepo)..add(const fetchTodos()),
        child: const TodoPage(),
      ),
    );
  }
}

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo App')),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoLoaded) {
            return state.todos.isEmpty
                ? const Center(child: Text('No todos available'))
                : ListView.separated(
                    itemCount: state.todos.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final todo = state.todos[index];
                      return ListTile(
                        title: Text(todo.title),
                        subtitle: Text(todo.description),
                        trailing: Checkbox(
                          value: todo.isCompleted,
                          onChanged: (_) {
                            context.read<TodoBloc>().add(
                              toggleTodoCompletion(todo.id),
                            );
                          },
                        ),
                        onLongPress: () {
                          context.read<TodoBloc>().add(deleteTodo(todo.id));
                        },
                      );
                    },
                  );
          } else if (state is TodoError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No data'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              if (title.isEmpty) return;

              final newTodo = Todo(
                userId: 1,
                title: title,
                description: description,
              );
              context.read<TodoBloc>().add(addTodo(newTodo));
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
