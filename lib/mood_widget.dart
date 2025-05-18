import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodWidgetConfig {
  static const String moodKey = 'mood';
  static const String noteKey = 'mood_note';
  static const String avgMoodKey = 'avg_mood';
  static const String motivationKey = 'motivation';
}

Future<void> updateMoodWidget(int mood, String? note, {double? avgMood, String? motivation}) async {
  final prefs = await SharedPreferences.getInstance();
  final showMood = prefs.getBool('widgetShowMood') ?? true;
  final showAvgMood = prefs.getBool('widgetShowAvgMood') ?? true;
  final showMotivation = prefs.getBool('widgetShowMotivation') ?? true;
  if (showMood) {
    await HomeWidget.saveWidgetData(MoodWidgetConfig.moodKey, mood);
    await HomeWidget.saveWidgetData(MoodWidgetConfig.noteKey, note ?? '');
  } else {
    await HomeWidget.saveWidgetData(MoodWidgetConfig.moodKey, '');
    await HomeWidget.saveWidgetData(MoodWidgetConfig.noteKey, '');
  }
  if (showAvgMood && avgMood != null) {
    await HomeWidget.saveWidgetData(MoodWidgetConfig.avgMoodKey, avgMood);
  } else {
    await HomeWidget.saveWidgetData(MoodWidgetConfig.avgMoodKey, '');
  }
  if (showMotivation && motivation != null) {
    await HomeWidget.saveWidgetData(MoodWidgetConfig.motivationKey, motivation);
  } else {
    await HomeWidget.saveWidgetData(MoodWidgetConfig.motivationKey, '');
  }
  await HomeWidget.updateWidget(name: 'MoodWidgetProvider', iOSName: 'MoodWidget');
}

class MoodWidgetPreview extends StatelessWidget {
  final int mood;
  final String? note;
  const MoodWidgetPreview({super.key, required this.mood, this.note});

  @override
  Widget build(BuildContext context) {
    final List<IconData> moodIcons = [
      Icons.sentiment_very_dissatisfied,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied,
    ];
    final List<Color> moodColors = [
      Colors.redAccent,
      Colors.orange,
      Colors.amber,
      Colors.lightGreen,
      Colors.green,
    ];
    return Container(
      width: 180,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.1), blurRadius: 12)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(moodIcons[mood], color: moodColors[mood], size: 48),
          const SizedBox(height: 8),
          Text(note ?? '', style: GoogleFonts.poppins(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
