import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardData> _pages = [
    _OnboardData(
      title: 'Nasıl Çalışır?',
      description: 'DuyguPan ile ruh halini ve alışkanlıklarını sadece 1 dakikada kaydedebilirsin. Minimal ve huzurlu bir deneyim seni bekliyor.',
      image: Icons.emoji_emotions,
    ),
    _OnboardData(
      title: 'Verilerin Güvende',
      description: 'Tüm verilerin sadece senin cihazında, şifreli ve gizli tutulur. Dilersen dışa aktarabilirsin.',
      image: Icons.lock_outline,
    ),
    _OnboardData(
      title: 'Kendin için dakikalar ayır',
      description: 'Her gün ruh halini ve alışkanlıklarını kaydederek kendini daha iyi tanı. AI destekli analizlerle farkındalık kazan.',
      image: Icons.self_improvement,
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB388FF), Color(0xFF8C9EFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, i) {
                    final page = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(32),
                            child: Icon(page.image, size: 80, color: Colors.deepPurple),
                          ),
                          const SizedBox(height: 32),
                          Text(page.title, style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                          const SizedBox(height: 16),
                          Text(page.description, style: GoogleFonts.poppins(fontSize: 16), textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 18 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _currentPage == i ? Colors.deepPurple : Colors.grey[300],
                  ),
                )),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _next,
                    child: Text(_currentPage == _pages.length - 1 ? 'Başla' : 'İleri', style: GoogleFonts.poppins(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardData {
  final String title;
  final String description;
  final IconData image;
  _OnboardData({required this.title, required this.description, required this.image});
}
