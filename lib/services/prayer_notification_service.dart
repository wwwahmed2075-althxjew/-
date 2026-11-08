import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class PrayerNotificationService {
  PrayerNotificationService._();
  static final PrayerNotificationService instance = PrayerNotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final notifications = await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
    return notifications ?? false;
  }

  Future<void> cancelPrayerAlerts() async {
    await initialize();
    for (var id = 3000; id < 3200; id++) {
      await _plugin.cancel(id);
    }
  }

  Future<void> schedulePrayerAlerts({
    required String city,
    required double latitude,
    required double longitude,
    required Map<String, bool> enabledPrayers,
    required int beforeMinutes,
  }) async {
    await initialize();
    await cancelPrayerAlerts();
    const names = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
    final coordinates = adhan.Coordinates(latitude, longitude);
    final params = adhan.CalculationMethod.egyptian.getParameters();
    params.madhab = adhan.Madhab.shafi;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'awwab_prayer_alerts',
        'تنبيهات مواقيت الصلاة',
        channelDescription: 'تنبيه عند دخول وقت الصلاة وقبله',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
    );
    final now = tz.TZDateTime.now(tz.local);
    for (var day = 0; day < 7; day++) {
      final date = now.add(Duration(days: day));
      final times = adhan.PrayerTimes(
        coordinates,
        adhan.DateComponents(date.year, date.month, date.day),
        params,
      );
      final values = <DateTime>[times.fajr, times.dhuhr, times.asr, times.maghrib, times.isha];
      for (var i = 0; i < names.length; i++) {
        final name = names[i];
        if (enabledPrayers[name] != true) continue;
        final prayerTime = tz.TZDateTime.from(values[i], tz.local);
        final baseId = 3000 + day * 20 + i * 2;
        if (prayerTime.isAfter(now)) {
          await _plugin.zonedSchedule(
            baseId,
            'حان الآن وقت صلاة $name',
            'حيّ على الصلاة — $city',
            prayerTime,
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
        if (beforeMinutes > 0) {
          final reminderTime = prayerTime.subtract(Duration(minutes: beforeMinutes));
          if (reminderTime.isAfter(now)) {
            await _plugin.zonedSchedule(
              baseId + 1,
              'اقترب موعد صلاة $name',
              'باقي $beforeMinutes دقائق على أذان $name',
              reminderTime,
              details,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );
          }
        }
      }
    }
  }
}
