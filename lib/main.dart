import 'package:flutter/material.dart';

void main() {
  runApp(const AwwabApp());
}

class AwwabApp extends StatelessWidget {
  const AwwabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'آواب',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080808),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Color(0xFF171717),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selectedTab = 0;
  int tasbeehCount = 0;

  static const tabs = ['الرئيسية', 'القرآن', 'الأذكار', 'السبحة', 'الإعدادات'];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      _simplePage('القرآن الكريم', 'قريبًا: المصحف والبحث والعلامات والورد'),
      _simplePage('الأذكار', 'قريبًا: أذكار الصباح والمساء والأذكار اليومية'),
      _tasbeehPage(),
      _simplePage('الإعدادات', 'اللغة والمظهر وحجم الخط والتنبيهات'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: pages[selectedTab],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xCC202020),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(.13)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.35),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (index) {
                final active = selectedTab == index;
                final icons = [
                  Icons.home_rounded,
                  Icons.menu_book_rounded,
                  Icons.auto_awesome_rounded,
                  Icons.radio_button_checked_rounded,
                  Icons.tune_rounded,
                ];
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => setState(() => selectedTab = index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icons[index], size: 20,
                            color: active ? Colors.white : Colors.white54),
                        const SizedBox(height: 3),
                        Text(tabs[index],
                            style: TextStyle(
                              fontSize: 10,
                              color: active ? Colors.white : Colors.white54,
                              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _homePage() {
    return ListView(
      key: const ValueKey('home'),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('السَّلَامُ عَلَيْكُمْ',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 5),
                  Text('أهلًا بك في آواب',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            _glassIcon(Icons.notifications_none_rounded),
          ],
        ),
        const SizedBox(height: 26),
        _glassCard(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('وَاذْكُر رَّبَّكَ كَثِيرًا',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              SizedBox(height: 9),
              Text('اجعل لسانك عامرًا بذكر الله',
                  style: TextStyle(color: Colors.white60, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('مساحتك اليومية', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: [
            _feature(Icons.menu_book_rounded, 'القرآن الكريم', 'تلاوة وورد'),
            _feature(Icons.favorite_border_rounded, 'الأذكار', 'حصنك اليومي'),
            _feature(Icons.radio_button_checked_rounded, 'السبحة', 'اذكر الله'),
            _feature(Icons.mosque_rounded, 'الصلاة', 'المواقيت والأذان'),
          ],
        ),
        const SizedBox(height: 20),
        _glassCard(
          child: const Row(
            children: [
              Icon(Icons.access_time_rounded, color: Colors.white70, size: 25),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مواقيت الصلاة', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('سيتم تحديد الموقع وطريقة الحساب من الإعدادات',
                        style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: Colors.white54),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tasbeehPage() {
    return Center(
      key: const ValueKey('tasbeeh'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('السُّبْحَة', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            const Text('سُبْحَانَ اللَّهِ', style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 34),
            GestureDetector(
              onTap: () => setState(() => tasbeehCount++),
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.055),
                  border: Border.all(color: Colors.white.withOpacity(.25), width: 1.4),
                  boxShadow: [
                    BoxShadow(color: Colors.white.withOpacity(.04), blurRadius: 35, spreadRadius: 4),
                  ],
                ),
                child: Center(
                  child: Text('$tasbeehCount',
                      style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w300)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('اضغط على الدائرة للتسبيح', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => setState(() => tasbeehCount = 0),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('تصفير العداد'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(.25)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simplePage(String title, String subtitle) {
    return Center(
      key: ValueKey(title),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_outlined, size: 42, color: Colors.white70),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(subtitle, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, height: 1.7)),
          ],
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.055),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: child,
    );
  }

  Widget _glassIcon(IconData icon) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(.13)),
      ),
      child: Icon(icon, color: Colors.white70),
    );
  }

  Widget _feature(IconData icon, String title, String subtitle) {
    return _glassCard(
      child: Row(
        children: [
          Icon(icon, size: 23, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
