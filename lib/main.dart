import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mood_entry.dart';
import 'habit_tracker.dart';
import 'micro_journal.dart';
import 'db_service.dart';
import 'onboarding.dart';
import 'theme_provider.dart';
import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'weekly_report.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showOnboarding = true;

  void _finishOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'DuyguPan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      home: _showOnboarding ? OnboardingScreen(onFinish: _finishOnboarding) : const DuyguPanHome(),
    );
  }
}

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
  }

  void _onHabitToggle(String habit, bool value) async {
    await DBService.insertOrUpdateHabit(habit, value, today);
    setState(() {
      habits[habit] = value;
    });
  }

  void _onMicroNoteSave(String note) async {
    await DBService.insertJournal(note, today);
    setState(() {
      microNote = note;
    });
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
    // Habits
    final habitsDb = await DBService.getHabitsByDate(today);
    if (habitsDb.isNotEmpty) {
      setState(() {
        for (var h in habitsDb) {
          habits[h['name']] = (h['isDone'] ?? 0) == 1;
        }
      });
    }
    // Micro journal
    final journals = await DBService.getJournalsByDate(today);
    if (journals.isNotEmpty) {
      setState(() {
        microNote = journals.last['note'] as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
                padding: const EdgeInsets.all(8.0),
                child: Text('Bugünkü mod: $mood\nAçıklama: ${moodNote ?? "-"}'),
              ),
            if (microNote != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Kendime Not: $microNote'),
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
