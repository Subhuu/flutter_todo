import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserService {
  static const String _userKey = 'user_profile';

  Future<UserProfile?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userString = prefs.getString(_userKey);
    if (userString != null) {
      return UserProfile.fromJson(jsonDecode(userString));
    }
    return null;
  }

  Future<void> saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(user.toJson());
    await prefs.setString(_userKey, encoded);
  }
}
