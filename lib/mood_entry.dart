import 'package:flutter/material.dart';

class MoodEntry extends StatefulWidget {
  final void Function(int mood, String? note) onMoodSelected;
  const MoodEntry({super.key, required this.onMoodSelected});

  @override
  State<MoodEntry> createState() => _MoodEntryState();
}

class _MoodEntryState extends State<MoodEntry> {
  int? selectedMood;
  final TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final List<IconData> moodIcons = [
      Icons.sentiment_very_dissatisfied,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied,
    ];
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bugünün Modu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Bunu biraz açıklamak ister misin?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (selectedMood != null) {
                  widget.onMoodSelected(selectedMood!, noteController.text.isEmpty ? null : noteController.text);
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
