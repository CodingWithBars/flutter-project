import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../provider/todo_provider.dart';
import '../services/notification_service.dart';

void showAddTodoSheet(BuildContext context, {Todo? todo}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddTodoSheet(todo: todo),
  );
}

class AddTodoSheet extends StatefulWidget {
  final Todo? todo;
  const AddTodoSheet({super.key, this.todo});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subjectController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late DateTime _dueDate;
  String _priority = 'medium';

  bool get isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descController.text = widget.todo!.description;
      _subjectController.text = widget.todo!.subjectName ?? '';
      _dueDate = widget.todo!.dueDate;
      _priority = widget.todo!.priority;
    } else {
      _dueDate = DateTime.now().add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TodoProvider>();

    if (isEditing) {
      final updated = Todo(
        id: widget.todo!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        subjectName: _subjectController.text.trim().isEmpty ? null : _subjectController.text.trim(),
        isDone: widget.todo!.isDone,
        dueDate: _dueDate,
        priority: _priority,
        createdAt: widget.todo!.createdAt,
      );
      provider.updateTodo(updated);
      _scheduleNotification(updated);
    } else {
      final todo = Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        subjectName: _subjectController.text.trim().isEmpty ? null : _subjectController.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
      );
      provider.addTodo(todo);
      _scheduleNotification(todo);
    }

    Navigator.pop(context);
  }

  void _scheduleNotification(Todo todo) {
    if (todo.isDone) return;
    
    // Schedule for 1 hour before due date
    final scheduledTime = todo.dueDate.subtract(const Duration(hours: 1));
    if (scheduledTime.isAfter(DateTime.now())) {
      NotificationService().scheduleNotification(
        id: todo.id.hashCode,
        title: 'Task Reminder',
        body: '${todo.title} is due in 1 hour!',
        scheduledDate: scheduledTime,
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEditing ? 'Edit Task' : 'Add Task',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'e.g. Study for midterms',
                    prefixIcon: Icon(Icons.task_alt_rounded),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Description
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Add more details...',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                // Subject Name
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject / Course Name (optional)',
                    hintText: 'e.g. Math 101',
                    prefixIcon: Icon(Icons.class_rounded),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                // Due date
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(_dueDate),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Priority selector
                const Text(
                  'Priority',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'low',
                      label: Text('Low'),
                      icon: Icon(Icons.arrow_downward_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: 'medium',
                      label: Text('Medium'),
                      icon: Icon(Icons.remove_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: 'high',
                      label: Text('High'),
                      icon: Icon(Icons.arrow_upward_rounded, size: 16),
                    ),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (v) =>
                      setState(() => _priority = v.first),
                ),
                const SizedBox(height: 28),
                // Save button
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Update Task' : 'Add Task',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
