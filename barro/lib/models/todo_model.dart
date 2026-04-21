class Todo {
  final String id;
  String title;
  String description;
  String? subjectName;
  bool isDone;
  DateTime dueDate;
  String priority;
  DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.subjectName,
    this.isDone = false,
    required this.dueDate,
    this.priority = 'medium',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue => !isDone && dueDate.isBefore(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'subjectName': subjectName,
        'isDone': isDone,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        subjectName: json['subjectName'] as String?,
        isDone: json['isDone'] as bool? ?? false,
        dueDate: DateTime.parse(json['dueDate'] as String),
        priority: json['priority'] as String? ?? 'medium',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}
