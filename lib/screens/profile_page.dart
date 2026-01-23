import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../widgets/glass_container.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  UserProfile? _user;
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userService.loadUser();
    setState(() {
      _user = user;
      if (user == null) {
        // If no user, prompt editing immediately
        _isEditing = true;
      } else {
        _nameController.text = user.name;
        _ageController.text = user.age.toString();
      }
    });
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
    if (_user != null) {
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: GlassContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.cyanAccent,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isEditing) _buildEditForm() else _buildDisplay(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay() {
    if (_user == null) return const SizedBox();
    return Column(
      children: [
        Text(
          _user!.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Age: ${_user!.age}",
          style: const TextStyle(fontSize: 18, color: Colors.white70),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          child: const Text("Edit Profile"),
        ),
        const SizedBox(height: 10),
        Text(
          "Last Updated: ${_user!.lastUpdated.toString().split(' ')[0]}",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Name",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _ageController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Age",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
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
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: _saveProfile,
              child: const Text("Save"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC), Color(0xFF80D0C7)],
        ),
      ),
    );
  }
}
