import 'package:flutter/material.dart';

class HabitTracker extends StatelessWidget {
  final List<String> habits;
  final Map<String, bool> dailyStatus;
  final void Function(String habit, bool value) onHabitToggle;
  const HabitTracker({super.key, required this.habits, required this.dailyStatus, required this.onHabitToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alışkanlık Takibi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...habits.map((habit) => CheckboxListTile(
              title: Text(habit),
              value: dailyStatus[habit] ?? false,
              onChanged: (val) {
                onHabitToggle(habit, val ?? false);
              },
            )),
          ],
        ),
      ),
    );
  }
}
