enum TaskStatus { todo, inProgress, done }

enum TaskPriority { high, medium, low }

class Task {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final DateTime createdAt;
  final TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
    required this.priority,
  });

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'priority': priority.index,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: TaskStatus.values[json['status']],
      createdAt: DateTime.parse(json['createdAt']),
      priority: json['priority'] != null ? TaskPriority.values[json['priority']] : TaskPriority.medium, // Default to Medium if null
    );
  }
}
