import 'package:flutter/material.dart';

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
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                        Icon(page.image, size: 100, color: Colors.deepPurple),
                        const SizedBox(height: 32),
                        Text(page.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(page.description, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
                  onPressed: _next,
                  child: Text(_currentPage == _pages.length - 1 ? 'Başla' : 'İleri'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String title;
  final String description;
  final IconData image;
  const _OnboardData({required this.title, required this.description, required this.image});
}
