import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mushaf_text/mushaf_text.dart';
import 'package:adhan/adhan.dart' as adhan;
import 'package:shared_preferences/shared_preferences.dart';
import 'data/azkar_data.dart';
import 'data/surah_names.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  String azkarCategory = awwabAzkar.keys.first;
  final Map<String, int> azkarProgress = {};
  double textScale = 1.0;
  String fontFamily = 'sans-serif';
  String quranSearch = '';
  int lastQuranPage = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      tasbeehCount = prefs.getInt('tasbeeh_count') ?? 0;
      textScale = prefs.getDouble('text_scale') ?? 1.0;
      fontFamily = prefs.getString('font_family') ?? 'sans-serif';
      lastQuranPage = prefs.getInt('last_quran_page') ?? 1;
      for (final category in awwabAzkar.keys) {
        final items = awwabAzkar[category]!;
        for (var i = 0; i < items.length; i++) {
          final key = '$category-$i';
          azkarProgress[key] = prefs.getInt('azkar_$key') ?? 0;
        }
      }
    });
  }

  Future<void> _saveTasbeeh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbeeh_count', tasbeehCount);
  }

  Future<void> _saveAzkar(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('azkar_$key', value);
  }

  static const tabs = ['الرئيسية', 'القرآن', 'الأذكار', 'السبحة', 'المزيد'];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      _quranPage(),
      _azkarPage(),
      _tasbeehPage(),
      _settingsPage(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: DefaultTextStyle(
            style: TextStyle(fontFamily: fontFamily),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
              child: AnimatedSwitcher(duration: const Duration(milliseconds: 220), child: pages[selectedTab]),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                margin: const EdgeInsets.fromLTRB(14, 6, 14, 10),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xAA202020),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(.16)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(.35), blurRadius: 22, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(tabs.length, (index) {
                    final active = selectedTab == index;
                    final icons = [
                      CupertinoIcons.house_fill,
                      CupertinoIcons.book_fill,
                      CupertinoIcons.sparkles,
                      CupertinoIcons.circle,
                      CupertinoIcons.ellipsis,
                    ];
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => setState(() => selectedTab = index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icons[index], size: 20, color: active ? Colors.white : Colors.white54),
                            const SizedBox(height: 3),
                            Text(tabs[index], style: TextStyle(
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
            _glassIcon(Icons.notifications_none_rounded, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersPage()));
            }),
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
            _feature(Icons.menu_book_rounded, 'القرآن الكريم', 'تلاوة وورد', onTap: () => setState(() => selectedTab = 1)),
            _feature(Icons.favorite_border_rounded, 'الأذكار', 'حصنك اليومي', onTap: () => setState(() => selectedTab = 2)),
            _feature(Icons.radio_button_checked_rounded, 'السبحة', 'اذكر الله', onTap: () => setState(() => selectedTab = 3)),
            _feature(Icons.mosque_rounded, 'الصلاة', 'المواقيت والأذان', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesPage()));
            }),
          ],
        ),
        const SizedBox(height: 20),
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesPage())),
          child: _glassCard(
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
                      Text('حساب محلي دون إنترنت • اضغط لعرض المواقيت', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded, color: Colors.white54),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _quranPage() {
    final surahs = Quran.surahs.where((surah) {
      final query = quranSearch.trim();
      return query.isEmpty || surah.nameArabic.contains(query) || surah.number.toString() == query;
    }).toList();
    return ListView(
      key: const ValueKey('quran'),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
      children: [
        const Text('القرآن الكريم', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('مصحف المدينة برواية حفص — يعمل دون إنترنت', style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 14),
        _glassCard(child: Row(children: [
          const Icon(Icons.menu_book_rounded, color: Colors.white70),
          const SizedBox(width: 10),
          const Expanded(child: Text('متابعة آخر قراءة', style: TextStyle(fontWeight: FontWeight.w600))),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuranReaderPage(initialPage: lastQuranPage))),
            child: const Text('متابعة'),
          ),
        ])),
        const SizedBox(height: 8),
        _glassCard(child: Row(children: [
          const Icon(Icons.bookmarks_outlined, color: Colors.white70),
          const SizedBox(width: 10),
          const Expanded(child: Text('علاماتي المرجعية', style: TextStyle(fontWeight: FontWeight.w600))),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranBookmarksPage())),
            child: const Text('عرض'),
          ),
        ])),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => setState(() => quranSearch = value),
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'ابحث باسم السورة أو رقمها',
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(.055),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.white.withOpacity(.12))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.white.withOpacity(.12))),
          ),
        ),
        const SizedBox(height: 14),
        ...surahs.map((surah) => Container(
          margin: const EdgeInsets.only(bottom: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.045),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(.08)),
          ),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withOpacity(.10),
              child: Text(surah.number.toString(), style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
            title: Text(surah.nameArabic, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Text('ص ${surah.startPage}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuranReaderPage(initialPage: surah.startPage))),
          ),
        )),
      ],
    );
  }

  Widget _azkarPage() {
    final items = awwabAzkar[azkarCategory]!;
    return ListView(
      key: const ValueKey('azkar'),
      padding: const EdgeInsets.all(18),
      children: [
        const Text('الأذكار', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          children: awwabAzkar.keys.map((category) => ChoiceChip(
            label: Text(category),
            selected: category == azkarCategory,
            onSelected: (_) => setState(() => azkarCategory = category),
            selectedColor: Colors.white,
            backgroundColor: const Color(0xFF222222),
            labelStyle: TextStyle(color: category == azkarCategory ? Colors.black : Colors.white, fontSize: 12),
          )).toList(),
        ),
        const SizedBox(height: 14),
        ...List.generate(items.length, (index) {
          final item = items[index];
          final key = '$azkarCategory-$index';
          final target = item['count'] as int;
          final current = azkarProgress[key] ?? 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.055),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(.12)),
            ),
            child: Column(
              children: [
                Text(item['text'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.8)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('$current / $target', style: const TextStyle(color: Colors.white70)),
                    const Spacer(),
                    IconButton.filled(
                      onPressed: current >= target ? null : () {
                        final next = current + 1;
                        setState(() => azkarProgress[key] = next);
                        _saveAzkar(key, next);
                      },
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                    ),
                    IconButton(
                      onPressed: () { setState(() => azkarProgress[key] = 0); _saveAzkar(key, 0); },
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
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
              onTap: () { setState(() => tasbeehCount++); _saveTasbeeh(); },
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
              onPressed: () { setState(() => tasbeehCount = 0); _saveTasbeeh(); },
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

  Widget _settingsPage() {
    return ListView(key: const ValueKey('more'), padding: const EdgeInsets.all(20), children: [
      const Text('المزيد', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('أدواتك ومحتواك الإسلامي', style: TextStyle(color: Colors.white54)),
      const SizedBox(height: 18),
      _moreTile(Icons.shield_moon_outlined, 'الرقية الشرعية', 'آية الكرسي والإخلاص والفلق والناس', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RuqyahPage()));
      }),
      _moreTile(Icons.auto_awesome_outlined, 'فضل القرآن والذكر', 'آيات وأحاديث في فضل التلاوة والذكر', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AwwabInfoPage(
          title: 'فضل القرآن والذكر',
          sections: [
            ['فضل الذكر', 'قال الله تعالى: ﴿يَا أَيُّهَا الَّذِينَ آمَنُوا اذْكُرُوا اللَّهَ ذِكْرًا كَثِيرًا ۝ وَسَبِّحُوهُ بُكْرَةً وَأَصِيلًا﴾ — الأحزاب: 41-42.'],
            ['فضل القرآن', 'قال رسول الله ﷺ: «خيركم من تعلم القرآن وعلمه» — صحيح البخاري، حديث 5027.'],
            ['حياة القلب', 'قال رسول الله ﷺ: «مثل الذي يذكر ربه والذي لا يذكر ربه مثل الحي والميت» — صحيح البخاري، حديث 6407.'],
          ],
        )));
      }),
      _moreTile(Icons.nightlight_round, 'قيام الليل وصلاة الضحى', 'تعريف وفضل وأوقات العبادة', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AwwabInfoPage(
          title: 'قيام الليل وصلاة الضحى',
          sections: [
            ['قيام الليل', 'قال الله تعالى: ﴿وَمِنَ اللَّيْلِ فَتَهَجَّدْ بِهِ نَافِلَةً لَكَ﴾ — الإسراء: 79. يبدأ وقته بعد صلاة العشاء وينتهي بطلوع الفجر.'],
            ['الثلث الأخير', 'ينبغي تحري الثلث الأخير من الليل بحسب وقتي المغرب والفجر في مدينتك.'],
            ['صلاة الضحى', 'وقتها بعد ارتفاع الشمس إلى قبيل الزوال، وأقلها ركعتان. ورد فضلها في صحيح مسلم، حديث 720.'],
          ],
        )));
      }),
      _moreTile(Icons.event_available_outlined, 'متابعة التذكيرات', 'متابعة صيام الاثنين والخميس والصلاة على النبي ﷺ', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersPage()));
      }),
      const SizedBox(height: 16),
      const Text('الإعدادات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      _glassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('حجم الخط', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('معاينة النص', style: TextStyle(fontSize: 15 * textScale)),
        Slider(value: textScale, min: 0.85, max: 1.25, divisions: 8, activeColor: Colors.white, onChanged: (v) async { setState(() => textScale = v); final p = await SharedPreferences.getInstance(); await p.setDouble('text_scale', v); }),
      ])),
      const SizedBox(height: 12),
      _glassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('نوع الخط', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: fontFamily,
          dropdownColor: const Color(0xFF202020),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          items: const [
            DropdownMenuItem(value: 'sans-serif', child: Text('خط النظام')),
            DropdownMenuItem(value: 'serif', child: Text('خط كلاسيكي')),
            DropdownMenuItem(value: 'monospace', child: Text('خط ثابت')),
          ],
          onChanged: (value) async {
            if (value == null) return;
            setState(() => fontFamily = value);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('font_family', value);
          },
        ),
      ])),
      const SizedBox(height: 12),
      _glassCard(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('المظهر', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text('أسود زجاجي — الهوية المعتمدة بالأسود والأبيض', style: TextStyle(color: Colors.white60, fontSize: 12)),
      ])),
      const SizedBox(height: 12),
      _glassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('اللغة', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text('الواجهة العربية هي اللغة الحالية. دعم الترجمة الكاملة للإنجليزية والفرنسية ما زال ضمن متطلبات الإصدار.', style: TextStyle(color: Colors.white60, fontSize: 12)),
      ])),
      const SizedBox(height: 12),
      _glassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('البيانات', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('عداد السبحة وتقدم الأذكار محفوظان على جهازك.', style: TextStyle(color: Colors.white60, fontSize: 12)),
        TextButton.icon(onPressed: () async { final p = await SharedPreferences.getInstance(); await p.setDouble('text_scale', 1.0); if (!mounted) return; setState(() => textScale = 1.0); }, icon: const Icon(Icons.restart_alt_rounded), label: const Text('إعادة ضبط حجم الخط')),
      ])),
    ]);
  }

  Widget _moreTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: _glassCard(child: Row(children: [
          Icon(icon, color: Colors.white70, size: 23),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ])),
          const Icon(Icons.chevron_left_rounded, color: Colors.white54),
        ])),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(borderRadius: BorderRadius.circular(22), child: BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18), child: Container(padding: const EdgeInsets.all(19), decoration: BoxDecoration(color: Colors.white.withOpacity(.065), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(.16), width: .8)), child: child)));
  }

  Widget _glassIcon(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(.13)),
        ),
        child: Icon(icon, color: Colors.white70),
      ),
    );
  }

  Widget _feature(IconData icon, String title, String subtitle, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: _glassCard(
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
      ),
    );
  }
}


