import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitTracker extends StatelessWidget {
  final List<String> habits;
  final Map<String, bool> dailyStatus;
  final void Function(String habit, bool value) onHabitToggle;
  const HabitTracker({super.key, required this.habits, required this.dailyStatus, required this.onHabitToggle});

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
            colors: [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alışkanlık Takibi', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
              const SizedBox(height: 16),
              ...habits.map((habit) => Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: CheckboxListTile(
                  title: Text(habit, style: GoogleFonts.poppins(fontSize: 16)),
                  value: dailyStatus[habit] ?? false,
                  activeColor: Colors.green,
                  secondary: Icon(Icons.check_circle, color: (dailyStatus[habit] ?? false) ? Colors.green : Colors.grey.shade400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onChanged: (val) {
                    onHabitToggle(habit, val ?? false);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// modern kart ve gradient arka plan, animasyonlu mood seçimi, renkli ikonlar, Google Fonts ile tipografi, modern buton ve kart stili...
