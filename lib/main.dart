import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:mushaf_text/mushaf_text.dart';
import 'package:adhan/adhan.dart' as adhan;
import 'package:shared_preferences/shared_preferences.dart';
import 'data/azkar_data.dart';
import 'data/surah_names.dart';
import 'services/prayer_notification_service.dart';

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
    return ListView(key: const ValueKey('home'), padding: const EdgeInsets.fromLTRB(18, 16, 18, 24), children: [
      Row(children: [
        _glassIcon(Icons.location_on_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerCenterPage()))),
        const Spacer(),
        _glassIcon(Icons.alarm_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersPage()))),
      ]),
      const SizedBox(height: 14),
      const Text('السَّلَامُ عَلَيْكُمْ', style: TextStyle(color: Colors.white70, fontSize: 13)),
      const SizedBox(height: 5),
      Text(DateTime.now().hour < 12 ? 'صباح الخير' : 'مساء الخير', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
      const SizedBox(height: 18),
      awwabGlassCard(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('وَاذْكُر رَّبَّكَ كَثِيرًا', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        SizedBox(height: 7),
        Text('اجعل لسانك عامرًا بذكر الله', style: TextStyle(color: Colors.white60, fontSize: 13)),
      ])),
      const SizedBox(height: 18),
      const Text('مواقيت الصلاة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      const HomePrayerSummary(),
    ]);
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
        awwabGlassCard(child: Row(children: [
          const Icon(Icons.menu_book_rounded, color: Colors.white70),
          const SizedBox(width: 10),
          const Expanded(child: Text('متابعة آخر قراءة', style: TextStyle(fontWeight: FontWeight.w600))),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuranReaderPage(initialPage: lastQuranPage))),
            child: const Text('متابعة'),
          ),
        ])),
        const SizedBox(height: 8),
        awwabGlassCard(child: Row(children: [
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
    const phrases = ['سُبْحَانَ اللَّهِ', 'الْحَمْدُ لِلَّهِ', 'لَا إِلَٰهَ إِلَّا اللَّهُ', 'اللَّهُ أَكْبَرُ', 'أَسْتَغْفِرُ اللَّهَ', 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّد'];
    return GestureDetector(
      key: const ValueKey('tasbeeh'),
      behavior: HitTestBehavior.opaque,
      onTap: () { setState(() => tasbeehCount++); _saveTasbeeh(); },
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('السُّبْحَة', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(phrases[tasbeehCount % phrases.length], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 17)),
            const SizedBox(height: 28),
            Container(
              width: 210, height: 210,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.055), border: Border.all(color: Colors.white.withOpacity(.25), width: 1.4), boxShadow: [BoxShadow(color: Colors.white.withOpacity(.04), blurRadius: 35, spreadRadius: 4)]),
              child: Center(child: Text('$tasbeehCount', style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w300))),
            ),
            const SizedBox(height: 22),
            const Text('المس أي مكان في الشاشة للتسبيح', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: () { setState(() => tasbeehCount = 0); _saveTasbeeh(); },
              icon: const Icon(Icons.refresh_rounded, size: 18), label: const Text('تصفير العداد'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withOpacity(.25))),
            ),
          ]),
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
      _moreTile(Icons.menu_book_rounded, 'الحديث النبوي', 'أحاديث مختارة مع مصادرها', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithPage()));
      }),
      _moreTile(Icons.auto_awesome_outlined, 'أسماء الله الحسنى', 'الأسماء ومعانيها المختصرة مع البحث', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AsmaUlHusnaPage()));
      }),
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
      _moreTile(Icons.notifications_active_outlined, 'مركز الصلاة والتنبيهات', 'مواقيت الصلاة والتنبيه قبل الأذان وعند دخوله', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerCenterPage()));
      }),
      _moreTile(Icons.explore_outlined, 'اتجاه القبلة', 'بوصلة حية باستخدام مستشعر الهاتف', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaPage()));
      }),
      _moreTile(Icons.calendar_month_outlined, 'التقويم الهجري والمناسبات', 'التاريخ الهجري والمناسبات الإسلامية', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HijriCalendarPage()));
      }),
      _moreTile(Icons.menu_book_outlined, 'الورد القرآني اليومي', 'حدد هدفك من الصفحات وتابع إنجازك', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyWirdPage()));
      }),
      _moreTile(Icons.checklist_rounded, 'متابعة العبادات', 'متابعة الصلاة والنوافل والأذكار يوميًا', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WorshipTrackerPage()));
      }),
      const SizedBox(height: 16),
      const Text('الإعدادات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      _moreTile(Icons.text_fields_rounded, 'حجم الخط', 'اضبط حجم القراءة من نافذة جانبية', _showTextScaleDialog),
      const SizedBox(height: 12),
      awwabGlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      awwabGlassCard(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('المظهر', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text('أسود زجاجي — الهوية المعتمدة بالأسود والأبيض', style: TextStyle(color: Colors.white60, fontSize: 12)),
      ])),
      const SizedBox(height: 12),
      awwabGlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('اللغة', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text('الواجهة العربية هي اللغة الحالية. دعم الترجمة الكاملة للإنجليزية والفرنسية ما زال ضمن متطلبات الإصدار.', style: TextStyle(color: Colors.white60, fontSize: 12)),
      ])),
      const SizedBox(height: 12),
      awwabGlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('البيانات', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('عداد السبحة وتقدم الأذكار محفوظان على جهازك.', style: TextStyle(color: Colors.white60, fontSize: 12)),
        TextButton.icon(onPressed: () async { final p = await SharedPreferences.getInstance(); await p.setDouble('text_scale', 1.0); if (!mounted) return; setState(() => textScale = 1.0); }, icon: const Icon(Icons.restart_alt_rounded), label: const Text('إعادة ضبط حجم الخط')),
      ])),
    ]);
  }

  Future<void> _showTextScaleDialog() async {
    double value = textScale;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF191919),
          title: const Text('حجم الخط'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('معاينة النص', style: TextStyle(fontSize: 16 * value)),
            Slider(
              value: value, min: 0.85, max: 1.25, divisions: 8,
              activeColor: Colors.white,
              onChanged: (v) {
                setDialogState(() => value = v);
                setState(() => textScale = v);
              },
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setDouble('text_scale', value);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moreTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: awwabGlassCard(child: Row(children: [
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


class HomePrayerSummary extends StatefulWidget {
  const HomePrayerSummary({super.key});
  @override
  State<HomePrayerSummary> createState() => _HomePrayerSummaryState();
}

class _HomePrayerSummaryState extends State<HomePrayerSummary> {
  static const places = <String, List<double>>{
    'الفيوم': [29.3084, 30.8428], 'القاهرة': [30.0444, 31.2357],
    'الجيزة': [30.0131, 31.2089], 'الإسكندرية': [31.2001, 29.9187],
    'طنطا': [30.7865, 31.0004], 'المنصورة': [31.0409, 31.3785],
    'أسيوط': [27.1809, 31.1837], 'الأقصر': [25.6872, 32.6396], 'أسوان': [24.0889, 32.8998],
  };
  String city = 'الفيوم';
  DateTime now = DateTime.now();
  Timer? ticker;
  @override
  void initState() {
    super.initState();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() => now = DateTime.now()); });
  }
  @override
  void dispose() { ticker?.cancel(); super.dispose(); }

  String _time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '$h:' + d.minute.toString().padLeft(2, '0') + (d.hour < 12 ? ' ص' : ' م');
  }
  String _left(DateTime d) {
    final n = d.difference(now).inSeconds;
    if (n < 0) return 'انتهى';
    return (n ~/ 3600).toString().padLeft(2, '0') + ':' +
      ((n % 3600) ~/ 60).toString().padLeft(2, '0') + ':' +
      (n % 60).toString().padLeft(2, '0');
  }
  @override
  Widget build(BuildContext context) {
    final p = places[city]!;
    final params = adhan.CalculationMethod.egyptian.getParameters();
    final times = adhan.PrayerTimes.today(adhan.Coordinates(p[0], p[1]), params);
    final rows = <MapEntry<String, DateTime>>[
      MapEntry('الفجر', times.fajr), MapEntry('الشروق', times.sunrise),
      MapEntry('الظهر', times.dhuhr), MapEntry('العصر', times.asr),
      MapEntry('المغرب', times.maghrib), MapEntry('العشاء', times.isha),
    ];
    final fajrEnd = times.fajr.isBefore(times.maghrib)
        ? times.fajr.add(const Duration(days: 1))
        : times.fajr;
    final nightSeconds = fajrEnd.difference(times.maghrib).inSeconds;
    final qiyamStart = times.maghrib.add(Duration(seconds: (nightSeconds * 2 / 3).round()));
    rows.add(MapEntry('قيام الليل', qiyamStart));
    MapEntry<String, DateTime>? next;
    for (final row in rows) {
      if (row.key != 'الشروق' && row.key != 'قيام الليل' && row.value.isAfter(now)) { next = row; break; }
    }
    final upcoming = next ?? rows.first;
    final target = next == null ? upcoming.value.add(const Duration(days: 1)) : upcoming.value;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withOpacity(.065), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(.16))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              DropdownButton<String>(
                value: city, dropdownColor: const Color(0xFF202020), underline: const SizedBox.shrink(), isDense: true,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                items: places.keys.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) { if (v != null) setState(() => city = v); },
              ),
              const Spacer(),
              Text('الصلاة القادمة: ' + upcoming.key, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
            const SizedBox(height: 5),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_time(target), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('الوقت المتبقي', style: TextStyle(color: Colors.white54, fontSize: 10)),
                Text(_left(target), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, fontFeatures: [ui.FontFeature.tabularFigures()])),
              ]),
            ]),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 22),
            ...rows.map((row) {
              final targetTime = row.value.isAfter(now) ? row.value : row.value.add(const Duration(days: 1));
              final isNext = row.key == upcoming.key;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                decoration: BoxDecoration(
                  color: isNext ? Colors.white.withOpacity(.13) : Colors.white.withOpacity(.035),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(isNext ? .22 : .07)),
                ),
                child: Row(children: [
                  SizedBox(width: 88, child: Text(row.key, style: TextStyle(fontSize: 12, color: isNext ? Colors.white : Colors.white70, fontWeight: isNext ? FontWeight.w700 : FontWeight.w500))),
                  Text(_time(row.value), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFeatures: [ui.FontFeature.tabularFigures()])),
                  const Spacer(),
                  Text(row.key == 'الشروق' ? 'شروق الشمس' : row.key == 'قيام الليل' ? 'بداية الثلث الأخير' : 'متبقي ' + _left(targetTime),
                    style: const TextStyle(fontSize: 10, color: Colors.white54, fontFeatures: [ui.FontFeature.tabularFigures()])),
                ]),
              );
            }),
          ]),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: colors.accent, visualDensity: VisualDensity.compact),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (dialogContext) => StatefulBuilder(
                          builder: (dialogContext, updateDialog) => AlertDialog(
                            backgroundColor: colors.paper,
                            title: Text('حجم خط المصحف', style: TextStyle(color: colors.accent)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Slider(
                                  value: fontSize,
                                  min: 22,
                                  max: 38,
                                  divisions: 16,
                                  activeColor: colors.accent,
                                  onChanged: (value) {
                                    setState(() => fontSize = value);
                                    updateDialog(() {});
                                  },
                                ),
                                Text(fontSize.round().toString(), style: TextStyle(color: colors.accent)),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('تم', style: TextStyle(color: colors.accent))),
                            ],
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.text_fields_rounded, size: 18),
                      label: const Text('حجم الخط'),
                    ),
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
    final fatiha = await Quran.surahAyahs(1);
    final kursi = await Quran.ayah(2, 255);
    final lastBaqara1 = await Quran.ayah(2, 285);
    final lastBaqara2 = await Quran.ayah(2, 286);
    final ikhlas = await Quran.surahAyahs(112);
    final falaq = await Quran.surahAyahs(113);
    final nas = await Quran.surahAyahs(114);
    return [
      'سورة الفاتحة\n${fatiha.map((a) => a.text).join(' ۝ ')}',
      'آية الكرسي — البقرة: 255\n${kursi?.text ?? ''}',
      'آخر آيتين من سورة البقرة\n${lastBaqara1?.text ?? ''} ۝ ${lastBaqara2?.text ?? ''}',
      'سورة الإخلاص\n${ikhlas.map((a) => a.text).join(' ۝ ')}',
      'سورة الفلق\n${falaq.map((a) => a.text).join(' ۝ ')}',
      'سورة الناس\n${nas.map((a) => a.text).join(' ۝ ')}',
      'دعاء الرقية: أذهب البأس رب الناس، واشف أنت الشافي، لا شفاء إلا شفاؤك، شفاءً لا يغادر سقمًا.',
      'دعاء التحصين: أعوذ بكلمات الله التامات من شر ما خلق.',
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


class AsmaUlHusnaPage extends StatefulWidget {
  const AsmaUlHusnaPage({super.key});
  @override
  State<AsmaUlHusnaPage> createState() => _AsmaUlHusnaPageState();
}

class _AsmaUlHusnaPageState extends State<AsmaUlHusnaPage> {
  String query = '';
  static const names = <List<String>>[
    ['الرَّحْمَن', 'واسع الرحمة لجميع خلقه'], ['الرَّحِيم', 'كثير الرحمة بالمؤمنين'], ['الْمَلِك', 'المالك المتصرف في خلقه'], ['الْقُدُّوس', 'المنزه عن كل نقص'], ['السَّلَام', 'السالم من كل عيب ونقص'], ['الْمُؤْمِن', 'الذي يؤمّن عباده ويصدق رسله'], ['الْمُهَيْمِن', 'الرقيب الحافظ'], ['الْعَزِيز', 'الغالب الذي لا يُغلب'], ['الْجَبَّار', 'العلي القاهر وجابر الكسير'], ['الْمُتَكَبِّر', 'المتعالي عن صفات الخلق'],
    ['الْخَالِق', 'المقدّر والموجد للأشياء'], ['الْبَارِئ', 'الذي أوجد الخلق'], ['الْمُصَوِّر', 'الذي أعطى كل شيء صورته'], ['الْغَفَّار', 'كثير المغفرة'], ['الْقَهَّار', 'الغالب لكل شيء'], ['الْوَهَّاب', 'كثير العطاء'], ['الرَّزَّاق', 'المتكفل بأرزاق خلقه'], ['الْفَتَّاح', 'الذي يفتح أبواب الرحمة والخير'], ['الْعَلِيم', 'المحيط علمه بكل شيء'], ['الْقَابِض', 'يقبض بحكمته'],
    ['الْبَاسِط', 'يبسط فضله ورزقه'], ['الْخَافِض', 'يخفض من شاء بحكمته'], ['الرَّافِع', 'يرفع من شاء بفضله'], ['الْمُعِزّ', 'يهب العزة لمن شاء'], ['الْمُذِلّ', 'يذل من شاء بعدله'], ['السَّمِيع', 'الذي يسمع كل شيء'], ['الْبَصِير', 'الذي يرى كل شيء'], ['الْحَكَم', 'الحاكم بالحق'], ['الْعَدْل', 'المنزه عن الظلم'], ['اللَّطِيف', 'الرفيق بعباده العالم بدقائق الأمور'],
    ['الْخَبِير', 'العالم ببواطن الأمور'], ['الْحَلِيم', 'لا يعاجل العصاة بالعقوبة'], ['الْعَظِيم', 'ذو العظمة والكبرياء'], ['الْغَفُور', 'واسع المغفرة'], ['الشَّكُور', 'يجزي على العمل القليل الكثير'], ['الْعَلِيّ', 'المتعالي فوق خلقه'], ['الْكَبِير', 'العظيم الذي كل شيء دونه'], ['الْحَفِيظ', 'الحافظ لكل شيء'], ['الْمُقِيت', 'الموصل أقوات الخلق'], ['الْحَسِيب', 'الكافي والمحاسب لعباده'],
    ['الْجَلِيل', 'المتصف بصفات العظمة'], ['الْكَرِيم', 'كثير الخير والعطاء'], ['الرَّقِيب', 'المطلع على أعمال عباده'], ['الْمُجِيب', 'الذي يجيب دعاء الداعين'], ['الْوَاسِع', 'الذي وسع علمه ورحمته كل شيء'], ['الْحَكِيم', 'الذي يضع الأمور مواضعها'], ['الْوَدُود', 'المحب لأوليائه'], ['الْمَجِيد', 'العظيم واسع الكرم والشرف'], ['الْبَاعِث', 'يبعث الخلق بعد الموت'], ['الشَّهِيد', 'المطلع على كل شيء'],
    ['الْحَقّ', 'الثابت الذي لا شك فيه'], ['الْوَكِيل', 'الكفيل بأمور عباده'], ['الْقَوِيّ', 'كامل القوة'], ['الْمَتِين', 'شديد القوة'], ['الْوَلِيّ', 'ناصر المؤمنين ومتولي أمورهم'], ['الْحَمِيد', 'المستحق للحمد كله'], ['الْمُحْصِي', 'الذي أحاط بكل شيء عددًا'], ['الْمُبْدِئ', 'الذي بدأ الخلق'], ['الْمُعِيد', 'الذي يعيد الخلق بعد الموت'], ['الْمُحْيِي', 'واهب الحياة'],
    ['الْمُمِيت', 'مقدر الموت على خلقه'], ['الْحَيّ', 'كامل الحياة التي لا تزول'], ['الْقَيُّوم', 'القائم بنفسه المقيم لغيره'], ['الْوَاجِد', 'الغني الذي لا يعوزه شيء'], ['الْمَاجِد', 'كامل المجد والشرف'], ['الْوَاحِد', 'المتفرد الذي لا شريك له'], ['الصَّمَد', 'المقصود في الحوائج'], ['الْقَادِر', 'تام القدرة'], ['الْمُقْتَدِر', 'كامل الاقتدار'], ['الْمُقَدِّم', 'يقدم من شاء بحكمته'],
    ['الْمُؤَخِّر', 'يؤخر من شاء بحكمته'], ['الأَوَّل', 'ليس قبله شيء'], ['الآخِر', 'ليس بعده شيء'], ['الظَّاهِر', 'العالي فوق خلقه'], ['الْبَاطِن', 'المحيط علمه بكل شيء'], ['الْوَالِي', 'المتولي تدبير الخلق'], ['الْمُتَعَالِي', 'المتنزه عن صفات النقص'], ['الْبَرّ', 'كثير الإحسان'], ['التَّوَّاب', 'يوفق للتوبة ويقبلها'], ['الْمُنْتَقِم', 'يعاقب من يستحق بعدله'],
    ['الْعَفُوّ', 'يمحو الذنوب ويتجاوز عنها'], ['الرَّؤُوف', 'شديد الرحمة بعباده'], ['مَالِكُ الْمُلْك', 'صاحب الملك كله'], ['ذُو الْجَلَالِ وَالإِكْرَام', 'صاحب العظمة والإحسان'], ['الْمُقْسِط', 'العادل في حكمه'], ['الْجَامِع', 'يجمع الخلائق ليوم الحساب'], ['الْغَنِيّ', 'المستغني عن كل ما سواه'], ['الْمُغْنِي', 'يغني من يشاء من عباده'], ['الْمَانِع', 'يمنع بحكمته'], ['الْمُعْطِي', 'الذي يعطي من يشاء من فضله'], ['الضَّارّ', 'لا يقع ضر إلا بإذنه وحكمته'],
    ['النَّافِع', 'بيده النفع والخير'], ['النُّور', 'منوّر السماوات والأرض'], ['الْهَادِي', 'يهدي من يشاء إلى صراطه'], ['الْبَدِيع', 'موجد الخلق على غير مثال سابق'], ['الْبَاقِي', 'الدائم الذي لا يفنى'], ['الْوَارِث', 'الباقي بعد فناء الخلق'], ['الرَّشِيد', 'الذي أرشد الخلق إلى مصالحهم'], ['الصَّبُور', 'لا يعجل بالعقوبة']
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = names.where((item) => item[0].contains(query) || item[1].contains(query)).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(backgroundColor: const Color(0xFF080808), foregroundColor: Colors.white, title: const Text('أسماء الله الحسنى')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('﴿وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ فَادْعُوهُ بِهَا﴾', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.8)),
            const SizedBox(height: 12),
            TextField(
              textDirection: TextDirection.rtl,
              onChanged: (value) => setState(() => query = value.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم أو معنى',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white.withOpacity(.06),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(.12))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(.12))),
              ),
            ),
            const SizedBox(height: 12),
            Text('${filtered.length} من ${names.length} اسمًا', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 8),
            ...filtered.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.055), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(.10))),
              child: Row(children: [
                const Icon(Icons.auto_awesome, color: Colors.white54, size: 17),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(entry[0], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(entry[1], style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ])),
              ]),
            )),
          ],
        ),
      ),
    );
  }
}


