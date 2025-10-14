import 'package:dio/dio.dart';
import 'package:task_bloc/models/todo.dart';

class TodoRepo {
  final Dio _dio;

  TodoRepo({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com/todos'),
          );

  Future<List<Todo>> fetchTodos({int limit = 50}) async {
    try {
      final response = await _dio.get('/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Todo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load todos');
      }
    } catch (e) {
      throw Exception('Failed to load todos: $e');
    }
  }

  Future<Todo> addTodo(Todo todo) async {
    try {
      final response = await _dio.post('/', data: todo.toJson());
      if (response.statusCode == 201) {
        return Todo.fromJson(response.data);
      } else {
        throw Exception('Failed to add todo');
      }
    } catch (e) {
      throw Exception('Failed to add todo: $e');
    }
  }

  Future<Todo> updateTodo(Todo todo) async {
    try {
      final response = await _dio.put('/${todo.id}', data: todo.toJson());
      if (response.statusCode == 200) {
        return Todo.fromJson(response.data);
      } else {
        throw Exception('Failed to update todo');
      }
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      final response = await _dio.delete('/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete todo');
      }
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }
}