class QuranReaderPage extends StatefulWidget {
  final int initialPage;
  const QuranReaderPage({super.key, this.initialPage = 1});
  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  late final PageController pageController;
  late int currentPage;
  double fontSize = 32;
  bool tajweed = false;
  Axis readingAxis = Axis.horizontal;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage.clamp(1, Quran.pageCount).toInt();
    pageController = PageController(initialPage: currentPage - 1);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _savePage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_quran_page', page);
    if (!mounted) return;
    setState(() => currentPage = page);
  }

  Future<void> _saveAyah(int ayahId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_quran_ayah', ayahId);
    await prefs.setInt('last_quran_page', currentPage);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ موضع الآية'), duration: Duration(milliseconds: 900)),
    );
  }

  Future<void> _addBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('quran_bookmarks') ?? <String>[];
    final page = currentPage.toString();
    if (!bookmarks.contains(page)) bookmarks.add(page);
    await prefs.setStringList('quran_bookmarks', bookmarks);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إضافة الصفحة إلى العلامات'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = MushafColors.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.paper,
        appBar: AppBar(
          backgroundColor: colors.paper,
          foregroundColor: colors.accent,
          elevation: 0,
          title: Text('المصحف الشريف • صفحة $currentPage', style: TextStyle(fontSize: 15, color: colors.accent)),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: tajweed ? 'إيقاف التجويد الملون' : 'إظهار أحكام التجويد',
              onPressed: () => setState(() => tajweed = !tajweed),
              icon: Icon(Icons.auto_awesome_rounded, color: tajweed ? Colors.white : colors.accent),
            ),
            IconButton(
              tooltip: 'تغيير اتجاه التقليب',
              onPressed: () => setState(() => readingAxis = readingAxis == Axis.horizontal ? Axis.vertical : Axis.horizontal),
              icon: Icon(readingAxis == Axis.horizontal ? Icons.swap_vert_rounded : Icons.swap_horiz_rounded, color: colors.accent),
            ),
            IconButton(
              tooltip: 'إضافة علامة مرجعية',
              onPressed: _addBookmark,
              icon: Icon(Icons.bookmark_add_outlined, color: colors.accent),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: pageController,
                scrollDirection: readingAxis,
                reverse: readingAxis == Axis.horizontal,
                itemCount: Quran.pageCount,
                onPageChanged: _savePage,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ColoredBox(
                      color: colors.paper,
                      child: MushafPage(
                        page: index + 1,
                        colors: colors,
                        tajweed: tajweed,
                        maxFontSize: fontSize,
                        onAyahTap: _saveAyah,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
              decoration: BoxDecoration(
                color: colors.paper,
                border: Border(top: BorderSide(color: colors.accent.withOpacity(.22))),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('حجم العرض', style: TextStyle(color: colors.accent, fontSize: 11)),
                      Expanded(
                        child: Slider(
                          value: fontSize,
                          min: 22,
                          max: 38,
                          divisions: 16,
                          activeColor: colors.accent,
                          onChanged: (value) => setState(() => fontSize = value),
                        ),
                      ),
                      Text(fontSize.round().toString(), style: TextStyle(color: colors.accent, fontSize: 11)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('صفحة $currentPage من ${Quran.pageCount}', style: TextStyle(color: colors.accent, fontSize: 11)),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: currentPage > 1 ? () => pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut) : null,
                        icon: Icon(Icons.chevron_right_rounded, color: colors.accent),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: currentPage < Quran.pageCount ? () => pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut) : null,
                        icon: Icon(Icons.chevron_left_rounded, color: colors.accent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuranBookmarksPage extends StatefulWidget {
  const QuranBookmarksPage({super.key});
  @override
  State<QuranBookmarksPage> createState() => _QuranBookmarksPageState();
}

class _QuranBookmarksPageState extends State<QuranBookmarksPage> {
  List<int> pages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => pages = (prefs.getStringList('quran_bookmarks') ?? []).map(int.parse).toList()..sort());
  }

  Future<void> _remove(int page) async {
    final prefs = await SharedPreferences.getInstance();
    pages.remove(page);
    await prefs.setStringList('quran_bookmarks', pages.map((e) => e.toString()).toList());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(backgroundColor: const Color(0xFF080808), foregroundColor: Colors.white, title: const Text('علاماتي المرجعية')),
        body: pages.isEmpty
          ? const Center(child: Text('لم تحفظ صفحات بعد', style: TextStyle(color: Colors.white54)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: pages.map((page) => ListTile(
                title: Text('صفحة $page'),
                leading: const Icon(Icons.bookmark, color: Colors.white70),
                trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _remove(page)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuranReaderPage(initialPage: page))),
              )).toList(),
            ),
      ),
    );
  }
}


