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
import 'package:google_fonts/google_fonts.dart';
import 'widget_data.dart';

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
    final badgeService = Provider.of<BadgeService>(context, listen: false);
    // Rozet: İlk mood kaydı
    await badgeService.earnBadge('first_mood', context: context);
    // Rozet: 3 gün üst üste mood
    final moodsRange = await DBService.getMoodsByDateRange(
      DateTime.now().subtract(const Duration(days: 2)).toIso8601String().substring(0, 10),
      today,
    );
    if (moodsRange.length >= 3) {
      await badgeService.earnBadge('streak_3', context: context);
    }
    // Rozet: 30 gün mood kaydı (mood_master)
    final moods30 = await DBService.getMoodsByDateRange(
      DateTime.now().subtract(const Duration(days: 29)).toIso8601String().substring(0, 10),
      today,
    );
    if (moods30.length >= 30) {
      await badgeService.earnBadge('mood_master', context: context);
    }
  }

  void _onHabitToggle(String habit, bool value) async {
    await DBService.insertOrUpdateHabit(habit, value, today);
    setState(() {
      habits[habit] = value;
    });
    final badgeService = Provider.of<BadgeService>(context, listen: false);
    final completed = habits.values.where((v) => v).length;
    if (completed >= 5) {
      await badgeService.earnBadge('habit_5', context: context);
    }
    // 14 gün üst üste alışkanlık (habit_streak_14)
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 14; i++) {
      final date = now.subtract(Duration(days: i)).toIso8601String().substring(0, 10);
      final dayHabits = await DBService.getHabitsByDate(date);
      if (dayHabits.isNotEmpty && (dayHabits.every((h) => h['isDone'] == true))) {
        streak++;
      } else {
        break;
      }
    }
    if (streak >= 14) {
      await badgeService.earnBadge('habit_streak_14', context: context);
    }
  }

  void _onMicroNoteSave(String note) async {
    await DBService.insertJournal(note, today);
    setState(() {
      microNote = note;
    });
    final badgeService = Provider.of<BadgeService>(context, listen: false);
    final journals = await DBService.getJournalsByDateRange(
      DateTime.now().subtract(const Duration(days: 6)).toIso8601String().substring(0, 10),
      today,
    );
    if (journals.length >= 7) {
      await badgeService.earnBadge('journal_7', context: context);
    }
  }

  void _updateWidgetFromHome() async {
    final badgeService = Provider.of<BadgeService>(context, listen: false);
    final badges = badgeService.earnedBadges.map((b) => b.title).toList();
    String moodSummary = '';
    if (mood != null) {
      moodSummary = 'Bugünkü modun: $mood';
      if (moodNote != null && moodNote!.isNotEmpty) {
        moodSummary += '\nNot: $moodNote';
      }
    } else {
      moodSummary = 'Bugün için mood kaydı yok.';
    }
    await WidgetDataService.updateWeeklyReportWidget(
      moodSummary: moodSummary,
      badges: badges,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ana ekran widget’ı güncellendi!')),
      );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('DuyguPan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.10),
              Theme.of(context).colorScheme.secondary.withOpacity(0.08),
              Theme.of(context).colorScheme.surface.withOpacity(0.92),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: MoodEntry(onMoodSelected: _onMoodSelected, key: ValueKey(mood)),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: HabitTracker(
                      habits: habits.keys.toList(),
                      dailyStatus: habits,
                      onHabitToggle: _onHabitToggle,
                      key: ValueKey(habits.toString()),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: MicroJournal(onSave: _onMicroNoteSave, key: ValueKey(microNote)),
                  ),
                  const SizedBox(height: 8),
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
                                Icon(Icons.emoji_events, color: Theme.of(context).colorScheme.primary, size: 22),
                                const SizedBox(width: 8),
                                Text('Motivasyon & Rozetler', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            BadgeWidget(), // Modern rozet widget'ı
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.bar_chart, color: Theme.of(context).colorScheme.onPrimary),
                        label: Text(
                          'Haftalık Raporu Gör',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const WeeklyReport()),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _updateWidgetFromHome,
        icon: const Icon(Icons.widgets_outlined),
        label: const Text('Widget’ı Güncelle'),
      ),
    );
  }
}

class BadgeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BadgeService>(
      builder: (context, badgeService, _) {
        final badges = badgeService.earnedBadges;
        if (badges.isEmpty) {
          return Text('Henüz rozet kazanmadın.', style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: badges.map((badge) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => badgeService.showBadgeDetailDialog(context, badge),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: badge.color.withOpacity(0.2),
                      child: Icon(badge.icon, color: badge.color, size: 28),
                      radius: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(badge.title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
              ),
            )).toList(),
          ),
        );
      },
    );
  }
}
