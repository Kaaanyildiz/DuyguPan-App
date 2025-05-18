import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Badge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class BadgeService with ChangeNotifier {
  static final List<Badge> allBadges = [
    Badge(
      id: 'first_mood',
      title: 'İlk Adım',
      description: 'İlk mood kaydını yaptın!',
      icon: Icons.emoji_emotions,
      color: Colors.amber,
    ),
    Badge(
      id: 'streak_3',
      title: '3 Günlük Seri',
      description: '3 gün üst üste mood girdin.',
      icon: Icons.local_fire_department,
      color: Colors.deepOrange,
    ),
    Badge(
      id: 'habit_5',
      title: 'Alışkanlıkçı',
      description: '5 alışkanlık tamamladın.',
      icon: Icons.check_circle,
      color: Colors.green,
    ),
    Badge(
      id: 'journal_7',
      title: 'Yazar',
      description: '7 gün mikro günlük girdin.',
      icon: Icons.edit_note,
      color: Colors.blue,
    ),
    // Daha fazla rozet eklenebilir
  ];

  List<String> _earnedBadgeIds = [];

  List<Badge> get earnedBadges =>
      allBadges.where((b) => _earnedBadgeIds.contains(b.id)).toList();

  Future<void> loadBadges() async {
    final prefs = await SharedPreferences.getInstance();
    _earnedBadgeIds = prefs.getStringList('earnedBadges') ?? [];
    notifyListeners();
  }

  Future<void> earnBadge(String badgeId, {BuildContext? context}) async {
    if (!_earnedBadgeIds.contains(badgeId)) {
      _earnedBadgeIds.add(badgeId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('earnedBadges', _earnedBadgeIds);
      notifyListeners();
      if (context != null) {
        final badge = allBadges.firstWhere((b) => b.id == badgeId);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) => Transform.scale(
                      scale: scale,
                      child: CircleAvatar(
                        backgroundColor: badge.color.withOpacity(0.2),
                        child: Icon(badge.icon, color: badge.color, size: 64),
                        radius: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Tebrikler!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: badge.color)),
                  const SizedBox(height: 12),
                  Text(badge.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(badge.description, style: const TextStyle(fontSize: 15), textAlign: TextAlign.center),
                  const SizedBox(height: 18),
                  Text(_supportMessage(badgeId), style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: badge.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Devam Et'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  String _supportMessage(String badgeId) {
    switch (badgeId) {
      case 'first_mood':
        return 'Harika bir başlangıç! Her gün kaydetmeye devam et.';
      case 'streak_3':
        return 'İstikrarın gücünü gösteriyorsun, devam et!';
      case 'habit_5':
        return 'Alışkanlıklarını sürdürmek büyük bir başarı!';
      case 'journal_7':
        return 'Duygularını yazmak farkındalığını artırır, tebrikler!';
      default:
        return 'Başarını kutluyoruz!';
    }
  }

  bool hasBadge(String badgeId) => _earnedBadgeIds.contains(badgeId);
}
