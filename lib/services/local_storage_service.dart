import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class LocalStorage {
  LocalStorage._();
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static const String _profileKey = 'user_profile';

  static Future<UserProfile?> loadProfile() async {
    final prefs = await _instance;
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson({
        'dateOfBirth': raw.split('|')[0],
        'lifeExpectancyYears': int.parse(raw.split('|')[1]),
        'isOnboarded': raw.split('|')[2] == 'true',
      });
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await _instance;
    await prefs.setString(
      _profileKey,
      '${profile.dateOfBirth.toIso8601String()}|${profile.lifeExpectancyYears}|${profile.isOnboarded}',
    );
  }

  static Future<void> clearProfile() async {
    final prefs = await _instance;
    await prefs.remove(_profileKey);
  }
}