class HadithPage extends StatefulWidget {
  const HadithPage({super.key});
  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  String query = '';
  static const items = <List<String>>[
    ['إنما الأعمال بالنيات', 'صحيح البخاري، حديث 1؛ وصحيح مسلم، حديث 1907', 'الأعمال معتبرة بمقاصدها ونياتها.'],
    ['من كان يؤمن بالله واليوم الآخر فليقل خيرًا أو ليصمت', 'صحيح البخاري، حديث 6018؛ وصحيح مسلم، حديث 47', 'فيه الحث على حفظ اللسان وقول الخير.'],
    ['لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه', 'صحيح البخاري، حديث 13؛ وصحيح مسلم، حديث 45', 'يدعو الحديث إلى كمال المحبة والإيثار.'],
    ['من سلك طريقًا يلتمس فيه علمًا سهّل الله له به طريقًا إلى الجنة', 'صحيح مسلم، حديث 2699', 'فضل طلب العلم الشرعي والسعي إليه.'],
    ['خيركم من تعلم القرآن وعلمه', 'صحيح البخاري، حديث 5027', 'فضل تعلم القرآن وتعليمه للناس.'],
    ['الكلمة الطيبة صدقة', 'صحيح البخاري، حديث 2989؛ وصحيح مسلم، حديث 1009', 'الكلام الحسن من أبواب الصدقة.'],
    ['الطهور شطر الإيمان', 'صحيح مسلم، حديث 223', 'بيان فضل الطهارة ومكانتها.'],
    ['من لا يَرحم لا يُرحم', 'صحيح البخاري، حديث 5997؛ وصحيح مسلم، حديث 2318', 'الحث على الرحمة بالخلق.'],
    ['يسروا ولا تعسروا وبشروا ولا تنفروا', 'صحيح البخاري، حديث 69؛ وصحيح مسلم، حديث 1734', 'الدعوة إلى الرفق والتيسير.'],
    ['إن الله لا ينظر إلى صوركم وأموالكم ولكن ينظر إلى قلوبكم وأعمالكم', 'صحيح مسلم، حديث 2564', 'العبرة بصلاح القلب والعمل لا بالمظاهر.'],
    ['أحب الأعمال إلى الله أدومها وإن قل', 'صحيح البخاري، حديث 6464؛ وصحيح مسلم، حديث 783', 'المداومة على العمل الصالح ولو كان قليلًا.'],
    ['من كان في حاجة أخيه كان الله في حاجته', 'صحيح البخاري، حديث 2442؛ وصحيح مسلم، حديث 2580', 'فضل قضاء حوائج الناس وإعانتهم.'],
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = items.where((item) => item.any((part) => part.contains(query))).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(backgroundColor: const Color(0xFF080808), foregroundColor: Colors.white, title: const Text('الحديث النبوي')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('أحاديث مختارة من صحيحي البخاري ومسلم', style: TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              textDirection: TextDirection.rtl,
              onChanged: (value) => setState(() => query = value.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث في الحديث أو الشرح أو المصدر',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white.withOpacity(.06),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(.12))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(.12))),
              ),
            ),
            const SizedBox(height: 12),
            ...filtered.map((item) => awwabGlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('«${item[0]}»', style: const TextStyle(fontSize: 17, height: 1.8, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(item[1], style: const TextStyle(color: Colors.white60, fontSize: 11)),
              const SizedBox(height: 8),
              Text(item[2], style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)),
            ]))),
            if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('لا توجد نتائج', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54))),
          ],
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
  bool dailyReminderEnabled = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 20, minute: 0);

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
      dailyReminderEnabled = prefs.getBool('daily_reminder_enabled') ?? false;
      reminderTime = TimeOfDay(
        hour: prefs.getInt('daily_reminder_hour') ?? 20,
        minute: prefs.getInt('daily_reminder_minute') ?? 0,
      );
    });
  }

  Future<void> _toggle(String key, bool value) async {
    setState(() => values[key] = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_check_$key', value);
  }

  Future<void> _setDailyReminder(bool value) async {
    if (value) {
      final granted = await PrayerNotificationService.instance.requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('اسمح بالإشعارات من إعدادات الهاتف لتفعيل التذكير.')),
          );
        }
        return;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', value);
    if (value) {
      await PrayerNotificationService.instance.scheduleDailyReminder(
        hour: reminderTime.hour,
        minute: reminderTime.minute,
      );
    } else {
      await PrayerNotificationService.instance.cancelDailyReminder();
    }
    if (mounted) setState(() => dailyReminderEnabled = value);
  }

  Future<void> _chooseReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
      helpText: 'اختر موعد التذكير اليومي',
    );
    if (picked == null) return;
    setState(() => reminderTime = picked);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_reminder_hour', picked.hour);
    await prefs.setInt('daily_reminder_minute', picked.minute);
    if (dailyReminderEnabled) {
      await PrayerNotificationService.instance.scheduleDailyReminder(
        hour: picked.hour,
        minute: picked.minute,
      );
    }
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
            awwabGlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: dailyReminderEnabled,
                activeColor: Colors.white,
                title: const Text('تذكير يومي بالورد والذكر', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('إشعار يومي في الموعد الذي تختاره', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onChanged: _setDailyReminder,
              ),
              const Divider(color: Colors.white24),
              Row(children: [
                const Expanded(child: Text('موعد التذكير', style: TextStyle(fontSize: 13))),
                TextButton.icon(
                  onPressed: _chooseReminderTime,
                  icon: const Icon(Icons.schedule_rounded, size: 17),
                  label: Text(reminderTime.format(context)),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                ),
              ]),
            ])),
            const SizedBox(height: 14),
            const Text('متابعة إنجاز العبادات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            const Text('علّم ما أنجزته؛ تُحفظ المتابعة على جهازك. التذكير اليومي أعلاه إشعار فعلي، أما هذه القائمة فهي لتسجيل الإنجاز.', style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.6)),
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

class DailyWirdPage extends StatefulWidget {
  const DailyWirdPage({super.key});
  @override
  State<DailyWirdPage> createState() => _DailyWirdPageState();
}

class _DailyWirdPageState extends State<DailyWirdPage> {
  static const goals = [2, 4, 6, 10, 20];
  int goal = 4;
  int completed = 0;
  String todayKey = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _dateKey() {
    final now = DateTime.now();
    return now.year.toString() + '-' + now.month.toString().padLeft(2, '0') + '-' + now.day.toString().padLeft(2, '0');
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final date = _dateKey();
    final savedDate = prefs.getString('wird_date') ?? '';
    if (savedDate != date) {
      await prefs.setString('wird_date', date);
      await prefs.setInt('wird_completed', 0);
    }
    if (!mounted) return;
    setState(() {
      todayKey = date;
      goal = goals.contains(prefs.getInt('wird_goal')) ? prefs.getInt('wird_goal')! : 4;
      completed = savedDate == date ? (prefs.getInt('wird_completed') ?? 0) : 0;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wird_date', todayKey);
    await prefs.setInt('wird_goal', goal);
    await prefs.setInt('wird_completed', completed);
  }

  @override
  Widget build(BuildContext context) {
    final progress = goal == 0 ? 0.0 : (completed / goal).clamp(0.0, 1.0);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(backgroundColor: const Color(0xFF080808), foregroundColor: Colors.white, title: const Text('الورد القرآني اليومي')),
        body: ListView(padding: const EdgeInsets.all(18), children: [
          awwabGlassCard(child: Column(children: [
            const Text('هدفك اليومي من صفحات المصحف', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: goal,
              dropdownColor: const Color(0xFF202020),
              decoration: InputDecoration(filled: true, fillColor: Colors.white.withOpacity(.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
              items: goals.map((v) => DropdownMenuItem(value: v, child: Text(v.toString() + ' صفحات'))).toList(),
              onChanged: (v) async { if (v == null) return; setState(() => goal = v); await _save(); },
            ),
            const SizedBox(height: 22),
            SizedBox(width: 170, height: 170, child: Stack(alignment: Alignment.center, children: [
              SizedBox.expand(child: CircularProgressIndicator(value: progress, strokeWidth: 10, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text(completed.toString(), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700)),
                Text('من ' + goal.toString() + ' صفحات', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ]),
            ])),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: completed > 0 ? () async { setState(() => completed--); await _save(); } : null,
                icon: const Icon(Icons.remove), label: const Text('تقليل'),
              )),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.icon(
                onPressed: () async { setState(() => completed++); await _save(); },
                icon: const Icon(Icons.add), label: const Text('أتممت صفحة'),
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              )),
            ]),
            const SizedBox(height: 10),
            Text(progress >= 1 ? 'أحسنت! أتممت وردك اليوم.' : 'باقي ' + (goal - completed).toString() + ' صفحات لإتمام هدفك.', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          const SizedBox(height: 12),
          const Text('يُعاد عداد الإنجاز تلقائيًا مع بداية يوم جديد، ويظل هدف الصفحات محفوظًا.', style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.6)),
        ]),
      ),
    );
  }
}

class WorshipTrackerPage extends StatefulWidget {
  const WorshipTrackerPage({super.key});
  @override
  State<WorshipTrackerPage> createState() => _WorshipTrackerPageState();
}

class _WorshipTrackerPageState extends State<WorshipTrackerPage> {
  static const items = [
    'صلاة الفجر', 'صلاة الظهر', 'صلاة العصر', 'صلاة المغرب', 'صلاة العشاء',
    'السنن الرواتب', 'صلاة الضحى', 'صلاة الوتر', 'أذكار الصباح', 'أذكار المساء',
    'ورد القرآن', 'صيام تطوع',
  ];
  final Map<String, bool> done = {for (final item in items) item: false};
  String date = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _today() {
    final n = DateTime.now();
    return n.year.toString() + '-' + n.month.toString().padLeft(2, '0') + '-' + n.day.toString().padLeft(2, '0');
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    if (!mounted) return;
    setState(() {
      date = today;
      for (final item in items) {
        done[item] = prefs.getString('worship_date') == today ? prefs.getBool('worship_$item') ?? false : false;
      }
    });
    if (prefs.getString('worship_date') != today) {
      await prefs.setString('worship_date', today);
      for (final item in items) {
        await prefs.setBool('worship_$item', false);
      }
    }
  }

  Future<void> _toggle(String item, bool value) async {
    setState(() => done[item] = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('worship_date', date);
    await prefs.setBool('worship_$item', value);
  }

  @override
  Widget build(BuildContext context) {
    final count = done.values.where((v) => v).length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(backgroundColor: const Color(0xFF080808), foregroundColor: Colors.white, title: const Text('متابعة العبادات')),
        body: ListView(padding: const EdgeInsets.all(18), children: [
          awwabGlassCard(child: Row(children: [
            const Expanded(child: Text('إنجاز اليوم', style: TextStyle(fontWeight: FontWeight.w700))),
            Text(count.toString() + ' / ' + items.length.toString(), style: const TextStyle(color: Colors.white70, fontFeatures: [ui.FontFeature.tabularFigures()])),
          ])),
          const SizedBox(height: 12),
          ...items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 7),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(.1))),
            child: CheckboxListTile(
              value: done[item] ?? false,
              onChanged: (value) => _toggle(item, value ?? false),
              activeColor: Colors.white,
              checkColor: Colors.black,
              title: Text(item, style: const TextStyle(fontSize: 13)),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
          )),
          const SizedBox(height: 8),
          const Text('هذه أداة متابعة شخصية وليست حكمًا على قبول العبادة، وتُصفّر القائمة تلقائيًا كل يوم.', style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.6)),
        ]),
      ),
    );
  }
}

