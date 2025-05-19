import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MicroJournal extends StatefulWidget {
  final void Function(String note) onSave;
  const MicroJournal({super.key, required this.onSave});
  @override
  State<MicroJournal> createState() => _MicroJournalState();
}

class _MicroJournalState extends State<MicroJournal> {
  late TextEditingController controller;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              controller.text = val.recognizedWords;
              controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
              Theme.of(context).colorScheme.primary.withOpacity(0.07),
              Theme.of(context).colorScheme.secondary.withOpacity(0.08),
              Theme.of(context).colorScheme.surface.withOpacity(0.92),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.shade200.withOpacity(0.13),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.purple.shade400.withOpacity(0.10),
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
                  Icon(Icons.edit_note, color: Theme.of(context).colorScheme.primary, size: 26),
                  const SizedBox(width: 8),
                  Text('Mikro Günlük', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                maxLength: 280,
                minLines: 2,
                maxLines: 5,
                style: GoogleFonts.poppins(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Bugün seni etkileyen bir şey oldu mu? Kısa bir not bırak...',
                  hintStyle: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                      elevation: 3,
                    ),
                    onPressed: _listen,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(_isListening ? Icons.mic : Icons.mic_none, key: ValueKey(_isListening), color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    label: Text(_isListening ? 'Dinleniyor...' : 'Sesli Not', style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 3,
                      ),
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          widget.onSave(controller.text.trim());
                          controller.clear();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mikro günlük kaydedildi!')));
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Kaydet', style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
