enum RecurrenceType { none, daily, weekly, monthly }

enum EndCondition { never, date, count }

class Todo {
  String id;
  String title;
  bool isDone;

  // Advanced Recurrence
  RecurrenceType recurrenceType;
  int interval; // e.g., 2 for "every 2 days"
  List<int> weekDays; // 1=Mon, 7=Sun (for weekly)
  DateTime? startDate; // When the tracking starts

  EndCondition endCondition;
  DateTime? endDate;
  int maxOccurrences;
  int currentOccurrence;

  DateTime? completedAt;

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
    this.recurrenceType = RecurrenceType.none,
    this.interval = 1,
    this.weekDays = const [],
    this.startDate,
    this.endCondition = EndCondition.never,
    this.endDate,
    this.maxOccurrences = 0,
    this.currentOccurrence = 0,
    this.completedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    // Legacy migration helper
    RecurrenceType rType = RecurrenceType.none;
    if (json['repeat'] != null) {
      if (json['repeat'] == 'daily') rType = RecurrenceType.daily;
      if (json['repeat'] == 'weekly') rType = RecurrenceType.weekly;
      if (json['repeat'] == 'monthly') rType = RecurrenceType.monthly;
    } else if (json['recurrenceType'] != null) {
      rType = RecurrenceType.values[json['recurrenceType']];
    }

    return Todo(
      id: json['id'],
      title: json['title'],
      isDone: json['isDone'],
      recurrenceType: rType,
      interval: json['interval'] ?? 1,
      weekDays: (json['weekDays'] as List<dynamic>?)?.cast<int>() ?? [],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endCondition: json['endCondition'] != null
          ? EndCondition.values[json['endCondition']]
          : EndCondition.never,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      maxOccurrences: json['maxOccurrences'] ?? 0,
      currentOccurrence: json['currentOccurrence'] ?? 0,
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
      'recurrenceType': recurrenceType.index,
      'interval': interval,
      'weekDays': weekDays,
      'startDate': startDate?.toIso8601String(),
      'endCondition': endCondition.index,
      'endDate': endDate?.toIso8601String(),
      'maxOccurrences': maxOccurrences,
      'currentOccurrence': currentOccurrence,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
