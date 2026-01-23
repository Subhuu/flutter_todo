import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../widgets/glass_container.dart';
import '../services/time_service.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/user_service.dart';
import 'stats_page.dart';
import 'profile_page.dart';
import 'task_editor_page.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TodoService _todoService = TodoService();
  final UserService _userService = UserService();
  List<Todo> _todos = [];
  String _userName = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadTodos(), _loadUser()]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUser() async {
    final user = await _userService.loadUser();
    if (user != null && mounted) {
      setState(() {
        _userName = user.name;
      });
    }
  }

  Future<void> _loadTodos() async {
    final todos = await _todoService.loadTodos();
    if (mounted) {
      setState(() {
        _todos = todos;
      });
    }
  }

  Future<void> _saveTodos() async {
    await _todoService.saveTodos(_todos);
  }

  void _addTodo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskEditorPage(
          onSave: (todo) {
            setState(() {
              _todos.add(todo);
            });
            _saveTodos();
          },
        ),
      ),
    );
  }

  void _toggleTodo(int index) async {
    final todo = _todos[index];
    final isNowDone = !todo.isDone;

    setState(() {
      todo.isDone = isNowDone;
      if (isNowDone) {
        todo.completedAt = DateTime.now();
      } else {
        todo.completedAt = null;
      }
    });

    if (isNowDone && todo.recurrenceType != RecurrenceType.none) {
      // Check end condition
      if (todo.endCondition == EndCondition.count && todo.maxOccurrences > 0) {
        todo.currentOccurrence++;
        if (todo.currentOccurrence >= todo.maxOccurrences) {
          await _saveTodos();
          return; // Stop recurring
        }
      }

      DateTime now = await TimeService().now();

      // Calculate next recurrence
      DateTime nextDate = now;
      if (todo.recurrenceType == RecurrenceType.daily) {
        nextDate = now.add(Duration(days: todo.interval));
      } else if (todo.recurrenceType == RecurrenceType.weekly) {
        if (todo.weekDays.isNotEmpty) {
          nextDate = now.add(Duration(days: 7 * todo.interval));
        } else {
          nextDate = now.add(Duration(days: 7 * todo.interval));
        }
      } else if (todo.recurrenceType == RecurrenceType.monthly) {
        nextDate = TimeService().nextMonthlyDate(now, todo.interval);
      }

      if (todo.endCondition == EndCondition.date && todo.endDate != null) {
        if (nextDate.isAfter(todo.endDate!)) {
          await _saveTodos();
          return;
        }
      }

      final newTodo = Todo(
        id: nextDate.millisecondsSinceEpoch.toString(),
        title: todo.title,
        recurrenceType: todo.recurrenceType,
        interval: todo.interval,
        weekDays: todo.weekDays,
        endCondition: todo.endCondition,
        endDate: todo.endDate,
        maxOccurrences: todo.maxOccurrences,
        currentOccurrence: todo.currentOccurrence,
        isDone: false,
      );

      if (mounted) {
        setState(() {
          _todos.insert(0, newTodo);
        });
      }
    }

    await _saveTodos();
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  void _editTodo(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskEditorPage(
          todo: _todos[index],
          onSave: (updatedTodo) {
            setState(() {
              _todos[index] = updatedTodo;
            });
            _saveTodos();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Theme Awareness
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define Styles based on Theme
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black54;
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: _buildFab(),
      body: Stack(
        children: [
          _buildBackgroundAndShapes(isDark),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(textColor, secondaryTextColor, iconColor),
                Expanded(
                  child: _buildTodoList(
                    textColor,
                    secondaryTextColor,
                    iconColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundAndShapes(bool isDark) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1F1C2C),
                      const Color(0xFF928DAB),
                    ] // Dark Gradient
                  : [
                      const Color(0xFF8EC5FC),
                      const Color(0xFFE0C3FC),
                      const Color(0xFF80D0C7),
                    ], // Light Pastel Gradient
            ),
          ),
        ),
        Positioned(
          top: -50,
          left: -50,
          child: _buildBlob(200, Colors.purpleAccent.withValues(alpha: 0.4)),
        ),
        Positioned(
          bottom: 100,
          right: -60,
          child: _buildBlob(250, Colors.blueAccent.withValues(alpha: 0.4)),
        ),
        Positioned(
          top: 200,
          right: 50,
          child: _buildBlob(150, Colors.pinkAccent.withValues(alpha: 0.3)),
        ),
      ],
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color titleColor, Color subtitleColor, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $_userName",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "You have ${_todos.where((t) => !t.isDone).length} tasks to do",
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.bar_chart, color: iconColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StatsPage(todos: _todos),
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfilePage()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(Icons.person, color: iconColor),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Provider.of<ThemeProvider>(context).isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: iconColor,
                  ),
                  onPressed: () {
                    Provider.of<ThemeProvider>(
                      context,
                      listen: false,
                    ).toggleTheme();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList(Color textColor, Color subColor, Color iconColor) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: iconColor));
    }
    if (_todos.isEmpty) {
      return Center(
        child: Text(
          "No tasks yet!",
          style: TextStyle(
            color: subColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return _buildGlassTodoItem(todo, index, textColor, subColor, iconColor);
      },
    );
  }

  Widget _buildGlassTodoItem(
    Todo todo,
    int index,
    Color textColor,
    Color subColor,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: Dismissible(
          key: Key(todo.id),
          background: Container(
            color: Colors.green.withValues(alpha: 0.3),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.check, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red.withValues(alpha: 0.3),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Delete
              _deleteTodo(index);
              return true;
            } else {
              // Mark Done (Toggle)
              _toggleTodo(index);
              return false; // Don't remove from list immediately to let user see change
            }
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            onTap: () => _editTodo(index),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    decoration: todo.isDone ? TextDecoration.lineThrough : null,
                    decorationColor: textColor,
                  ),
                ),
                if (todo.recurrenceType != RecurrenceType.none)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Repeats: ${todo.recurrenceType.name} (Interval: ${todo.interval})",
                      style: TextStyle(color: subColor, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: _addTodo,
      backgroundColor: Colors.cyanAccent,
      child: const Icon(Icons.add, color: Colors.black),
    );
  }
}
