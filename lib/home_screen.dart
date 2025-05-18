import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mood_entry.dart';
import 'habit_tracker.dart';
import 'micro_journal.dart';
import 'db_service.dart';
import 'theme_provider.dart';
import 'notification_service.dart';
import 'weekly_report.dart';
import 'settings.dart';
import 'mood_widget.dart';
import 'badge_service.dart';

class DuyguPanHome extends StatefulWidget {
  const DuyguPanHome({super.key});

  @override
  State<DuyguPanHome> createState() => _DuyguPanHomeState();
}

class _DuyguPanHomeState extends State<DuyguPanHome> {
  int? mood;
  String? moodNote;
  Map<String, bool> habits = {
    'Su İç (2L)': false,
    'Kitap Oku (20dk)': false,
    'Yürüyüş (30dk)': false,
  };
  String? microNote;

  String get today => DateTime.now().toIso8601String().substring(0, 10);

  void _onMoodSelected(int m, String? note) async {
    await DBService.insertMood(m, note, today);
    setState(() {
      mood = m;
      moodNote = note;
    });
    // Haftalık ortalama mood ve motivasyon güncellemesi
    final now = DateTime.now();
    List<int> weekMoods = [];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i)).toIso8601String().substring(0, 10);
      final dayMoods = await DBService.getMoodsByDate(date);
      if (dayMoods.isNotEmpty) {
        weekMoods.add(dayMoods.last['mood'] as int);
      }
    }
    double? avgMood;
    if (weekMoods.isNotEmpty) {
      avgMood = weekMoods.reduce((a, b) => a + b) / weekMoods.length;
    }
    String motivation = '';
    if (avgMood != null) {
      if (avgMood >= 3.5) {
        motivation = 'Harika bir hafta! Pozitif kalmaya devam et.';
      } else if (avgMood >= 2.5) {
        motivation = 'Dengeli bir hafta, kendine iyi bakmayı unutma!';
      } else {
        motivation = 'Zor bir hafta olabilir, küçük şeylerle motive ol!';
      }
    }
    await updateMoodWidget(m, note, avgMood: avgMood, motivation: motivation);
    // Rozet: İlk mood kaydı
    final badgeService = Provider.of<BadgeService>(context, listen: false);
    if (!badgeService.hasBadge('first_mood')) {
      await badgeService.earnBadge('first_mood', context: context);
    }
    // Rozet: 3 gün üst üste mood
    final moodsRange = await DBService.getMoodsByDateRange(
      DateTime.now().subtract(const Duration(days: 2)).toIso8601String().substring(0, 10),
      today,
    );
    if (moodsRange.length >= 3 && !badgeService.hasBadge('streak_3')) {
      await badgeService.earnBadge('streak_3', context: context);
    }
  }

  void _onHabitToggle(String habit, bool value) async {
    await DBService.insertOrUpdateHabit(habit, value, today);
    setState(() {
      habits[habit] = value;
    });
    // Rozet: 5 alışkanlık tamamlandı
    final badgeService = Provider.of<BadgeService>(context, listen: false);
    final completed = habits.values.where((v) => v).length;
    if (completed >= 5 && !badgeService.hasBadge('habit_5')) {
      await badgeService.earnBadge('habit_5', context: context);
    }
  }

  void _onMicroNoteSave(String note) async {
    await DBService.insertJournal(note, today);
    setState(() {
      microNote = note;
    });
    // Rozet: 7 gün mikro günlük
    final badgeService = Provider.of<BadgeService>(context, listen: false);
    final journals = await DBService.getJournalsByDateRange(
      DateTime.now().subtract(const Duration(days: 6)).toIso8601String().substring(0, 10),
      today,
    );
    if (journals.length >= 7 && !badgeService.hasBadge('journal_7')) {
      await badgeService.earnBadge('journal_7', context: context);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTodayData();
    _scheduleNotifications();
  }

  void _scheduleNotifications() async {
    await NotificationService.scheduleDailyNotification(
      id: 1,
      title: 'DuyguPan’dan merhaba!',
      body: 'Bugün nasıl hissediyorsun?',
      hour: 8,
      minute: 0,
    );
    await NotificationService.scheduleDailyNotification(
      id: 2,
      title: 'Akşam Modu',
      body: 'Bugün neyi başardın?',
      hour: 21,
      minute: 0,
    );
  }

  Future<void> _loadTodayData() async {
    // Mood
    final moods = await DBService.getMoodsByDate(today);
    if (moods.isNotEmpty) {
      setState(() {
        mood = moods.last['mood'] as int?;
        moodNote = moods.last['note'] as String?;
      });
    }
    // Haftalık ortalama mood ve motivasyon
    final now = DateTime.now();
    List<int> weekMoods = [];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i)).toIso8601String().substring(0, 10);
      final dayMoods = await DBService.getMoodsByDate(date);
      if (dayMoods.isNotEmpty) {
        weekMoods.add(dayMoods.last['mood'] as int);
      }
    }
    double? avgMood;
    if (weekMoods.isNotEmpty) {
      avgMood = weekMoods.reduce((a, b) => a + b) / weekMoods.length;
    }
    String motivation = '';
    if (avgMood != null) {
      if (avgMood >= 3.5) {
        motivation = 'Harika bir hafta! Pozitif kalmaya devam et.';
      } else if (avgMood >= 2.5) {
        motivation = 'Dengeli bir hafta, kendine iyi bakmayı unutma!';
      } else {
        motivation = 'Zor bir hafta olabilir, küçük şeylerle motive ol!';
      }
    }
    // Widget'ı güncelle
    await updateMoodWidget(mood ?? 2, moodNote, avgMood: avgMood, motivation: motivation);
    // Rozet: İlk mood kaydı
    final badgeService = Provider.of<BadgeService>(context, listen: false);
    if (!badgeService.hasBadge('first_mood')) {
      await badgeService.earnBadge('first_mood', context: context);
    }
    // Rozet: 3 gün üst üste mood
    final moodsRange = await DBService.getMoodsByDateRange(
      DateTime.now().subtract(const Duration(days: 2)).toIso8601String().substring(0, 10),
      today,
    );
    if (moodsRange.length >= 3 && !badgeService.hasBadge('streak_3')) {
      await badgeService.earnBadge('streak_3', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DuyguPan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: themeProvider.isDark ? 'Aydınlık Mod' : 'Karanlık Mod',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ayarlar',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MoodEntry(onMoodSelected: _onMoodSelected),
            HabitTracker(
              habits: habits.keys.toList(),
              dailyStatus: habits,
              onHabitToggle: _onHabitToggle,
            ),
            MicroJournal(onSave: _onMicroNoteSave),
            if (mood != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.emoji_emotions, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text('Bugünkü mod: $mood', style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        if (moodNote != null && moodNote!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Açıklama: $moodNote', style: Theme.of(context).textTheme.bodyMedium),
                          ),
                        const SizedBox(height: 12),
                        Center(child: MoodWidgetPreview(mood: mood!, note: moodNote)),
                      ],
                    ),
                  ),
                ),
              ),
            if (microNote != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.sticky_note_2_outlined, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Kendime Not: $microNote', style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Consumer<BadgeService>(
                builder: (context, badgeService, _) {
                  final badges = badgeService.earnedBadges;
                  if (badges.isEmpty) {
                    return const SizedBox();
                  }
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    color: Colors.yellow.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.military_tech, color: Colors.amber.shade700),
                              const SizedBox(width: 8),
                              Text('Rozetlerim', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: badges.map((badge) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => Dialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TweenAnimationBuilder<double>(
                                                tween: Tween(begin: 0.7, end: 1),
                                                duration: const Duration(milliseconds: 600),
                                                curve: Curves.elasticOut,
                                                builder: (context, scale, child) => Transform.scale(
                                                  scale: scale,
                                                  child: CircleAvatar(
                                                    backgroundColor: badge.color.withOpacity(0.2),
                                                    child: Icon(badge.icon, color: badge.color, size: 48),
                                                    radius: 40,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(badge.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 8),
                                              Text(badge.description, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                                              const SizedBox(height: 16),
                                              ElevatedButton(
                                                onPressed: () => Navigator.of(ctx).pop(),
                                                child: const Text('Kapat'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: badge.color,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: badge.color.withOpacity(0.2),
                                        child: Icon(badge.icon, color: badge.color, size: 28),
                                        radius: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(badge.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bar_chart),
                label: const Text('Haftalık Raporu Gör'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WeeklyReport()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
