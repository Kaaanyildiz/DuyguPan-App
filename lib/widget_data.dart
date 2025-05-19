import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

/// Widget'a gönderilecek haftalık rapor ve rozet özetini yöneten servis.
class WidgetDataService {
  /// Haftalık rapor özetini ana ekran widget'ına gönderir.
  static Future<void> updateWeeklyReportWidget({
    required String moodSummary,
    required List<String> badges,
  }) async {
    await HomeWidget.saveWidgetData<String>('mood_summary', moodSummary);
    await HomeWidget.saveWidgetData<String>('badges', badges.join(', '));
    await HomeWidget.updateWidget(
      name: 'MoodWidgetProvider',
      iOSName: 'MoodWidget',
    );
  }

  /// Widget'tan veri okuma (isteğe bağlı, örnek)
  static Future<String?> getMoodSummary() async {
    return await HomeWidget.getWidgetData<String>('mood_summary');
  }
}
