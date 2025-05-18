import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final List<Color> colorOptions = [
      Colors.deepPurple, Colors.blue, Colors.green, Colors.orange, Colors.pink
    ];
    final List<String> fontOptions = [
      'Poppins', 'Roboto', 'Montserrat', 'Lato', 'Nunito'
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Tema & Kişiselleştirme', style: GoogleFonts.poppins()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Ana Renk', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: colorOptions.map((color) => GestureDetector(
              onTap: () => themeProvider.setSeedColor(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeProvider.seedColor == color ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    if (themeProvider.seedColor == color)
                      BoxShadow(color: color.withOpacity(0.4), blurRadius: 12)
                  ],
                ),
                child: themeProvider.seedColor == color
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
              ),
            )).toList(),
          ),
          const SizedBox(height: 32),
          Text('Yazı Tipi', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: fontOptions.map((font) => ChoiceChip(
              label: Text(font, style: GoogleFonts.getFont(font)),
              selected: themeProvider.fontFamily == font,
              onSelected: (_) => themeProvider.setFontFamily(font),
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            )).toList(),
          ),
          const SizedBox(height: 32),
          Divider(height: 40),
          Text('Emoji Seti', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          EmojiSetSelector(),
          const SizedBox(height: 32),
          Divider(height: 40),
          Text('Bildirim Ayarları', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          NotificationSettingsSection(),
          const SizedBox(height: 32),
          Divider(height: 40),
          WidgetSettingsSection(),
          const SizedBox(height: 32),
          Divider(height: 40),
        ],
      ),
    );
  }
}

class NotificationSettingsSection extends StatefulWidget {
  @override
  State<NotificationSettingsSection> createState() => _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState extends State<NotificationSettingsSection> {
  TimeOfDay? morningTime;
  TimeOfDay? eveningTime;
  TextEditingController morningMsg = TextEditingController();
  TextEditingController eveningMsg = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      morningTime = _parseTime(prefs.getString('notif_morning_time')) ?? const TimeOfDay(hour: 8, minute: 0);
      eveningTime = _parseTime(prefs.getString('notif_evening_time')) ?? const TimeOfDay(hour: 21, minute: 0);
      morningMsg.text = prefs.getString('notif_morning_msg') ?? 'Bugün nasıl hissediyorsun?';
      eveningMsg.text = prefs.getString('notif_evening_msg') ?? 'Bugün neyi başardın?';
      loading = false;
    });
  }

  TimeOfDay? _parseTime(String? s) {
    if (s == null) return null;
    final parts = s.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}' ;

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_morning_time', _formatTime(morningTime!));
    await prefs.setString('notif_evening_time', _formatTime(eveningTime!));
    await prefs.setString('notif_morning_msg', morningMsg.text);
    await prefs.setString('notif_evening_msg', eveningMsg.text);
    // Bildirimleri güncelle
    await NotificationService.scheduleDailyNotification(
      id: 1,
      title: 'DuyguPan’dan merhaba!',
      body: morningMsg.text,
      hour: morningTime!.hour,
      minute: morningTime!.minute,
    );
    await NotificationService.scheduleDailyNotification(
      id: 2,
      title: 'Akşam Modu',
      body: eveningMsg.text,
      hour: eveningTime!.hour,
      minute: eveningTime!.minute,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bildirim ayarları kaydedildi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Sabah Bildirimi:', style: GoogleFonts.poppins())),
            TextButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(_formatTime(morningTime!), style: GoogleFonts.poppins()),
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: morningTime!);
                if (picked != null) setState(() => morningTime = picked);
              },
            ),
          ],
        ),
        TextField(
          controller: morningMsg,
          decoration: InputDecoration(
            labelText: 'Sabah mesajı',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.wb_sunny_outlined),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Text('Akşam Bildirimi:', style: GoogleFonts.poppins())),
            TextButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(_formatTime(eveningTime!), style: GoogleFonts.poppins()),
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: eveningTime!);
                if (picked != null) setState(() => eveningTime = picked);
              },
            ),
          ],
        ),
        TextField(
          controller: eveningMsg,
          decoration: InputDecoration(
            labelText: 'Akşam mesajı',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.nightlight_outlined),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _savePrefs,
            child: Text('Kaydet', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class EmojiSetSelector extends StatelessWidget {
  final List<String> emojiSets = ['default', 'kawaii', 'minimal', 'classic'];
  final Map<String, List<IconData>> emojiPreviews = {
    'default': [Icons.sentiment_very_dissatisfied, Icons.sentiment_neutral, Icons.sentiment_very_satisfied],
    'kawaii': [Icons.face_2, Icons.face_3, Icons.face_4],
    'minimal': [Icons.circle_outlined, Icons.circle, Icons.check_circle],
    'classic': [Icons.mood_bad, Icons.mood, Icons.tag_faces],
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: emojiSets.map((set) {
          final isSelected = themeProvider.emojiSet == set;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => themeProvider.setEmojiSet(set),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: emojiPreviews[set]!.map((icon) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(icon, size: 24, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
                      )).toList(),
                    ),
                    const SizedBox(height: 6),
                    Text(set[0].toUpperCase() + set.substring(1), style: GoogleFonts.poppins(fontSize: 13, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class WidgetSettingsSection extends StatefulWidget {
  @override
  State<WidgetSettingsSection> createState() => _WidgetSettingsSectionState();
}

class _WidgetSettingsSectionState extends State<WidgetSettingsSection> {
  bool showMood = true;
  bool showAvgMood = true;
  bool showMotivation = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showMood = prefs.getBool('widgetShowMood') ?? true;
      showAvgMood = prefs.getBool('widgetShowAvgMood') ?? true;
      showMotivation = prefs.getBool('widgetShowMotivation') ?? true;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('widgetShowMood', showMood);
    await prefs.setBool('widgetShowAvgMood', showAvgMood);
    await prefs.setBool('widgetShowMotivation', showMotivation);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Widget ayarları kaydedildi.')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Widget Ayarları', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        SwitchListTile(
          value: showMood,
          onChanged: (v) => setState(() => showMood = v),
          title: const Text('Son mood bilgisini göster'),
        ),
        SwitchListTile(
          value: showAvgMood,
          onChanged: (v) => setState(() => showAvgMood = v),
          title: const Text('Haftalık ortalama moodu göster'),
        ),
        SwitchListTile(
          value: showMotivation,
          onChanged: (v) => setState(() => showMotivation = v),
          title: const Text('Motivasyon mesajını göster'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _savePrefs,
            child: const Text('Kaydet'),
          ),
        ),
      ],
    );
  }
}
