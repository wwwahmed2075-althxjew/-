import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_text/mushaf_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Complete Quran text and Madinah page data load locally', () async {
    final fatiha = await Quran.ayah(1, 1);
    expect(fatiha, isNotNull);
    expect(fatiha!.text, isNotEmpty);

    final kursi = await Quran.ayah(2, 255);
    expect(kursi, isNotNull);
    expect(kursi!.text, isNotEmpty);

    final page = await Quran.page(3);
    expect(page, isNotEmpty);
    expect(page.every((ayah) => ayah.text.isNotEmpty), isTrue);
  });

  test('Egyptian prayer calculation returns ordered daily times locally', () {
    final coordinates = adhan.Coordinates(29.3084, 30.8428);
    final parameters = adhan.CalculationMethod.egyptian.getParameters();
    final times = adhan.PrayerTimes.today(coordinates, parameters);
    expect(times.fajr.isBefore(times.sunrise), isTrue);
    expect(times.sunrise.isBefore(times.dhuhr), isTrue);
    expect(times.dhuhr.isBefore(times.asr), isTrue);
    expect(times.asr.isBefore(times.maghrib), isTrue);
    expect(times.maghrib.isBefore(times.isha), isTrue);
  });
}
