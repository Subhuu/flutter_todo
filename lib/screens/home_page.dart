import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../widgets/glass_container.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/user_service.dart';
import 'stats_page.dart';
import 'profile_page.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TodoService _todoService = TodoService();
  final UserService _userService = UserService();
  final TextEditingController _controller = TextEditingController();
  List<Todo> _todos = [];
  String _userName = 'User';
  bool _isLoading = true;
  String _newRepeat = 'none'; // State for new task repeat

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
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _todos.add(
        Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _controller.text.trim(),
          repeat: _newRepeat,
        ),
      );
      _controller.clear();
      _newRepeat = 'none'; // Reset logic
    });
    _saveTodos();
  }

  void _toggleTodo(int index) async {
    setState(() {
      final todo = _todos[index];
      final isNowDone = !todo.isDone;
      todo.isDone = isNowDone;

      if (isNowDone) {
        todo.completedAt = DateTime.now();
      } else {
        todo.completedAt = null;
      }
    });

    // Determine repetition logic (async part outside setState)
    // We need to re-fetch the todo because setState might have updated it,
    // but here we have the reference.
    final todo = _todos[index];
    if (todo.isDone && todo.repeat != 'none') {
      DateTime now;
      try {
        // NTP might fail if offline
        now = await NTP.now();
      } catch (_) {
        now = DateTime.now();
      }

      if (mounted) {
        setState(() {
          final newTodo = Todo(
            id: now.millisecondsSinceEpoch.toString(),
            title: todo.title,
            isDone: false,
            repeat: todo.repeat,
          );
          _todos.insert(0, newTodo);
        });
        await _saveTodos();
      }
    } else {
      await _saveTodos();
    }
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  void _editTodo(int index) {
    final TextEditingController editController = TextEditingController(
      text: _todos[index].title,
    );
    String currentRepeat = _todos[index].repeat;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Needed to update dropdown state inside dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                'Edit Task',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: editController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Edit your task",
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Repeat',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyanAccent),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentRepeat,
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'none', child: Text('Once')),
                          DropdownMenuItem(
                            value: 'daily',
                            child: Text('Daily'),
                          ),
                          DropdownMenuItem(
                            value: 'weekly',
                            child: Text('Weekly'),
                          ),
                          DropdownMenuItem(
                            value: 'monthly',
                            child: Text('Monthly'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              currentRepeat = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (editController.text.trim().isNotEmpty) {
                      setState(() {
                        _todos[index].title = editController.text.trim();
                        _todos[index].repeat = currentRepeat;
                      });
                      _saveTodos();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                ),
              ],
            );
          },
        );
      },
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
    final hintColor = isDark ? Colors.white54 : Colors.black45;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                _buildInputArea(textColor, hintColor, iconColor),
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
                    child: const CircleAvatar(
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
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
          onTap: () => _editTodo(index),
          leading: GestureDetector(
            onTap: () => _toggleTodo(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: todo.isDone ? iconColor : Colors.transparent,
                border: Border.all(color: iconColor, width: 2),
              ),
              child: todo.isDone
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                    )
                  : null,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todo.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  decoration: todo.isDone ? TextDecoration.lineThrough : null,
                  decorationColor: textColor,
                ),
              ),
              if (todo.repeat != 'none')
                Text(
                  "Repeats: ${todo.repeat}",
                  style: TextStyle(color: subColor, fontSize: 12),
                ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: iconColor.withValues(alpha: 0.7),
            ),
            onPressed: () => _deleteTodo(index),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(Color textColor, Color hintColor, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ), // Reduced vertical padding
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Add a new task...",
                      hintStyle: TextStyle(color: hintColor),
                      border: InputBorder.none,
                      isDense: true, // Make it compact
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                  // Small Repeat Selector
                  if (_newRepeat != 'none')
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Repeats: $_newRepeat",
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Repeat Icon Button
            PopupMenuButton<String>(
              icon: Icon(
                Icons.repeat,
                color: _newRepeat == 'none'
                    ? iconColor.withValues(alpha: 0.5)
                    : Colors.cyanAccent,
              ),
              color: Colors.grey[900],
              onSelected: (value) {
                setState(() {
                  _newRepeat = value;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'none',
                  child: Text(
                    'No Repeat',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'daily',
                  child: Text('Daily', style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem<String>(
                  value: 'weekly',
                  child: Text('Weekly', style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem<String>(
                  value: 'monthly',
                  child: Text('Monthly', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            IconButton(
              onPressed: _addTodo,
              icon: Icon(Icons.add_circle, color: iconColor, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
