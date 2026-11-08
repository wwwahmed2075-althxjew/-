import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:quran_data_dart/quran.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/azkar_data.dart';
import 'data/surah_names.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QuranService.initialize();
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

  static const tabs = ['الرئيسية', 'القرآن', 'الأذكار', 'السبحة', 'الإعدادات'];

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
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
            child: AnimatedSwitcher(duration: const Duration(milliseconds: 220), child: pages[selectedTab]),
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
            _glassIcon(Icons.notifications_none_rounded, onTap: () {
              showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
                backgroundColor: const Color(0xFF202020),
                title: const Text('الإشعارات'),
                content: const Text('لا توجد إشعارات جديدة حاليًا.'),
                actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('حسنًا'))],
              ));
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
              showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
                backgroundColor: const Color(0xFF202020),
                title: const Text('مواقيت الصلاة'),
                content: const Text('ميزة مواقيت الصلاة والأذان لم تُفعّل بعد. لن نعرض مواعيد غير محسوبة أو غير موثوقة.'),
                actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('حسنًا'))],
              ));
            }),
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


  Widget _quranPage() {
    return ListView(
      key: const ValueKey('quran'),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
      children: [
        const Text('القرآن الكريم', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('اختر سورة لفتح المصحف وقراءة الآيات', style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 18),
        ...List.generate(awwabSurahNames.length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 7),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.045), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(.08))),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(.10),
                child: Text((index + 1).toString(), style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
              title: Text(awwabSurahNames[index], style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_left_rounded, color: Colors.white38, size: 20),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => QuranReaderPage(surahNumber: index + 1, surahName: awwabSurahNames[index]),
                ));
              },
            ),
          );
        }),
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
    return ListView(key: const ValueKey('settings'), padding: const EdgeInsets.all(20), children: [
      const Text('الإعدادات', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8), const Text('خصص تجربة آواب', style: TextStyle(color: Colors.white54)), const SizedBox(height: 20),
      _glassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('حجم الخط', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8), Text('معاينة النص', style: TextStyle(fontSize: 15 * textScale)), Slider(value: textScale, min: 0.85, max: 1.25, divisions: 8, activeColor: Colors.white, onChanged: (v) async { setState(() => textScale = v); final p = await SharedPreferences.getInstance(); await p.setDouble('text_scale', v); })])),
      const SizedBox(height: 12), _glassCard(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('المظهر', style: TextStyle(fontWeight: FontWeight.w600)), SizedBox(height: 8), Text('أسود زجاجي — هوية أحادية اللون بالأسود والأبيض', style: TextStyle(color: Colors.white60, fontSize: 12))])),
      const SizedBox(height: 12), _glassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('البيانات', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 8), const Text('عداد السبحة وتقدم الأذكار محفوظان على جهازك.', style: TextStyle(color: Colors.white60, fontSize: 12)), TextButton.icon(onPressed: () async { final p = await SharedPreferences.getInstance(); await p.setDouble('text_scale', 1.0); if (!mounted) return; setState(() => textScale = 1.0); }, icon: const Icon(Icons.restart_alt_rounded), label: const Text('إعادة ضبط حجم الخط'))]))
    ]);
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
  final int surahNumber;
  final String surahName;
  const QuranReaderPage({super.key, required this.surahNumber, required this.surahName});
  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  late Future<Surah> surahFuture;
  double fontSize = 27;
  int lastReadAyah = 1;

  @override
  void initState() {
    super.initState();
    surahFuture = QuranService.getSurah(widget.surahNumber);
    _loadLastRead();
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => lastReadAyah = prefs.getInt('last_ayah_${widget.surahNumber}') ?? 1);
  }

  Future<void> _saveLastRead(int ayah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_surah', widget.surahNumber);
    await prefs.setInt('last_ayah_${widget.surahNumber}', ayah);
    if (!mounted) return;
    setState(() => lastReadAyah = ayah);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ موضع القراءة على جهازك'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(
          backgroundColor: const Color(0xFF080808),
          foregroundColor: Colors.white,
          title: Text(widget.surahName),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'حفظ موضع القراءة',
              onPressed: () => _saveLastRead(lastReadAyah),
              icon: const Icon(Icons.bookmark_add_outlined),
            ),
          ],
        ),
        body: FutureBuilder<Surah>(
          future: surahFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('تعذر فتح بيانات المصحف المحلية. أعد تشغيل التطبيق أو حدّثه.', textAlign: TextAlign.center),
                ),
              );
            }
            final surah = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.07),
                          border: Border.all(color: Colors.white.withOpacity(.15)),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            Text('سُورَةُ ${surah.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 5),
                            Text('${surah.numberOfAyahs} آية • ${surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('حجم الخط', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                Expanded(
                                  child: Slider(
                                    value: fontSize,
                                    min: 21,
                                    max: 38,
                                    divisions: 17,
                                    activeColor: Colors.white,
                                    onChanged: (v) => setState(() => fontSize = v),
                                  ),
                                ),
                                Text(fontSize.round().toString(), style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: surah.ayat.length,
                    itemBuilder: (context, index) {
                      final ayah = surah.ayat[index];
                      final isLastRead = ayah.id == lastReadAyah;
                      return GestureDetector(
                        onTap: () => _saveLastRead(ayah.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          decoration: BoxDecoration(
                            color: isLastRead ? Colors.white.withOpacity(.105) : Colors.white.withOpacity(.045),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isLastRead ? Colors.white.withOpacity(.32) : Colors.white.withOpacity(.09)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(ayah.text,
                                textAlign: TextAlign.justify,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontSize: fontSize, height: 2.05, color: Colors.white, fontWeight: FontWeight.w400)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 27, height: 27,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white38)),
                                    child: Text(ayah.id.toString(), style: const TextStyle(fontSize: 10, color: Colors.white70)),
                                  ),
                                  const Spacer(),
                                  if (ayah.sajdah) const Text('۩ سجدة', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    tooltip: 'حفظ موضع القراءة',
                                    onPressed: () => _saveLastRead(ayah.id),
                                    icon: const Icon(Icons.bookmark_border_rounded, size: 19, color: Colors.white60),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.surahNumber > 1
                            ? () => Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (_) => QuranReaderPage(surahNumber: widget.surahNumber - 1, surahName: awwabSurahNames[widget.surahNumber - 2])))
                            : null,
                          icon: const Icon(Icons.chevron_right_rounded),
                          label: const Text('السورة السابقة'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.surahNumber < 114
                            ? () => Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (_) => QuranReaderPage(surahNumber: widget.surahNumber + 1, surahName: awwabSurahNames[widget.surahNumber])))
                            : null,
                          icon: const Icon(Icons.chevron_left_rounded),
                          label: const Text('السورة التالية'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
