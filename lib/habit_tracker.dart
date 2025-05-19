import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitTracker extends StatelessWidget {
  final List<String> habits;
  final Map<String, bool> dailyStatus;
  final void Function(String habit, bool value) onHabitToggle;
  const HabitTracker({super.key, required this.habits, required this.dailyStatus, required this.onHabitToggle});

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
              color: Colors.green.shade200.withOpacity(0.13),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.green.shade400.withOpacity(0.10),
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
                  Icon(Icons.track_changes, color: Theme.of(context).colorScheme.primary, size: 26),
                  const SizedBox(width: 8),
                  Text('Alışkanlık Takibi', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                ],
              ),
              const SizedBox(height: 18),
              ...habits.map((habit) => Dismissible(
                key: ValueKey(habit),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.delete, color: Colors.redAccent, size: 28),
                ),
                onDismissed: (_) {
                  // Alışkanlık silme işlemi (isteğe bağlı)
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade100.withOpacity(0.10),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CheckboxListTile(
                    title: Text(habit, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                    value: dailyStatus[habit] ?? false,
                    activeColor: Theme.of(context).colorScheme.primary,
                    secondary: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.check_circle,
                        key: ValueKey(dailyStatus[habit] ?? false),
                        color: (dailyStatus[habit] ?? false) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        size: 28,
                      ),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onChanged: (val) {
                      onHabitToggle(habit, val ?? false);
                      HapticFeedback.lightImpact();
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
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
