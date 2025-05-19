// SettingsScreen'i daha gelişmiş ve kişiselleştirilebilir yapmak için:
// - Kullanıcıya canlı tema önizlemesi, dinamik renk paleti, font büyüklüğü ayarı, koyu/açık/otomatik tema seçimi, animasyonlu geçişler, ve gelişmiş kişiselleştirme seçenekleri ekleniyor.
// - Kullanıcı avatarı, isim ve motivasyon mesajı ekleniyor.
// - Tüm seçimlerde animasyon, ripple ve modern Material 3 kartlar kullanılıyor.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'package:lottie/lottie.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  double fontSize = 16;
  bool darkMode = false;
  bool systemTheme = true;
  String userName = '';
  final TextEditingController nameController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Kullanıcı adı ve tema ayarlarını yükle (isteğe bağlı: SharedPreferences ile)
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final List<Color> colorOptions = [
      Colors.deepPurple, Colors.blue, Colors.green, Colors.orange, Colors.pink, Colors.teal, Colors.redAccent
    ];
    final List<String> fontOptions = [
      'Poppins', 'Roboto', 'Montserrat', 'Lato', 'Nunito', 'Quicksand'
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Tema & Kişiselleştirme', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12), // vertical margin kaldırıldı
            // padding kaldırıldı
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(12), // borderRadius biraz küçültüldü
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              tabs: const [
                Tab(icon: Icon(Icons.person), text: 'Profil'),
                Tab(icon: Icon(Icons.palette), text: 'Tema'),
                Tab(icon: Icon(Icons.font_download), text: 'Yazı Tipi'),
                Tab(icon: Icon(Icons.notifications), text: 'Bildirim'),
                Tab(icon: Icon(Icons.widgets), text: 'Widget/Emoji'),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(systemTheme ? Icons.brightness_auto : (themeProvider.isDark ? Icons.dark_mode : Icons.light_mode)),
            tooltip: systemTheme ? 'Sistem Teması' : (themeProvider.isDark ? 'Koyu Tema' : 'Açık Tema'),
            onPressed: () {
              setState(() {
                if (systemTheme) {
                  systemTheme = false;
                  if (!themeProvider.isDark) themeProvider.toggleTheme();
                } else if (themeProvider.isDark) {
                  themeProvider.toggleTheme();
                  darkMode = false;
                } else {
                  systemTheme = true;
                  if (themeProvider.isDark) themeProvider.toggleTheme();
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.10),
                Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                Theme.of(context).colorScheme.surface.withOpacity(0.92),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: [
              // PROFIL
              ListView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                children: [
                  // Avatar ve isim kartı
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // TODO: Avatar seçimi için dialog aç
                            },
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: themeProvider.seedColor.withOpacity(0.2),
                              child: Icon(Icons.person, color: themeProvider.seedColor, size: 36),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Adınızı girin',
                                    border: InputBorder.none,
                                    hintStyle: GoogleFonts.poppins(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                  ),
                                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                                  onChanged: (v) => setState(() => userName = v),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Kısa biyografiniz (isteğe bağlı)',
                                    border: InputBorder.none,
                                    hintStyle: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                                  ),
                                  style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Günlük motivasyon ve hedef kutusu
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    color: themeProvider.seedColor.withOpacity(0.10),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.emoji_objects, color: themeProvider.seedColor, size: 28),
                              const SizedBox(width: 10),
                              Text('Bugünkü Hedefin', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: themeProvider.seedColor)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Küçük bir hedef belirle... (ör. 10dk yürüyüş)',
                              border: InputBorder.none,
                              hintStyle: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                            ),
                            style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Kendini bir kelimeyle anlat
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    color: themeProvider.seedColor.withOpacity(0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.edit_note, color: themeProvider.seedColor, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Kendini bir kelimeyle anlat',
                                border: InputBorder.none,
                                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                              ),
                              style: GoogleFonts.poppins(fontSize: 13, color: themeProvider.seedColor),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Rozet ve istatistik özeti
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.90),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.emoji_events, color: themeProvider.seedColor, size: 22),
                              const SizedBox(width: 8),
                              Text('Kazanılan Rozetler', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: themeProvider.seedColor)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // TODO: Burada yatay kaydırmalı rozet widgetı göster
                          SizedBox(
                            height: 48,
                            child: Center(child: Text('Rozetler burada görünecek', style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)))),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Günlük giriş', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                                  Text('0', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: themeProvider.seedColor)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('En iyi seri', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                                  Text('0 gün', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: themeProvider.seedColor)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Toplam alışkanlık', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                                  Text('0', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: themeProvider.seedColor)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Kendini ödüllendir butonu
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.seedColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 6,
                      ),
                      onPressed: () {
                        // TODO: Güzel bir animasyonla ödüllendirme
                      },
                      icon: const Icon(Icons.cake, color: Colors.white),
                      label: Text('Kendini Ödüllendir', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              // TEMA
              ListView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                children: [
                  _SectionCard(
                    title: 'Ana Renk',
                    icon: Icons.palette,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: colorOptions.map((color) => GestureDetector(
                        onTap: () => themeProvider.setSeedColor(color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: themeProvider.seedColor == color ? 54 : 44,
                          height: themeProvider.seedColor == color ? 54 : 44,
                          decoration: BoxDecoration(
                            gradient: themeProvider.seedColor == color
                              ? LinearGradient(colors: [color.withOpacity(0.8), color.withOpacity(0.5)])
                              : null,
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: themeProvider.seedColor == color ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              if (themeProvider.seedColor == color)
                                BoxShadow(color: color.withOpacity(0.4), blurRadius: 18, spreadRadius: 2)
                            ],
                          ),
                          child: themeProvider.seedColor == color
                            ? Lottie.asset('assets/lottie/confetti.json', width: 40, height: 40, repeat: false)
                            : null,
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Canlı Tema Önizlemesi',
                    icon: Icons.visibility,
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [themeProvider.seedColor.withOpacity(0.7), themeProvider.seedColor.withOpacity(0.3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Text('Bu alanda seçtiğiniz renklerle uygulama teması canlı önizlenir.',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Rastgele Tema',
                    icon: Icons.auto_awesome,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeProvider.seedColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          final random = (colorOptions.toList()..shuffle()).first;
                          themeProvider.setSeedColor(random);
                        },
                        icon: const Icon(Icons.shuffle, color: Colors.white),
                        label: Text('Rastgele Tema', style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
              // YAZI TIPI
              ListView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                children: [
                  _SectionCard(
                    title: 'Yazı Tipi',
                    icon: Icons.font_download,
                    child: Wrap(
                      spacing: 12,
                      children: fontOptions.map((font) => ChoiceChip(
                        label: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: GoogleFonts.getFont(font).copyWith(
                            fontSize: themeProvider.fontFamily == font ? 18 : 15,
                            color: themeProvider.fontFamily == font ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                            fontWeight: themeProvider.fontFamily == font ? FontWeight.bold : FontWeight.normal,
                          ),
                          child: Text(font),
                        ),
                        selected: themeProvider.fontFamily == font,
                        onSelected: (_) => themeProvider.setFontFamily(font),
                        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        elevation: themeProvider.fontFamily == font ? 6 : 0,
                        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionCard(
                    title: 'Yazı Boyutu',
                    icon: Icons.format_size,
                    child: Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: fontSize,
                            min: 12,
                            max: 24,
                            divisions: 6,
                            label: fontSize.round().toString(),
                            onChanged: (v) => setState(() => fontSize = v),
                          ),
                        ),
                        Text('${fontSize.round()} pt', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Okunabilirlik Testi',
                    icon: Icons.read_more,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'DuyguPan ile hayatını kolaylaştır!\n\nBu metin, seçtiğin yazı tipi ve boyutuyla örnek olarak gösterilir. Okunabilirlik senin için yeterli mi?',
                        style: GoogleFonts.getFont(themeProvider.fontFamily, fontSize: fontSize, color: Theme.of(context).colorScheme.onSurface),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              // BILDIRIM
              ListView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                children: [
                  _SectionCard(
                    title: 'Bildirim Ayarları',
                    icon: Icons.notifications,
                    child: NotificationSettingsSection(),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Kendi Motivasyonunu Yaz',
                    icon: Icons.mood,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Her gün sana özel bir motivasyon cümlesi...',
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                      ),
                      style: GoogleFonts.poppins(fontSize: 14, color: themeProvider.seedColor),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Hatırlatıcılar',
                    icon: Icons.alarm,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.alarm, color: themeProvider.seedColor),
                          title: Text('Akşam günlüğü', style: GoogleFonts.poppins()),
                          subtitle: Text('Her akşam saat 21:00', style: GoogleFonts.poppins(fontSize: 12)),
                          trailing: Switch(value: true, onChanged: (_) {}),
                        ),
                        ListTile(
                          leading: Icon(Icons.alarm, color: themeProvider.seedColor),
                          title: Text('Sabah motivasyonu', style: GoogleFonts.poppins()),
                          subtitle: Text('Her sabah saat 08:00', style: GoogleFonts.poppins(fontSize: 12)),
                          trailing: Switch(value: true, onChanged: (_) {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // WIDGET/EMOJI
              ListView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                children: [
                  _SectionCard(
                    title: 'Widget Önizlemesi',
                    icon: Icons.widgets,
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: themeProvider.seedColor.withOpacity(0.10),
                      ),
                      child: Text('Ana ekrana ekleyeceğin widget burada önizlenir.',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: themeProvider.seedColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Emoji Seti',
                    icon: Icons.emoji_emotions,
                    child: EmojiSetSelector(),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'En Çok Kullandığın Emoji',
                    icon: Icons.bar_chart,
                    child: Row(
                      children: [
                        Icon(Icons.emoji_emotions, color: themeProvider.seedColor, size: 28),
                        const SizedBox(width: 10),
                        Text('😊', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'En çok kullandığın emoji burada gösterilecek.',
                            style: GoogleFonts.poppins(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
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

class _ThemePreviewBox extends StatelessWidget {
  final ThemeProvider themeProvider;
  final double fontSize;
  final String userName;
  const _ThemePreviewBox({required this.themeProvider, required this.fontSize, required this.userName, super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      color: themeProvider.seedColor.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.palette, color: themeProvider.seedColor, size: 38),
                const SizedBox(width: 18),
                Text('Önizleme', style: GoogleFonts.getFont(themeProvider.fontFamily, fontSize: 22, fontWeight: FontWeight.bold, color: themeProvider.seedColor)),
                const SizedBox(width: 18),
                Icon(Icons.emoji_emotions, color: themeProvider.seedColor, size: 38),
              ],
            ),
            const SizedBox(height: 12),
            Text(userName.isNotEmpty ? 'Merhaba, $userName!' : 'Kişiselleştirilmiş temanız burada önizlenir.',
              style: GoogleFonts.getFont(themeProvider.fontFamily, fontSize: fontSize, color: themeProvider.seedColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


// Modern ve şık kartlar için Material 3, glassmorphism, gradient, yumuşak gölgeler ve animasyonlu hover/tap efektleri uygulanıyor.
// Her kartta modern ikon, başlık ve içerik tipografisi, kart arka planında hafif blur ve gradient, seçili öğelerde canlı renk geçişleri ve ripple efektleri.

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  const _SectionCard({required this.title, required this.child, this.icon});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withOpacity(0.10);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        highlightColor: Colors.transparent,
        onTap: () {}, // Sadece ripple için
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [color, Theme.of(context).colorScheme.surface.withOpacity(0.92)],
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
              color: Colors.transparent,
              width: 1.5,
            ),
            // Glassmorphism efekti için blur (arka planı bulanıklaştırmak için)
            // Not: BackdropFilter ile üst widget'ta kullanılabilir.
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
                      ),
                    if (icon != null) const SizedBox(width: 10),
                    Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17, color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
                const SizedBox(height: 14),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationSettingsSection extends StatefulWidget {
  @override
  State<NotificationSettingsSection> createState() => _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState extends State<NotificationSettingsSection> {
  TimeOfDay? morningTime;
  TimeOfDay? eveningTime;
  TextEditingController morningMsg = TextEditingController();
  TextEditingController eveningMsg = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      morningTime = _parseTime(prefs.getString('notif_morning_time')) ?? const TimeOfDay(hour: 8, minute: 0);
      eveningTime = _parseTime(prefs.getString('notif_evening_time')) ?? const TimeOfDay(hour: 21, minute: 0);
      morningMsg.text = prefs.getString('notif_morning_msg') ?? 'Bugün nasıl hissediyorsun?';
      eveningMsg.text = prefs.getString('notif_evening_msg') ?? 'Bugün neyi başardın?';
      loading = false;
    });
  }

  TimeOfDay? _parseTime(String? s) {
    if (s == null) return null;
    final parts = s.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}' ;

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_morning_time', _formatTime(morningTime!));
    await prefs.setString('notif_evening_time', _formatTime(eveningTime!));
    await prefs.setString('notif_morning_msg', morningMsg.text);
    await prefs.setString('notif_evening_msg', eveningMsg.text);
    // Bildirimleri güncelle
    await NotificationService.scheduleDailyNotification(
      id: 1,
      title: 'DuyguPan’dan merhaba!',
      body: morningMsg.text,
      hour: morningTime!.hour,
      minute: morningTime!.minute,
    );
    await NotificationService.scheduleDailyNotification(
      id: 2,
      title: 'Akşam Modu',
      body: eveningMsg.text,
      hour: eveningTime!.hour,
      minute: eveningTime!.minute,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bildirim ayarları kaydedildi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Sabah Bildirimi:', style: GoogleFonts.poppins())),
            TextButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(_formatTime(morningTime!), style: GoogleFonts.poppins()),
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: morningTime!);
                if (picked != null) setState(() => morningTime = picked);
              },
            ),
          ],
        ),
        TextField(
          controller: morningMsg,
          decoration: InputDecoration(
            labelText: 'Sabah mesajı',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.wb_sunny_outlined),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Text('Akşam Bildirimi:', style: GoogleFonts.poppins())),
            TextButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(_formatTime(eveningTime!), style: GoogleFonts.poppins()),
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: eveningTime!);
                if (picked != null) setState(() => eveningTime = picked);
              },
            ),
          ],
        ),
        TextField(
          controller: eveningMsg,
          decoration: InputDecoration(
            labelText: 'Akşam mesajı',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.nightlight_outlined),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _savePrefs,
            child: Text('Kaydet', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class EmojiSetSelector extends StatelessWidget {
  final List<String> emojiSets = ['default', 'kawaii', 'minimal', 'classic'];
  final Map<String, List<IconData>> emojiPreviews = {
    'default': [Icons.sentiment_very_dissatisfied, Icons.sentiment_neutral, Icons.sentiment_very_satisfied],
    'kawaii': [Icons.face_2, Icons.face_3, Icons.face_4],
    'minimal': [Icons.circle_outlined, Icons.circle, Icons.check_circle],
    'classic': [Icons.mood_bad, Icons.mood, Icons.tag_faces],
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: emojiSets.map((set) {
          final isSelected = themeProvider.emojiSet == set;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => themeProvider.setEmojiSet(set),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: emojiPreviews[set]!.map((icon) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(icon, size: 24, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
                      )).toList(),
                    ),
                    const SizedBox(height: 6),
                    Text(set[0].toUpperCase() + set.substring(1), style: GoogleFonts.poppins(fontSize: 13, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class WidgetSettingsSection extends StatefulWidget {
  @override
  State<WidgetSettingsSection> createState() => _WidgetSettingsSectionState();
}

class _WidgetSettingsSectionState extends State<WidgetSettingsSection> {
  bool showMood = true;
  bool showAvgMood = true;
  bool showMotivation = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showMood = prefs.getBool('widgetShowMood') ?? true;
      showAvgMood = prefs.getBool('widgetShowAvgMood') ?? true;
      showMotivation = prefs.getBool('widgetShowMotivation') ?? true;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('widgetShowMood', showMood);
    await prefs.setBool('widgetShowAvgMood', showAvgMood);
    await prefs.setBool('widgetShowMotivation', showMotivation);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Widget ayarları kaydedildi.')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Widget Ayarları', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        SwitchListTile(
          value: showMood,
          onChanged: (v) => setState(() => showMood = v),
          title: const Text('Son mood bilgisini göster'),
        ),
        SwitchListTile(
          value: showAvgMood,
          onChanged: (v) => setState(() => showAvgMood = v),
          title: const Text('Haftalık ortalama moodu göster'),
        ),
        SwitchListTile(
          value: showMotivation,
          onChanged: (v) => setState(() => showMotivation = v),
          title: const Text('Motivasyon mesajını göster'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _savePrefs,
            child: const Text('Kaydet'),
          ),
        ),
      ],
    );
  }
}
