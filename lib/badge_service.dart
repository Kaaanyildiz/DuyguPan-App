import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

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
      description: 'İlk mood kaydını yaptın! Harika bir başlangıç, devam et!',
      icon: Icons.emoji_emotions,
      color: Colors.amber,
    ),
    Badge(
      id: 'streak_3',
      title: '3 Günlük Seri',
      description: '3 gün üst üste mood girdin. İstikrarın gücünü gösteriyorsun!',
      icon: Icons.local_fire_department,
      color: Colors.deepOrange,
    ),
    Badge(
      id: 'habit_5',
      title: 'Alışkanlıkçı',
      description: '5 alışkanlık tamamladın. Alışkanlıklarını sürdürmek büyük bir başarı!',
      icon: Icons.check_circle,
      color: Colors.green,
    ),
    Badge(
      id: 'journal_7',
      title: 'Yazar',
      description: '7 gün mikro günlük girdin. Duygularını yazmak farkındalığını artırır, tebrikler!',
      icon: Icons.edit_note,
      color: Colors.blue,
    ),
    Badge(
      id: 'mood_master',
      title: 'Mood Ustası',
      description: '30 gün boyunca mood kaydı yaptın. Harika bir istikrar!',
      icon: Icons.star,
      color: Colors.deepPurple,
    ),
    Badge(
      id: 'habit_streak_14',
      title: 'Alışkanlık Serisi',
      description: '14 gün üst üste alışkanlıklarını tamamladın. Müthiş bir disiplin!',
      icon: Icons.bolt,
      color: Colors.orangeAccent,
    ),
    Badge(
      id: 'ai_insight',
      title: 'AI Farkındalığı',
      description: 'AI önerisiyle bir haftayı tamamladın. Dijital destekle gelişiyorsun!',
      icon: Icons.psychology,
      color: Colors.teal,
    ),
    Badge(
      id: 'community_1',
      title: 'Topluluk Katılımcısı',
      description: 'İlk kez toplulukta paylaşım yaptın. Deneyimlerini paylaşmak güzeldir!',
      icon: Icons.people,
      color: Colors.pinkAccent,
    ),
    Badge(
      id: 'widget_power',
      title: 'Widget Gücü',
      description: 'Ana ekrana widget ekledin. Hızlı erişim için harika bir adım!',
      icon: Icons.widgets,
      color: Colors.indigo,
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

  Future<bool> earnBadge(String badgeId, {BuildContext? context}) async {
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
          builder: (ctx) => Center(
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.98),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: badge.color.withOpacity(0.18),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Lottie.asset('assets/lottie/confetti.json', repeat: false),
                        ),
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 18),
                        Text('Tebrikler!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: badge.color)),
                        const SizedBox(height: 10),
                        Text(badge.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        Text(badge.description, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85)), textAlign: TextAlign.center),
                        const SizedBox(height: 18),
                        Text(_supportMessage(badgeId), style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: badge.color,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Devam Et'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return true;
    }
    return false;
  }

  void showBadgeDetailDialog(BuildContext context, Badge badge) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.98),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: badge.color.withOpacity(0.18),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: badge.color.withOpacity(0.2),
                  child: Icon(badge.icon, color: badge.color, size: 64),
                  radius: 48,
                ),
                const SizedBox(height: 18),
                Text(badge.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: badge.color)),
                const SizedBox(height: 10),
                Text(badge.description, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85)), textAlign: TextAlign.center),
                const SizedBox(height: 18),
                Text(_supportMessage(badge.id), style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: badge.color,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Kapat'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      case 'mood_master':
        return '30 gün boyunca her gün kaydetmeye devam et, mükemmel bir alışkanlık geliştiriyorsun!';
      case 'habit_streak_14':
        return '14 gün boyunca alışkanlıklarını sürdürdün, bu harika bir disiplin göstergesi!';
      case 'ai_insight':
        return 'AI ile desteklenmekte harikasın, dijital asistanınla daha da güçlen!';
      case 'community_1':
        return 'Topluluğuna katıldığın için teşekkürler, deneyimlerini paylaşmaya devam et!';
      case 'widget_power':
        return 'Widget kullanarak uygulamaya hızlı erişim sağladın, bu harika!';
      default:
        return 'Başarını kutluyoruz!';
    }
  }

  bool hasBadge(String badgeId) => _earnedBadgeIds.contains(badgeId);
}
