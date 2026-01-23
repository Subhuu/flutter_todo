import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../services/todo_service.dart';
import '../widgets/glass_container.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final TodoService _todoService = TodoService();

  UserProfile? _user;
  int _totalTasks = 0;
  int _completedTasks = 0;

  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _userService.loadUser();
    final todos = await _todoService.loadTodos();

    if (mounted) {
      setState(() {
        _user = user;
        _totalTasks = todos.length;
        _completedTasks = todos.where((t) => t.isDone).length;

        if (user == null) {
          _isEditing = true;
        } else {
          _nameController.text = user.name;
          _ageController.text = user.age.toString();
        }
      });
    }
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    if (name.isEmpty || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and valid Age required!")),
      );
      return;
    }

    final now = DateTime.now();

    // Check constraint: Can only edit once a month if not first time
    if (_user != null && !_isEditing) {
      // Only enforce strict month rule if we aren't just toggling mode
      // But user logic says "can update profile again in X days"
      // We keep logic simple: Check constraint before allowing Save action? or on Save?
      // Let's stick to existing logic:
      final lastUpdate = _user!.lastUpdated;
      final difference = now.difference(lastUpdate).inDays;
      if (difference < 30) {
        final remaining = 30 - difference;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You can update profile again in $remaining days"),
          ),
        );
        setState(() {
          _isEditing = false;
          _nameController.text = _user!.name;
          _ageController.text = _user!.age.toString();
        });
        return;
      }
    }

    final newUser = UserProfile(name: name, age: age, lastUpdated: now);
    _userService.saveUser(newUser);

    setState(() {
      _user = newUser;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: textColor)),
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
              child: Column(
                children: [
                  Center(
                    child: GlassContainer(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Avatar
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.cyanAccent,
                                width: 3,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.cyanAccent,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (_isEditing)
                            _buildEditForm(textColor)
                          else
                            _buildDisplay(textColor, secondaryTextColor),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_user != null && !_isEditing)
                    GlassContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              "Total Tasks",
                              "$_totalTasks",
                              textColor,
                              secondaryTextColor,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: secondaryTextColor,
                            ),
                            _buildStatItem(
                              "Completed",
                              "$_completedTasks",
                              textColor,
                              secondaryTextColor,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: secondaryTextColor,
                            ),
                            _buildStatItem(
                              "Rate",
                              _totalTasks == 0
                                  ? "0%"
                                  : "${((_completedTasks / _totalTasks) * 100).toInt()}%",
                              textColor,
                              secondaryTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color textColor,
    Color subColor,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: subColor)),
      ],
    );
  }

  Widget _buildDisplay(Color textColor, Color subColor) {
    if (_user == null) return const SizedBox();
    return Column(
      children: [
        Text(
          _user!.name,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Level 1 Member • ${_user!.age} years old",
          style: TextStyle(fontSize: 14, color: subColor),
        ),
        const SizedBox(height: 20),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
          ),
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          icon: const Icon(Icons.edit, size: 18),
          label: const Text("Edit Profile"),
        ),

        const SizedBox(height: 15),
        Text(
          "Member Since: ${_user!.lastUpdated.toString().split(' ')[0]}",
          style: TextStyle(
            color: subColor.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(Color textColor) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: "Name",
            labelStyle: TextStyle(color: textColor.withValues(alpha: 0.7)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: textColor.withValues(alpha: 0.5)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _ageController,
          style: TextStyle(color: textColor),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Age",
            labelStyle: TextStyle(color: textColor.withValues(alpha: 0.7)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: textColor.withValues(alpha: 0.5)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (_user != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _nameController.text = _user!.name;
                    _ageController.text = _user!.age.toString();
                  });
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: textColor.withValues(alpha: 0.7)),
                ),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: _saveProfile,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1F1C2C), const Color(0xFF928DAB)]
              : [
                  const Color(0xFF8EC5FC),
                  const Color(0xFFE0C3FC),
                  const Color(0xFF80D0C7),
                ],
        ),
      ),
    );
  }
}
