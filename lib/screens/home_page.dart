import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../widgets/glass_container.dart';
import 'analytics_page.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TodoService _todoService = TodoService();
  final TextEditingController _controller = TextEditingController();
  List<Todo> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await _todoService.loadTodos();
    if (mounted) {
      setState(() {
        _todos = todos;
        _isLoading = false;
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
        ),
      );
      _controller.clear();
    });
    _saveTodos();
  }

  void _toggleTodo(int index) {
    setState(() {
      final todo = _todos[index];
      final isNowDone = !todo.isDone;
      todo.isDone = isNowDone;

      if (isNowDone) {
        todo.completedAt = DateTime.now();

        // Handle Repetition
        if (todo.repeat != 'none') {
          // Create the next task instance
          final newTodo = Todo(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: todo.title,
            isDone: false,
            repeat: todo.repeat,
          );
          // Add it to the list (after a slight delay or immediately)
          // If we add immediately, it might be confusing if lists are sorted.
          // For now, simpler is better: just add it to the top.
          _todos.insert(0, newTodo);
        }
      } else {
        todo.completedAt = null;
      }
    });
    _saveTodos();
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
                  DropdownButtonFormField<String>(
                    value: currentRepeat,
                    dropdownColor: Colors.grey[800],
                    style: const TextStyle(color: Colors.white),
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
                    items: const [
                      DropdownMenuItem(value: 'none', child: Text('No Repeat')),
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          currentRepeat = value;
                        });
                      }
                    },
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildBackgroundAndShapes(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildTodoList()),
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundAndShapes() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC), Color(0xFF80D0C7)],
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

  Widget _buildHeader() {
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
                const Text(
                  "Hello, User",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "You have ${_todos.where((t) => !t.isDone).length} tasks to do",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.bar_chart, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnalyticsPage(todos: _todos),
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_todos.isEmpty) {
      return Center(
        child: Text(
          "No tasks yet!",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
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
        return _buildGlassTodoItem(todo, index);
      },
    );
  }

  Widget _buildGlassTodoItem(Todo todo, int index) {
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
                color: todo.isDone ? Colors.white : Colors.transparent,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: todo.isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.purple)
                  : null,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todo.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  decoration: todo.isDone ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.white,
                ),
              ),
              if (todo.repeat != 'none')
                Text(
                  "Repeats: ${todo.repeat}",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed: () => _deleteTodo(index),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Add a new task...",
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _addTodo(),
              ),
            ),
            IconButton(
              onPressed: _addTodo,
              icon: const Icon(Icons.add_circle, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