class RuqyahPage extends StatelessWidget {
  const RuqyahPage({super.key});

  Future<List<String>> _loadRuqyah() async {
    final kursi = await Quran.ayah(2, 255);
    final ikhlas = await Quran.surahAyahs(112);
    final falaq = await Quran.surahAyahs(113);
    final nas = await Quran.surahAyahs(114);
    return [
      'آية الكرسي — البقرة: 255\\n${kursi?.text ?? ''}',
      'سورة الإخلاص\\n${ikhlas.map((a) => a.text).join(' ۝ ')}',
      'سورة الفلق\\n${falaq.map((a) => a.text).join(' ۝ ')}',
      'سورة الناس\\n${nas.map((a) => a.text).join(' ۝ ')}',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(backgroundColor: const Color(0xFF080808), foregroundColor: Colors.white, title: const Text('الرقية الشرعية')),
        body: FutureBuilder<List<String>>(
          future: _loadRuqyah(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
            if (snapshot.hasError || !snapshot.hasData) return const Center(child: Text('تعذر تحميل نص الرقية من المصحف المحلي.'));
            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text('اقرأ الآيات بتدبر ويقين، والشفاء من الله وحده.', style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 12),
                ...snapshot.data!.map((text) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.055), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(.12))),
                  child: SelectableText(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, height: 2, color: Colors.white)),
                )),
                const Text('نص الآيات من بيانات المصحف المنسوبة إلى مشروع Tanzil.', style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AwwabInfoPage extends StatelessWidget {
  final String title;
  final List<List<String>> sections;
  const AwwabInfoPage({super.key, required this.title, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(backgroundColor: const Color(0xFF080808), foregroundColor: Colors.white, title: Text(title)),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: sections.map((section) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.055), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(.12))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(section[0], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              Text(section[1], style: const TextStyle(color: Colors.white, height: 1.8, fontSize: 15)),
            ]),
          )).toList(),
        ),
      ),
    );
  }
}

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});
  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final Map<String, bool> values = {
    'صيام يوم الاثنين': false,
    'صيام يوم الخميس': false,
    'الصلاة على النبي ﷺ': false,
    'قيام الليل': false,
    'صلاة الضحى': false,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      for (final key in values.keys) {
        values[key] = prefs.getBool('reminder_check_$key') ?? false;
      }
    });
  }

  Future<void> _toggle(String key, bool value) async {
    setState(() => values[key] = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_check_$key', value);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(backgroundColor: const Color(0xFF080808), foregroundColor: Colors.white, title: const Text('متابعة التذكيرات')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text('علّم ما أنجزته؛ تُحفظ المتابعة على جهازك. هذه قائمة متابعة وليست إشعارات تلقائية بعد.', style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.6)),
            const SizedBox(height: 14),
            ...values.keys.map((key) => Container(
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.055), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(.1))),
              child: CheckboxListTile(
                value: values[key],
                onChanged: (value) => _toggle(key, value ?? false),
                activeColor: Colors.white,
                checkColor: Colors.black,
                title: Text(key, style: const TextStyle(fontSize: 13)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});
  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  static const cities = <String, List<double>>{
    'الفيوم': [29.3084, 30.8428],
    'القاهرة': [30.0444, 31.2357],
    'الجيزة': [30.0131, 31.2089],
    'الإسكندرية': [31.2001, 29.9187],
    'طنطا': [30.7865, 31.0004],
    'المنصورة': [31.0409, 31.3785],
    'أسيوط': [27.1809, 31.1837],
    'الأقصر': [25.6872, 32.6396],
    'أسوان': [24.0889, 32.8998],
  };
  String city = 'الفيوم';

  String _time(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour < 12 ? 'ص' : 'م'}';
  }

  @override
  Widget build(BuildContext context) {
    final point = cities[city]!;
    final coordinates = adhan.Coordinates(point[0], point[1]);
    final params = adhan.CalculationMethod.egyptian.getParameters();
    params.madhab = adhan.Madhab.shafi;
    final times = adhan.PrayerTimes.today(coordinates, params);
    final rows = <MapEntry<String, DateTime>>[
      MapEntry('الفجر', times.fajr),
      MapEntry('الشروق', times.sunrise),
      MapEntry('الظهر', times.dhuhr),
      MapEntry('العصر', times.asr),
      MapEntry('المغرب', times.maghrib),
      MapEntry('العشاء', times.isha),
    ];
    final now = DateTime.now();
    final upcoming = rows.where((e) => e.key != 'الشروق' && e.value.isAfter(now)).toList();
    final next = upcoming.isNotEmpty ? upcoming.first : rows.first;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(
          backgroundColor: const Color(0xFF080808),
          foregroundColor: Colors.white,
          title: const Text('مواقيت الصلاة'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.075),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(.16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('المدينة', style: TextStyle(color: Colors.white60, fontSize: 12)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: city,
                        dropdownColor: const Color(0xFF202020),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(.06),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        items: cities.keys.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                        onChanged: (value) { if (value != null) setState(() => city = value); },
                      ),
                      const SizedBox(height: 16),
                      Text('الصلاة القادمة: ${next.key}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 5),
                      Text(_time(next.value), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 6),
                      const Text('يُعاد الحساب محليًا على جهازك ولا يحتاج إلى اتصال بالإنترنت.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...rows.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(entry.key == next.key ? .12 : .05),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: Colors.white.withOpacity(entry.key == next.key ? .25 : .09)),
              ),
              child: Row(
                children: [
                  Icon(entry.key == 'الشروق' ? Icons.wb_sunny_outlined : Icons.mosque_outlined, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600))),
                  Text(_time(entry.value), style: const TextStyle(color: Colors.white70, fontFeatures: [ui.FontFeature.tabularFigures()])),
                ],
              ),
            )),
            const SizedBox(height: 10),
            const Text('طريقة الحساب: الهيئة المصرية العامة للمساحة. مواقيت الصلاة تقديرية وفق إحداثيات المدينة المختارة وقد تختلف دقائق عن الجداول المحلية الرسمية.', style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.6)),
          ],
        ),
      ),
    );
  }
}
