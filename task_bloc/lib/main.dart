// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/todo_repo.dart';
import 'bloc/todo_bloc.dart';
import 'bloc/todo_event.dart';
import 'bloc/todo_state.dart';
import 'models/todo.dart';

void main() {
  final repo = TodoRepo();
  runApp(MyApp(repository: repo));
}

class MyApp extends StatelessWidget {
  final TodoRepo repository;
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter ToDo BLoC + Dio',
      home: BlocProvider(
        create: (_) =>
            TodoBloc(repository: repository)..add(const fetchTodos(limit: 20)),
        child: const TodoPage(),
      ),
    );
  }
}

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TodoBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('todo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              bloc.add(const fetchTodos(limit: 20));
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          if (state is TodoInitial || state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoLoaded) {
            if (state.todos.isEmpty) {
              return const Center(child: Text('No todos'));
            }
            return ListView.builder(
              itemCount: state.todos.length,
              itemBuilder: (context, index) {
                final t = state.todos[index];
                return Dismissible(
                  key: ValueKey(t.id ?? '${t.title}-$index'),
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    if (t.id != null) {
                      bloc.add(deleteTodo(t.id!));
                    } else {
                      // for local items without ID
                      // you might want a local delete event here instead
                    }
                  },
                  child: ListTile(
                    title: Text(t.title),
                    leading: Checkbox(
                      value: t.isCompleted,
                      onChanged: (_) {
                        if (t.id != null) {
                          bloc.add(toggleTodoCompletion(t.id!));
                        } else {}
                      },
                    ),
                    subtitle: Text(
                      'userId: ${t.userId} | id: ${t.id ?? 'local'}',
                    ),
                    onTap: () {
                      if (t.id != null) bloc.add(toggleTodoCompletion(t.id!));
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final newTitle = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            final controller = TextEditingController(
                              text: t.title,
                            );
                            return AlertDialog(
                              title: const Text('Edit title'),
                              content: TextField(controller: controller),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pop(controller.text),
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                        if (newTitle != null && newTitle.trim().isNotEmpty) {
                          final updated = t.copyWith(title: newTitle.trim());
                          bloc.add(updateTodo(updated));
                        }
                      },
                    ),
                  ),
                );
              },
            );
          } else if (state is TodoError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final controller = TextEditingController();
          final title = await showDialog<String?>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add Todo'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Todo title'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(controller.text),
                  child: const Text('Add'),
                ),
              ],
            ),
          );

          if (title != null && title.trim().isNotEmpty) {
            final newTodo = Todo(
              title: title.trim(),
              isCompleted: false,
              userId: 1,
              id: null,
              description: '',
            );
            bloc.add(addTodo(newTodo));
          }
        },
      ),
    );
  }
}
