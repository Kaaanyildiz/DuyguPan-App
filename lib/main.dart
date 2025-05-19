import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'onboarding.dart';
import 'theme_provider.dart';
import 'badge_service.dart';
import 'home_screen.dart';
import 'notification_service.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BadgeService()..loadBadges()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DuyguPan',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: themeProvider.seedColor, brightness: Brightness.light),
          fontFamily: themeProvider.fontFamily,
          textTheme: Theme.of(context).textTheme,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: themeProvider.seedColor, brightness: Brightness.dark),
          fontFamily: themeProvider.fontFamily,
          textTheme: Theme.of(context).textTheme,
        ),
        themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
        home: _showOnboarding ? OnboardingScreen(onFinish: _finishOnboarding) : const DuyguPanHome(),
      ),
    );
  }
}
