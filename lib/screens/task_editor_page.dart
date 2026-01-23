import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/glass_container.dart';

class TaskEditorPage extends StatefulWidget {
  final Todo? todo; // If null, creating new
  final Function(Todo) onSave;

  const TaskEditorPage({super.key, this.todo, required this.onSave});

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  final _titleController = TextEditingController();

  RecurrenceType _recurrenceType = RecurrenceType.none;
  int _interval = 1;
  List<int> _weekDays = [];

  EndCondition _endCondition = EndCondition.never;
  DateTime? _endDate;
  int _maxOccurrences = 5;

  DateTime? _startDate;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _recurrenceType = widget.todo!.recurrenceType;
      _interval = widget.todo!.interval;
      _weekDays = List.from(widget.todo!.weekDays);
      _endCondition = widget.todo!.endCondition;
      _endDate = widget.todo!.endDate;
      _maxOccurrences = widget.todo!.maxOccurrences;
      _startDate = widget.todo!.startDate;
    } else {
      _startDate = DateTime.now();
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;

    final todo = Todo(
      id: widget.todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      isDone: widget.todo?.isDone ?? false,
      recurrenceType: _recurrenceType,
      interval: _interval,
      weekDays: _weekDays,
      startDate: _startDate,
      endCondition: _endCondition,
      endDate: _endDate,
      maxOccurrences: _maxOccurrences,
      currentOccurrence: widget.todo?.currentOccurrence ?? 0,
      completedAt: widget.todo?.completedAt,
    );
    widget.onSave(todo);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.todo == null ? "New Task" : "Edit Task",
          style: TextStyle(color: textColor),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: TextStyle(fontSize: 20, color: textColor),
                      decoration: InputDecoration(
                        labelText: "Task Title",
                        labelStyle: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    Text(
                      "Recurrence",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    DropdownButton<RecurrenceType>(
                      value: _recurrenceType,
                      dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                      style: TextStyle(color: textColor),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: RecurrenceType.none,
                          child: Text('No Repeat'),
                        ),
                        DropdownMenuItem(
                          value: RecurrenceType.daily,
                          child: Text('Daily'),
                        ),
                        DropdownMenuItem(
                          value: RecurrenceType.weekly,
                          child: Text('Weekly'),
                        ),
                        DropdownMenuItem(
                          value: RecurrenceType.monthly,
                          child: Text('Monthly'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _recurrenceType = val);
                      },
                    ),

                    if (_recurrenceType != RecurrenceType.none) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text("Every ", style: TextStyle(color: textColor)),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textColor),
                              controller: TextEditingController(
                                text: _interval.toString(),
                              ),
                              onChanged: (v) =>
                                  _interval = int.tryParse(v) ?? 1,
                              decoration: const InputDecoration(isDense: true),
                            ),
                          ),
                          Text(
                            _getIntervalLabel(_recurrenceType),
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),

                      if (_recurrenceType == RecurrenceType.weekly) ...[
                        const SizedBox(height: 10),
                        Text(
                          "Days of Week:",
                          style: TextStyle(color: textColor),
                        ),
                        Wrap(
                          spacing: 5,
                          children: [
                            for (var i = 1; i <= 7; i++)
                              FilterChip(
                                label: Text(_weekdayName(i)),
                                selected: _weekDays.contains(i),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _weekDays.add(i);
                                    } else {
                                      _weekDays.remove(i);
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),
                      Text(
                        "End Condition",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      DropdownButton<EndCondition>(
                        value: _endCondition,
                        dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                        style: TextStyle(color: textColor),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: EndCondition.never,
                            child: Text('Never End'),
                          ),
                          DropdownMenuItem(
                            value: EndCondition.date,
                            child: Text('End by Date'),
                          ),
                          DropdownMenuItem(
                            value: EndCondition.count,
                            child: Text('End after X times'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _endCondition = val);
                        },
                      ),

                      if (_endCondition == EndCondition.date)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _endDate == null
                                ? "Select Date"
                                : _endDate.toString().split(' ')[0],
                            style: TextStyle(color: textColor),
                          ),
                          trailing: Icon(
                            Icons.calendar_today,
                            color: textColor,
                          ),
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (d != null) setState(() => _endDate = d);
                          },
                        ),

                      if (_endCondition == EndCondition.count)
                        Row(
                          children: [
                            Text(
                              "End after ",
                              style: TextStyle(color: textColor),
                            ),
                            SizedBox(
                              width: 50,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: textColor),
                                controller: TextEditingController(
                                  text: _maxOccurrences.toString(),
                                ),
                                onChanged: (v) =>
                                    _maxOccurrences = int.tryParse(v) ?? 1,
                                decoration: const InputDecoration(
                                  isDense: true,
                                ),
                              ),
                            ),
                            Text(
                              " occurrences",
                              style: TextStyle(color: textColor),
                            ),
                          ],
                        ),
                    ],

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: _save,
                        child: const Text(
                          "Save Task",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIntervalLabel(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return "day(s)";
      case RecurrenceType.weekly:
        return "week(s)";
      case RecurrenceType.monthly:
        return "month(s)";
      default:
        return "";
    }
  }

  String _weekdayName(int i) {
    const days = ["M", "T", "W", "T", "F", "S", "S"];
    return days[i - 1];
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1F1C2C), const Color(0xFF928DAB)] // Dark
              : [
                  const Color(0xFF8EC5FC),
                  const Color(0xFFE0C3FC),
                  const Color(0xFF80D0C7),
                ], // Light
        ),
      ),
    );
  }
}
