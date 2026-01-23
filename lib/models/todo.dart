class Todo {
  String id;
  String title;
  bool isDone;
  String repeat; // 'none', 'daily', 'weekly'
  DateTime? completedAt;

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
    this.repeat = 'none',
    this.completedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      isDone: json['isDone'],
      repeat: json['repeat'] ?? 'none',
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'repeat': repeat,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
