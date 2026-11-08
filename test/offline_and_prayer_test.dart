import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_data_dart/quran.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Quran data opens locally without a network request', () async {
    await QuranService.initialize();
    final fatiha = await QuranService.getSurah(1);
    expect(fatiha.name, isNotEmpty);
    expect(fatiha.numberOfAyahs, 7);
    expect(fatiha.ayat.first.text, isNotEmpty);
    final kursi = await QuranService.getAyah(2, 255);
    expect(kursi.text, isNotEmpty);
  });

  test('Egyptian prayer calculation returns all daily times locally', () {
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
