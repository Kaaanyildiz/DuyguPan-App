import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'db_service.dart';
import 'package:provider/provider.dart';
import 'badge_service.dart';

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
  final GlobalKey _reportKey = GlobalKey();

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

  String _generateMotivation() {
    if (moods.isEmpty) return 'Yeni bir haftaya başlarken küçük adımlar bile büyük fark yaratır!';
    double avgMood = moods.map((m) => m['mood'] as int).reduce((a, b) => a + b) / moods.length;
    int totalHabits = 0, doneHabits = 0;
    for (var h in habits) {
      final habitList = h['habits'] as List<dynamic>;
      for (var item in habitList) {
        totalHabits++;
        if ((item['isDone'] ?? 0) == 1) doneHabits++;
      }
    }
    double habitRate = totalHabits > 0 ? doneHabits / totalHabits : 0;
    if (avgMood >= 3.5 && habitRate >= 0.7) {
      return 'Harika bir hafta geçirdin! Bu istikrarı sürdür, kendinle gurur duy.';
    } else if (avgMood >= 2.5 && habitRate >= 0.4) {
      return 'Dengeli bir haftaydı. Küçük iyileştirmelerle daha da iyi hissedebilirsin!';
    } else if (avgMood < 2.5 && habitRate < 0.4) {
      return 'Zor bir hafta olabilir. Kendine nazik ol, minik hedeflerle başla!';
    } else {
      return 'Her gün yeni bir başlangıç. Motive ol ve küçük adımlar atmaya devam et!';
    }
  }

  void _showExportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Verileri Dışa Aktar', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.deepPurple),
              title: Text('CSV Olarak Paylaş', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                _exportAsCSV();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
              title: Text('PDF Olarak Paylaş', style: GoogleFonts.poppins()),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsCSV() async {
    try {
      final List<List<String>> csvData = [
        ['Tarih', 'Mod', 'Mod Notu', 'Alışkanlıklar', 'Mikro Günlük'],
        ...List.generate(moods.length, (i) {
          final date = moods[i]['date'] ?? '';
          final mood = moods[i]['mood']?.toString() ?? '';
          final moodNote = moods[i]['note'] ?? '';
          final habitList = habits.firstWhere((h) => h['date'] == date, orElse: () => {'habits': []})['habits'] as List<dynamic>;
          final habitStr = habitList.map((h) => '${h['name']}: ${(h['isDone'] ?? 0) == 1 ? '✓' : '✗'}').join(', ');
          final journal = journals.firstWhere((j) => j['date'] == date, orElse: () => {'note': ''})['note'] ?? '';
          return [date, mood, moodNote, habitStr, journal];
        })
      ];
      final csv = const ListToCsvConverter().convert(csvData);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/duygupan_rapor.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)], text: 'DuyguPan haftalık verilerim (CSV)');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV dışa aktarma başarısız: $e')),
      );
    }
  }

  Future<void> _exportAsPDF() async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('DuyguPan Haftalık Rapor', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: ['Tarih', 'Mod', 'Mod Notu', 'Alışkanlıklar', 'Mikro Günlük'],
                  data: List.generate(moods.length, (i) {
                    final date = moods[i]['date'] ?? '';
                    final mood = moods[i]['mood']?.toString() ?? '';
                    final moodNote = moods[i]['note'] ?? '';
                    final habitList = habits.firstWhere((h) => h['date'] == date, orElse: () => {'habits': []})['habits'] as List<dynamic>;
                    final habitStr = habitList.map((h) => '${h['name']}: ${(h['isDone'] ?? 0) == 1 ? '✓' : '✗'}').join(', ');
                    final journal = journals.firstWhere((j) => j['date'] == date, orElse: () => {'note': ''})['note'] ?? '';
                    return [date, mood, moodNote, habitStr, journal];
                  }),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple100),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
              ],
            );
          },
        ),
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/duygupan_rapor.pdf');
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)], text: 'DuyguPan haftalık verilerim (PDF)');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF dışa aktarma başarısız: $e')),
      );
    }
  }

  Future<void> _shareAsImage() async {
    try {
      RenderRepaintBoundary boundary = _reportKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/duygupan_haftalik_rapor.png');
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'DuyguPan haftalık raporum (Görsel)');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Görsel olarak paylaşma başarısız: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Haftalık Rapor'),
        backgroundColor: Colors.deepPurple.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: 'Görsel Olarak Paylaş',
            onPressed: _shareAsImage,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RepaintBoundary(
                  key: _reportKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI destekli motivasyon kartı
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.deepPurple.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 36),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(_generateMotivation(),
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.deepPurple.shade800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Card(
                        color: Colors.deepPurple.shade50,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_generateWeeklyInsight(), style: GoogleFonts.poppins(fontSize: 16))),
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
                                        return Text(moodLabels[v.toInt()].toString(), style: GoogleFonts.poppins(fontSize: 10));
                                      }),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                                        if (v.toInt() < moods.length) {
                                          final date = moods[v.toInt()]['date'];
                                          return Text(date.substring(5), style: GoogleFonts.poppins(fontSize: 10));
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
                            Text(date, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                            ...habitList.map((item) => Row(
                              children: [
                                Checkbox(value: (item['isDone'] ?? 0) == 1, onChanged: null),
                                Text(item['name'] ?? '', style: GoogleFonts.poppins()),
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
                              color: Colors.orange.shade50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                leading: const Icon(Icons.sticky_note_2_outlined, color: Colors.orange),
                                title: Text(j['note'] ?? '', style: GoogleFonts.poppins()),
                                subtitle: Text(j['date'], style: GoogleFonts.poppins(fontSize: 12)),
                              ),
                            )),
                      const SizedBox(height: 24),
                      Card(
                        color: Colors.green.shade50,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.green),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_habitSuccessText(), style: GoogleFonts.poppins(fontSize: 16))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<BadgeService>(
                        builder: (context, badgeService, _) {
                          final badges = badgeService.earnedBadges;
                          if (badges.isEmpty) return const SizedBox();
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            color: Colors.yellow.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.military_tech, color: Colors.amber.shade700),
                                      const SizedBox(width: 8),
                                      Text('Bu Haftaki Rozetlerim', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: badges.map((badge) => Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: badge.color.withOpacity(0.2),
                                              child: Icon(badge.icon, color: badge.color, size: 28),
                                              radius: 24,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(badge.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      )).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
