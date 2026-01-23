import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoService {
  static const String _todosKey = 'todos';

  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString(_todosKey);
    if (todosString != null) {
      final List<dynamic> decoded = jsonDecode(todosString);
      return decoded.map((e) => Todo.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(todos.map((e) => e.toJson()).toList());
    await prefs.setString(_todosKey, encoded);
  }
}
