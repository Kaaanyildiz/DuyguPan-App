import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'db_service.dart';

class WeeklyReport extends StatefulWidget {
  const WeeklyReport({super.key});

  @override
  State<WeeklyReport> createState() => _WeeklyReportState();
}

class _WeeklyReportState extends State<WeeklyReport> {
  List<Map<String, dynamic>> moods = [];
  List<Map<String, dynamic>> habits = [];
  List<Map<String, dynamic>> journals = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> allMoods = [];
    final List<Map<String, dynamic>> allHabits = [];
    final List<Map<String, dynamic>> allJournals = [];
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final date = day.toIso8601String().substring(0, 10);
      final moodsOfDay = await DBService.getMoodsByDate(date);
      final habitsOfDay = await DBService.getHabitsByDate(date);
      final journalsOfDay = await DBService.getJournalsByDate(date);
      if (moodsOfDay.isNotEmpty) allMoods.add({'date': date, ...moodsOfDay.last});
      if (habitsOfDay.isNotEmpty) allHabits.add({'date': date, 'habits': habitsOfDay});
      if (journalsOfDay.isNotEmpty) allJournals.add({'date': date, ...journalsOfDay.last});
    }
    setState(() {
      moods = allMoods.reversed.toList();
      habits = allHabits.reversed.toList();
      journals = allJournals.reversed.toList();
      loading = false;
    });
  }

  String _generateWeeklyInsight() {
    if (moods.isEmpty) return 'Bu hafta için yeterli veri yok.';
    int sum = 0;
    int minMood = 4, maxMood = 0, minDay = 0, maxDay = 0;
    for (int i = 0; i < moods.length; i++) {
      int m = moods[i]['mood'] ?? 2;
      sum += m;
      if (m < minMood) {
        minMood = m;
        minDay = i;
      }
      if (m > maxMood) {
        maxMood = m;
        maxDay = i;
      }
    }
    double avg = sum / moods.length;
    String avgText = avg >= 3 ? 'genellikle iyiydi' : avg >= 2 ? 'orta seviyedeydi' : 'düşüktü';
    String minDate = moods[minDay]['date'].substring(5);
    String maxDate = moods[maxDay]['date'].substring(5);
    return 'Bu hafta ruh halin $avgText. En düşük modun $minDate, en yüksek modun ise $maxDate tarihinde kaydedildi.';
  }

  String _habitSuccessText() {
    if (habits.isEmpty) return 'Bu hafta için yeterli veri yok.';
    int total = 0, done = 0;
    for (var h in habits) {
      final habitList = h['habits'] as List<dynamic>;
      for (var item in habitList) {
        total++;
        if ((item['isDone'] ?? 0) == 1) done++;
      }
    }
    if (total == 0) return 'Bu hafta için yeterli veri yok.';
    int percent = (done / total * 100).round();
    String badge = percent >= 90
        ? 'Alışkanlık Ustası Rozeti 🏅'
        : percent >= 70
            ? 'İstikrarlı Takipçi Rozeti 🥈'
            : percent >= 40
                ? 'Başlangıç Rozeti 🥉'
                : 'Daha fazla istikrar için devam et!';
    return 'Haftalık alışkanlık başarı oranı: %$percent\n$badge';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Haftalık Rapor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_generateWeeklyInsight(), style: const TextStyle(fontSize: 16))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Ruh Hali Trend Grafiği', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: moods.isEmpty
                ? const Center(child: Text('Veri yok'))
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 4,
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, meta) {
                            const moodLabels = ['Kötü', 'Düşük', 'Nötr', 'İyi', 'Harika'];
                            return Text(moodLabels[v.toInt()].toString(), style: const TextStyle(fontSize: 10));
                          }),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                            if (v.toInt() < moods.length) {
                              final date = moods[v.toInt()]['date'];
                              return Text(date.substring(5), style: const TextStyle(fontSize: 10));
                            }
                            return const SizedBox.shrink();
                          }),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (int i = 0; i < moods.length; i++)
                              FlSpot(i.toDouble(), (moods[i]['mood'] ?? 2).toDouble()),
                          ],
                          isCurved: true,
                          color: Colors.deepPurple,
                          barWidth: 4,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: Colors.deepPurple.withOpacity(0.2)),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          const Text('Alışkanlık Sürekliliği', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...habits.map((h) {
            final date = h['date'];
            final habitList = h['habits'] as List<dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                ...habitList.map((item) => Row(
                  children: [
                    Checkbox(value: (item['isDone'] ?? 0) == 1, onChanged: null),
                    Text(item['name'] ?? ''),
                  ],
                )),
                const SizedBox(height: 8),
              ],
            );
          }),
          const SizedBox(height: 24),
          const Text('Haftalık Mikro Günlükler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (journals.isEmpty)
            const Text('Bu hafta için mikro günlük bulunamadı.')
          else
            ...journals.map((j) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.sticky_note_2_outlined),
                    title: Text(j['note'] ?? ''),
                    subtitle: Text(j['date']),
                  ),
                )),
          const SizedBox(height: 24),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_habitSuccessText(), style: const TextStyle(fontSize: 16))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
