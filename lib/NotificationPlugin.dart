import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show File, Platform;
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:tts_with_local_notif/DbConnect.dart';
import 'package:tts_with_local_notif/model/Event.dart';

class NotificationPlugin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Subject for iOS < 10 foreground notifications (legacy, kept for compatibility)
  final BehaviorSubject<ReceivedNotification> didReceivedLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();

  var initializationSettings;

  NotificationPlugin._() {
    init();
  }

  init() async {
    tz.initializeTimeZones();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializePlatformSpecifics();
  }

  initializePlatformSpecifics() {
    const initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/logo_icon");

    // DarwinInitializationSettings replaces IOSInitializationSettings
    final initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceivedLocalNotificationSubject.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
    );

    initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
  }

  /// Request notification permission on Android 13+ and iOS
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final iosImpl = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      return await iosImpl?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    } else if (Platform.isAndroid) {
      final androidImpl = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImpl?.requestNotificationsPermission() ?? false;
    }
    return false;
  }

  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    didReceivedLocalNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    // onSelectNotification is replaced by onDidReceiveNotificationResponse
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        final payload = notificationResponse.payload;
        if (payload != null) {
          onNotificationClick(payload);
        }
      },
    );
  }

  Future<void> showNotification() async {
    const androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      channelDescription: 'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    const iosChannelSpecifics = DarwinNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      1,
      'Test Title',
      'Test Body',
      platformChannelSpecifics,
      payload: 'New Payload',
    );
  }

  /// scheduleNotification now uses zonedSchedule (replaces deprecated .schedule())
  Future<void> scheduleNotification() async {
    List<Event> wholeSchedule = await DbConnect.instance.fetchEvents();

    for (Event e in wholeSchedule) {
      String strtime = e.fromdate ?? '';
      if (strtime.isEmpty) continue;

      final scheduleDateTime = Event().stringToDatetime(strtime);
      // Skip events in the past
      if (scheduleDateTime.isBefore(DateTime.now())) continue;

      final tzScheduleDateTime = tz.TZDateTime.from(scheduleDateTime, tz.local);

      const androidChannelSpecifics = AndroidNotificationDetails(
        'CHANNEL_ID_1',
        'Scheduled Notifications',
        channelDescription: 'Channel for scheduled event reminders',
        icon: "@mipmap/logo_icon",
        largeIcon: DrawableResourceAndroidBitmap("@mipmap/logo_icon"),
        enableLights: true,
        color: Color.fromARGB(255, 255, 0, 0),
        ledColor: Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        timeoutAfter: 5000,
        styleInformation: DefaultStyleInformation(true, true),
      );
      const iosChannelSpecifics = DarwinNotificationDetails(
        sound: 'my_sound.aiff',
      );
      const platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics,
        iOS: iosChannelSpecifics,
      );

      // zonedSchedule replaces the deprecated .schedule()
      await flutterLocalNotificationsPlugin.zonedSchedule(
        e.id ?? 0,
        e.eventname,
        e.fromdate,
        tzScheduleDateTime,
        platformChannelSpecifics,
        payload: 'Event Payload',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> showDailyAtTime() async {
    const time = Time(21, 3, 0);
    const androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID_4',
      'Daily Notifications',
      channelDescription: 'Channel for daily reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosChannelSpecifics = DarwinNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );

    // showDailyAtTime is deprecated; use zonedSchedule with matchDateTimeComponents
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Notification at ${time.hour}:${time.minute}',
      'Test Body',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'Daily Payload',
    );
  }

  Future<void> repeatNotification() async {
    const androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID_3',
      'Repeating Notifications',
      channelDescription: 'Channel for repeating reminders',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: DefaultStyleInformation(true, true),
    );
    const iosChannelSpecifics = DarwinNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'Repeating Test Title',
      'Repeating Test Body',
      RepeatInterval.everyMinute,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'Test Payload',
    );
  }

  Future<void> showNotificationWithAttachment() async {
    final attachmentPicturePath = await _downloadAndSaveFile(
        'https://via.placeholder.com/800x200', 'attachment_img.jpg');
    final iOSPlatformSpecifics = DarwinNotificationDetails(
      attachments: [DarwinNotificationAttachment(attachmentPicturePath)],
    );
    final bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(attachmentPicturePath),
      contentTitle: '<b>Attached Image</b>',
      htmlFormatContentTitle: true,
      summaryText: 'Test Image',
      htmlFormatSummaryText: true,
    );
    final androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID_2',
      'Attachment Notifications',
      channelDescription: 'Channel for attachment notifications',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation,
    );
    final notificationDetails = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iOSPlatformSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Title with attachment',
      'Body with Attachment',
      notificationDetails,
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<int> getPendingNotificationCount() async {
    final List<PendingNotificationRequest> p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return p.length;
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

NotificationPlugin notificationPlugin = NotificationPlugin._();

class ReceivedNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}
