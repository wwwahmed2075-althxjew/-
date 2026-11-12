import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_text/mushaf_text.dart';
import 'package:mushaf_text/src/mushaf_layout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Madinah Mushaf contains all 6236 ayahs in order', () async {
    final ayahs = await Quran.ayahs();

    expect(ayahs, hasLength(6236));
    expect(ayahs.map((a) => a.id).toList(),
        List<int>.generate(6236, (i) => i + 1));

    for (var i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];
      expect(ayah.text.trim(), isNotEmpty,
          reason: 'Empty text at ayah ' + ayah.surah.toString() + ':' + ayah.number.toString());
      expect(ayah.surah, inInclusiveRange(1, 114));
      expect(ayah.number, greaterThan(0));
      expect(ayah.page, inInclusiveRange(1, 604));
      if (i > 0) {
        expect(ayah.page, greaterThanOrEqualTo(ayahs[i - 1].page),
            reason: 'Page order moved backwards at ayah ' + ayah.id.toString());
      }
    }
  });

  test('all 114 surahs have the expected ayah counts and page bounds', () async {
    final ayahs = await Quran.ayahs();
    expect(Quran.surahs, hasLength(114));

    for (final surah in Quran.surahs) {
      final verses = ayahs.where((a) => a.surah == surah.number).toList();
      expect(verses, hasLength(surah.ayahCount),
          reason: 'Wrong ayah count in ' + surah.nameArabic);
      expect(verses.map((a) => a.number).toList(),
          List<int>.generate(surah.ayahCount, (i) => i + 1),
          reason: 'Missing or duplicated ayah number in ' + surah.nameArabic);
      expect(verses.first.page, surah.startPage,
          reason: 'Wrong first page in ' + surah.nameArabic);
      expect(verses.last.page, surah.endPage,
          reason: 'Wrong last page in ' + surah.nameArabic);
    }
  });

  test('all 604 pages exist and match their complete line-token layout', () async {
    final ayahs = await Quran.ayahs();
    final byPage = <int, List<Ayah>>{};
    for (final ayah in ayahs) {
      byPage.putIfAbsent(ayah.page, () => <Ayah>[]).add(ayah);
    }

    final expectedPages = Set<int>.from(List<int>.generate(604, (i) => i + 1));
    expect(byPage.keys.toSet(), expectedPages,
        reason: 'A page is missing or an unexpected page number exists');

    final layout = await MushafLineIndex.load();
    expect(layout.keys.toSet(), expectedPages,
        reason: 'The printed-page layout is missing or has extra pages');

    for (var page = 1; page <= 604; page++) {
      final pageAyahs = byPage[page]!;
      expect(pageAyahs, isNotEmpty, reason: 'Page ' + page.toString() + ' has no ayahs');

      final lines = layout[page]!;
      expect(lines.lineCount, page <= 2 ? 8 : 15,
          reason: 'Unexpected line count on page ' + page.toString());

      final tokens = buildPageTokens(pageAyahs, toArabicNumerals);
      expect(lines.sliceTokens(tokens), isNotNull,
          reason: 'Page ' + page.toString() + ' token count does not match its line layout');
    }
  });
}
