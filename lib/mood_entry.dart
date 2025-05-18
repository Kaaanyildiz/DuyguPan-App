import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:home_widget/home_widget.dart';
import 'theme_provider.dart';

class MoodEntry extends StatefulWidget {
  final void Function(int mood, String? note) onMoodSelected;
  const MoodEntry({super.key, required this.onMoodSelected});

  @override
  State<MoodEntry> createState() => _MoodEntryState();
}

class _MoodEntryState extends State<MoodEntry> {
  int? selectedMood;
  final TextEditingController noteController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _micShake = false; // State değişkeni ekle

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (selectedMood == null) {
      // Mood seçilmeden sesli not başlatılırsa uyarı ve mikrofon animasyonu kısa titreşim
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bir mood seçmelisiniz.')),
      );
      // Kısa bir animasyon için mikrofonu "titret" (örnek: kısa bir renk değişimi)
      setState(() {
        _micShake = true;
      });
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _micShake = false;
      });
      return;
    }
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'tr_TR', // Türkçe desteği
          onResult: (val) {
            setState(() {
              noteController.text = val.recognizedWords;
              noteController.selection = TextSelection.fromPosition(TextPosition(offset: noteController.text.length));
            });
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mikrofon izni verilmedi veya cihaz desteklemiyor.')),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // Widget güncellemesi için HomeWidget entegrasyonu
  Future<void> _updateMoodWidget(int mood, String? note) async {
    try {
      await HomeWidget.saveWidgetData('mood', mood);
      await HomeWidget.saveWidgetData('note', note ?? '');
      await HomeWidget.updateWidget(name: 'MoodWidgetProvider', iOSName: 'MoodWidget');
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final emojiSet = themeProvider.emojiSet;
    final Map<String, List<IconData>> moodIconsMap = {
      'default': [
        Icons.sentiment_very_dissatisfied,
        Icons.sentiment_dissatisfied,
        Icons.sentiment_neutral,
        Icons.sentiment_satisfied,
        Icons.sentiment_very_satisfied,
      ],
      'kawaii': [
        Icons.face_2,
        Icons.face_3,
        Icons.face_4,
        Icons.face_5,
        Icons.face_6,
      ],
      'minimal': [
        Icons.circle_outlined,
        Icons.circle,
        Icons.check_circle,
        Icons.radio_button_unchecked,
        Icons.radio_button_checked,
      ],
      'classic': [
        Icons.mood_bad,
        Icons.mood,
        Icons.tag_faces,
        Icons.sentiment_satisfied_alt,
        Icons.sentiment_very_satisfied,
      ],
    };
    final moodIcons = moodIconsMap[emojiSet] ?? moodIconsMap['default']!;
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bugünün Modu', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(moodIcons.length, (index) {
                  return IconButton(
                    icon: Icon(moodIcons[index], size: 32, color: selectedMood == index ? Colors.blue : Colors.grey),
                    onPressed: () {
                      setState(() {
                        selectedMood = index;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: noteController,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: 'Bugün kendini nasıl hissediyorsun?',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animasyonlu mikrofon efekti
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: _isListening ? 48 : (_micShake ? 40 : 0),
                        height: _isListening ? 48 : (_micShake ? 40 : 0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening
                              ? Colors.deepPurple.withOpacity(0.2)
                              : (_micShake ? Colors.red.withOpacity(0.2) : Colors.transparent),
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.4),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : (_micShake
                                  ? [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : []),
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.deepPurple : (_micShake ? Colors.red : Colors.deepPurple)),
                        onPressed: _listen,
                        tooltip: _isListening ? 'Dinleniyor...' : 'Sesli Not',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: selectedMood != null
                      ? () async {
                          widget.onMoodSelected(selectedMood!, noteController.text);
                          await _updateMoodWidget(selectedMood!, noteController.text);
                        }
                      : null,
                  child: Text('Kaydet', style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
