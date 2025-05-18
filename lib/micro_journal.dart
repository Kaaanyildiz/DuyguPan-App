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
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kendime Not', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: 'Bugün kendine bir not bırak...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.orange.shade800),
                    onPressed: _listen,
                    tooltip: _isListening ? 'Dinleniyor...' : 'Sesli Not',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    widget.onSave(controller.text);
                    controller.clear();
                  },
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
