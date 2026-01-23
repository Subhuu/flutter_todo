class Todo {
  String id;
  String title;
  bool isDone;

  Todo({required this.id, required this.title, this.isDone = false});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(id: json['id'], title: json['title'], isDone: json['isDone']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }
}
