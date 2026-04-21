import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../services/storage_service.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  bool _isLoaded = false;

  List<Todo> get todos => List.unmodifiable(_todos);
  bool get isLoaded => _isLoaded;

  int get pendingCount => _todos.where((t) => !t.isDone).length;
  int get completedCount => _todos.where((t) => t.isDone).length;
  int get overdueCount => _todos.where((t) => t.isOverdue).length;

  List<Todo> getFiltered(String filter) {
    switch (filter) {
      case 'pending':
        return _todos.where((t) => !t.isDone).toList();
      case 'completed':
        return _todos.where((t) => t.isDone).toList();
      case 'overdue':
        return _todos.where((t) => t.isOverdue).toList();
      default:
        return _todos.toList();
    }
  }

  Future<void> loadTodos() async {
    if (_isLoaded) return;
    final data = await StorageService.loadTodos();
    _todos = data.map((json) => Todo.fromJson(json)).toList();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    _todos.insert(0, todo);
    await _save();
    notifyListeners();
  }

  Future<void> updateTodo(Todo updated) async {
    final index = _todos.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _todos[index] = updated;
      await _save();
      notifyListeners();
    }
  }

  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].isDone = !_todos[index].isDone;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    await StorageService.saveTodos(_todos.map((t) => t.toJson()).toList());
  }
}