Widget awwabGlassCard({required Widget child}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.065),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(.16), width: .8),
        ),
        child: child,
      ),
    ),
  );
}

class HijriCalendarPage extends StatelessWidget {
  const HijriCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    HijriCalendar.setLocal('ar');
    final today = HijriCalendar.now();
    final events = <List<String>>[
      ['1 محرم', 'رأس السنة الهجرية'],
      ['10 محرم', 'يوم عاشوراء'],
      ['12 ربيع الأول', 'المولد النبوي — يختلف الاحتفاء به بين المسلمين'],
      ['1 رمضان', 'بداية شهر رمضان'],
      ['27 رمضان', 'ليلة يُرجى أن توافق ليلة القدر، وليلة القدر تُلتمس في العشر الأواخر'],
      ['1 شوال', 'عيد الفطر'],
      ['9 ذو الحجة', 'يوم عرفة'],
      ['10 ذو الحجة', 'عيد الأضحى'],
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(
          backgroundColor: const Color(0xFF080808),
          foregroundColor: Colors.white,
          title: const Text('التقويم الهجري'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            awwabGlassCard(child: Column(children: [
              const Icon(Icons.nightlight_round, size: 34, color: Colors.white70),
              const SizedBox(height: 12),
              Text(today.getDayName() + ' ' + today.hDay.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Text(today.getLongMonthName() + ' ' + today.hYear.toString() + ' هـ', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text('عدد أيام الشهر: ' + today.lengthOfMonth.toString(), style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 8),
              Text('الموافق ميلاديًا: ' + DateTime.now().day.toString().padLeft(2, '0') + '/' + DateTime.now().month.toString().padLeft(2, '0') + '/' + DateTime.now().year.toString(), style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ])),
            const SizedBox(height: 16),
            const Text('أهم المناسبات الإسلامية', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ...events.map((event) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(.1)),
              ),
              child: Row(children: [
                SizedBox(width: 105, child: Text(event[0], style: const TextStyle(color: Colors.white70, fontSize: 12))),
                Expanded(child: Text(event[1], style: const TextStyle(fontSize: 13))),
              ]),
            )),
            const SizedBox(height: 8),
            const Text('التاريخ محسوب وفق تقويم أم القرى، وقد يختلف يومًا عن الإعلان الرسمي في مصر تبعًا لرؤية الهلال.', style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.6)),
          ],
        ),
      ),
    );
  }
}

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});
  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  static const cities = <String, List<double>>{
    'الفيوم': [29.3084, 30.8428], 'القاهرة': [30.0444, 31.2357],
    'الجيزة': [30.0131, 31.2089], 'الإسكندرية': [31.2001, 29.9187],
    'طنطا': [30.7865, 31.0004], 'المنصورة': [31.0409, 31.3785],
    'أسيوط': [27.1809, 31.1837], 'الأقصر': [25.6872, 32.6396], 'أسوان': [24.0889, 32.8998],
  };
  String city = 'الفيوم';

  @override
  Widget build(BuildContext context) {
    final point = cities[city]!;
    final bearing = adhan.Qibla(adhan.Coordinates(point[0], point[1])).direction;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(
          backgroundColor: const Color(0xFF080808),
          foregroundColor: Colors.white,
          title: const Text('اتجاه القبلة'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            awwabGlassCard(child: Column(children: [
              const Text('اختر مدينتك لحساب اتجاه القبلة', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: city,
                dropdownColor: const Color(0xFF202020),
                underline: const SizedBox.shrink(),
                items: cities.keys.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                onChanged: (value) { if (value != null) setState(() => city = value); },
              ),
              const SizedBox(height: 20),
              Text(bearing.toStringAsFixed(1) + '° من الشمال', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ])),
            const SizedBox(height: 28),
            StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                final heading = snapshot.data?.heading;
                if (heading == null) {
                  return awwabGlassCard(child: const Column(children: [
                    Icon(Icons.explore_off_outlined, size: 42, color: Colors.white54),
                    SizedBox(height: 12),
                    Text('مستشعر البوصلة غير متاح', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 6),
                    Text('تأكد من وجود مستشعر اتجاه في هاتفك، وعاير البوصلة بتحريك الهاتف على شكل رقم 8.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.6)),
                  ]));
                }
                final angle = (bearing - heading) * math.pi / 180;
                return Column(children: [
                  Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.045),
                      border: Border.all(color: Colors.white.withOpacity(.22), width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.white.withOpacity(.035), blurRadius: 28, spreadRadius: 4)],
                    ),
                    child: Stack(alignment: Alignment.center, children: [
                      const Positioned(top: 13, child: Text('شمال', style: TextStyle(color: Colors.white70, fontSize: 12))),
                      const Positioned(bottom: 13, child: Text('جنوب', style: TextStyle(color: Colors.white54, fontSize: 12))),
                      const Positioned(left: 15, child: Text('غرب', style: TextStyle(color: Colors.white54, fontSize: 12))),
                      const Positioned(right: 15, child: Text('شرق', style: TextStyle(color: Colors.white54, fontSize: 12))),
                      Transform.rotate(
                        angle: angle,
                        child: const Icon(Icons.navigation_rounded, size: 94, color: Colors.white),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text('اتجاه الهاتف: ' + heading.toStringAsFixed(0) + '°', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 7),
                  const Text('حرّك الهاتف حتى يشير السهم إلى اتجاه القبلة.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PrayerCenterPage extends StatefulWidget {
  const PrayerCenterPage({super.key});
  @override
  State<PrayerCenterPage> createState() => _PrayerCenterPageState();
}

class _PrayerCenterPageState extends State<PrayerCenterPage> {
  static const cities = <String, List<double>>{
    'الفيوم': [29.3084, 30.8428], 'القاهرة': [30.0444, 31.2357],
    'الجيزة': [30.0131, 31.2089], 'الإسكندرية': [31.2001, 29.9187],
    'طنطا': [30.7865, 31.0004], 'المنصورة': [31.0409, 31.3785],
    'أسيوط': [27.1809, 31.1837], 'الأقصر': [25.6872, 32.6396], 'أسوان': [24.0889, 32.8998],
  };
  static const prayerNames = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
  String city = 'الفيوم';
  int beforeMinutes = 10;
  bool notificationsEnabled = false;
  final Map<String, bool> enabled = {for (final name in prayerNames) name: true};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      city = cities.containsKey(prefs.getString('prayer_city')) ? prefs.getString('prayer_city')! : 'الفيوم';
      beforeMinutes = prefs.getInt('prayer_before_minutes') ?? 10;
      notificationsEnabled = prefs.getBool('prayer_notifications_enabled') ?? false;
      for (final name in prayerNames) {
        enabled[name] = prefs.getBool('prayer_enabled_$name') ?? true;
      }
    });
    if (notificationsEnabled) {
      await _persistAndSchedule();
    }
  }

  Future<void> _persistAndSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prayer_city', city);
    await prefs.setInt('prayer_before_minutes', beforeMinutes);
    await prefs.setBool('prayer_notifications_enabled', notificationsEnabled);
    for (final name in prayerNames) {
      await prefs.setBool('prayer_enabled_$name', enabled[name] ?? false);
    }
    if (!notificationsEnabled) {
      await PrayerNotificationService.instance.cancelPrayerAlerts();
      return;
    }
    final granted = await PrayerNotificationService.instance.requestPermissions();
    if (!granted) {
      notificationsEnabled = false;
      await prefs.setBool('prayer_notifications_enabled', false);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم منح إذن الإشعارات؛ يمكنك تفعيله من إعدادات الهاتف ثم المحاولة مجددًا.')),
        );
      }
      return;
    }
    final point = cities[city]!;
    await PrayerNotificationService.instance.schedulePrayerAlerts(
      city: city,
      latitude: point[0],
      longitude: point[1],
      enabledPrayers: enabled,
      beforeMinutes: beforeMinutes,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث تنبيهات الصلاة للأيام السبعة القادمة.')),
      );
    }
  }

  String _time(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return hour.toString() + ':' + value.minute.toString().padLeft(2, '0') + (value.hour < 12 ? ' ص' : ' م');
  }

  @override
  Widget build(BuildContext context) {
    final point = cities[city]!;
    final params = adhan.CalculationMethod.egyptian.getParameters();
    params.madhab = adhan.Madhab.shafi;
    final times = adhan.PrayerTimes.today(adhan.Coordinates(point[0], point[1]), params);
    final prayerTimes = <String, DateTime>{
      'الفجر': times.fajr, 'الظهر': times.dhuhr, 'العصر': times.asr,
      'المغرب': times.maghrib, 'العشاء': times.isha,
    };
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(
          backgroundColor: const Color(0xFF080808),
          foregroundColor: Colors.white,
          title: const Text('مركز الصلاة'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            awwabGlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('المدينة', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: city,
                dropdownColor: const Color(0xFF202020),
                decoration: InputDecoration(
                  filled: true, fillColor: Colors.white.withOpacity(.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                items: cities.keys.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                onChanged: (value) async {
                  if (value == null) return;
                  setState(() => city = value);
                  await _persistAndSchedule();
                },
              ),
              const SizedBox(height: 12),
              ...prayerTimes.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(children: [
                  Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600))),
                  Text(_time(entry.value), style: const TextStyle(color: Colors.white70, fontFeatures: [ui.FontFeature.tabularFigures()])),
                ]),
              )),
            ])),
            const SizedBox(height: 14),
            awwabGlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: notificationsEnabled,
                activeColor: Colors.white,
                title: const Text('تفعيل تنبيهات الصلاة', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('إشعار عند دخول الوقت وإشعار قبله', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onChanged: (value) async {
                  setState(() => notificationsEnabled = value);
                  await _persistAndSchedule();
                },
              ),
              const Divider(color: Colors.white24),
              const Text('التنبيه قبل الصلاة', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: beforeMinutes,
                dropdownColor: const Color(0xFF202020),
                decoration: InputDecoration(
                  filled: true, fillColor: Colors.white.withOpacity(.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('بدون تنبيه مسبق')),
                  DropdownMenuItem(value: 5, child: Text('قبلها بـ 5 دقائق')),
                  DropdownMenuItem(value: 10, child: Text('قبلها بـ 10 دقائق')),
                  DropdownMenuItem(value: 15, child: Text('قبلها بـ 15 دقيقة')),
                ],
                onChanged: (value) async {
                  if (value == null) return;
                  setState(() => beforeMinutes = value);
                  await _persistAndSchedule();
                },
              ),
              const SizedBox(height: 10),
              const Text('اختيار الصلوات', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ...prayerNames.map((name) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: enabled[name] ?? false,
                activeColor: Colors.white,
                title: Text(name, style: const TextStyle(fontSize: 13)),
                onChanged: notificationsEnabled ? (value) async {
                  setState(() => enabled[name] = value);
                  await _persistAndSchedule();
                } : null,
              )),
              const SizedBox(height: 6),
              const Text('التنبيهات الحالية إشعارات قصيرة بصوت الإشعار الافتراضي للهاتف. تشغيل الأذان الكامل واختيار مؤذن مختلف لكل صلاة يحتاج إضافة ملفات صوتية مرخّصة واختبار تشغيلها في الخلفية، ولم أفعّله كميزة مكتملة بعد.', style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.6)),
            ])),
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
