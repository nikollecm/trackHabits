import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class HabitStorage {
  static const String _key = 'habits';

  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();

    final String encoded = jsonEncode(habits.map((h) => h.toMap()).toList());

    await prefs.setString(_key, encoded);
  }

  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();

    final String? encoded = prefs.getString(_key);

    if (encoded == null) return [];

    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((item) => Habit.fromMap(item)).toList();
  }
}
