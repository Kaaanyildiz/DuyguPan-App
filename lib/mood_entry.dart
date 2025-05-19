import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:home_widget/home_widget.dart';
import 'package:lottie/lottie.dart';
import 'badge_service.dart';
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
  bool _micShake = false;
  bool _showCelebration = false; // Kutlama animasyonu için

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

  void _showBadgeCelebration() async {
    setState(() => _showCelebration = true);
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _showCelebration = false);
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
    return Stack(
      children: [
        Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.10),
                  Theme.of(context).colorScheme.surface.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bubble_chart_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                      const SizedBox(width: 8),
                      Text('Bugünün Modu', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(moodIcons.length, (index) {
                      return AnimatedScale(
                        scale: selectedMood == index ? 1.25 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMood = index;
                            });
                            HapticFeedback.selectionClick();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: selectedMood == index ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Colors.transparent,
                              shape: BoxShape.circle,
                              boxShadow: selectedMood == index
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Icon(moodIcons[index], size: 36, color: selectedMood == index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: noteController,
                          maxLength: 100,
                          style: GoogleFonts.poppins(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Bugün kendini nasıl hissediyorsun?',
                            hintStyle: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: _isListening ? 52 : (_micShake ? 44 : 0),
                            height: _isListening ? 52 : (_micShake ? 44 : 0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isListening
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.18)
                                  : (_micShake ? Colors.red.withOpacity(0.18) : Colors.transparent),
                              boxShadow: _isListening
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                                        blurRadius: 18,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : (_micShake
                                      ? [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.25),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : []),
                            ),
                          ),
                          IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(_isListening ? Icons.mic : Icons.mic_none, key: ValueKey(_isListening), color: _isListening ? Theme.of(context).colorScheme.primary : (_micShake ? Colors.red : Theme.of(context).colorScheme.primary)),
                            ),
                            onPressed: _listen,
                            tooltip: _isListening ? 'Dinleniyor...' : 'Sesli Not',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                      ),
                      onPressed: selectedMood != null
                          ? () async {
                              widget.onMoodSelected(selectedMood!, noteController.text);
                              await _updateMoodWidget(selectedMood!, noteController.text);
                              // Rozet kutlaması tetikleme (örnek: ilk mood kaydı için)
                              final badgeService = Provider.of<BadgeService>(context, listen: false);
                              final isNew = await badgeService.earnBadge('first_mood', context: context);
                              if (isNew) {
                                _showBadgeCelebration();
                              }
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Kaydet', style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showCelebration)
          Center(
            child: AnimatedScale(
              scale: _showCelebration ? 1 : 0.8,
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/lottie/confetti.json', repeat: false, width: 120, height: 120),
                    const SizedBox(height: 12),
                    Text('Tebrikler! Yeni bir rozet kazandın 🎉',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
