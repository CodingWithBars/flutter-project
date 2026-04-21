import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/todo_provider.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/todo_tile.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<TodoProvider>(
        builder: (context, provider, _) {
          final filteredTodos = provider.getFiltered(_filter);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To-Do List',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.pendingCount} pending · ${provider.completedCount} completed',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                          context, 'All', 'all', provider.todos.length),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          context, 'Pending', 'pending', provider.pendingCount),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, 'Completed', 'completed',
                          provider.completedCount),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          context, 'Overdue', 'overdue', provider.overdueCount),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Todo list
              Expanded(
                child: filteredTodos.isEmpty
                    ? EmptyState(
                        icon: _filter == 'all'
                            ? Icons.checklist_rounded
                            : Icons.filter_list_off_rounded,
                        title: _filter == 'all'
                            ? 'No tasks yet'
                            : 'No $_filter tasks',
                        subtitle: _filter == 'all'
                            ? 'Tap the + button below to add your first task'
                            : 'Tasks matching this filter will appear here',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: filteredTodos.length,
                        itemBuilder: (context, index) {
                          final todo = filteredTodos[index];
                          return TodoTile(
                            todo: todo,
                            onToggle: () => provider.toggleTodo(todo.id),
                            onEdit: () =>
                                showAddTodoSheet(context, todo: todo),
                            onDelete: () => provider.deleteTodo(todo.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, String value, int count) {
    final isSelected = _filter == value;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return FilterChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          color: isSelected ? primaryColor : Colors.white54,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: primaryColor.withValues(alpha: 0.15),
      backgroundColor: Theme.of(context).colorScheme.surface,
      checkmarkColor: primaryColor,
      side: BorderSide(
        color: isSelected ? primaryColor.withValues(alpha: 0.3) : Colors.white10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
