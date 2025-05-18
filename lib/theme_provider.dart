import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  Color _seedColor = Colors.deepPurple;
  Color get seedColor => _seedColor;

  String _fontFamily = 'Poppins';
  String get fontFamily => _fontFamily;

  String _emojiSet = 'default';
  String get emojiSet => _emojiSet;

  ThemeProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('seedColor');
    if (colorValue != null) _seedColor = Color(colorValue);
    _fontFamily = prefs.getString('fontFamily') ?? 'Poppins';
    _isDark = prefs.getBool('isDark') ?? false;
    _emojiSet = prefs.getString('emojiSet') ?? 'default';
    notifyListeners();
  }

  void toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    notifyListeners();
  }

  void setSeedColor(Color color) async {
    _seedColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', color.value);
    notifyListeners();
  }

  void setFontFamily(String font) async {
    _fontFamily = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', font);
    notifyListeners();
  }

  void setEmojiSet(String set) async {
    _emojiSet = set;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emojiSet', set);
    notifyListeners();
  }
}
