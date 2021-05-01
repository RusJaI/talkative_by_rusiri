import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show File, Platform;
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';
import 'package:tts_with_local_notif/DbConnect.dart';
import 'package:tts_with_local_notif/model/Event.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationPlugin {
  //

  DbConnect dbConnect=DbConnect.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final BehaviorSubject<ReceivedNotification>
  didReceivedLocalNotificationSubject =
  BehaviorSubject<ReceivedNotification>();
  var initializationSettings;

  /////tts//////////////////////
  FlutterTts flutterTts = FlutterTts();

/////////////////tts///////////////////
  NotificationPlugin._() {
    init();
  }
  init() async {
    tz.initializeTimeZones();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    initializePlatformSpecifics();
   ////tts flutter////////
    List<dynamic> languages = await flutterTts.getLanguages;
    await flutterTts.setLanguage("en-US");
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    /////tts flutter///////////////
  }
  initializePlatformSpecifics() {
    var initializationSettingsAndroid =
    AndroidInitializationSettings("@mipmap/logo_icon");
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification receivedNotification = ReceivedNotification(
            id: id, title: title, body: body, payload: payload);
        didReceivedLocalNotificationSubject.add(receivedNotification);
      },
    );
    initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  }
  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
      alert: false,
      badge: true,
      sound: true,
    );
  }
  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    didReceivedLocalNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }
  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
          onNotificationClick(payload);
        });
  }
  Future<void> showNotification() async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      "CHANNEL_DESCRIPTION",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
    NotificationDetails(android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      1,
      'Test Title',
      'Test Body', //null
      platformChannelSpecifics,
      payload: 'New Payload',
    );
  }

  Future<void> showWeeklyAtDayTime() async {
    var time = Time(21, 5, 0);
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 5',
      'CHANNEL_NAME 5',
      "CHANNEL_DESCRIPTION 5",
      importance: Importance.max,
      priority: Priority.high,
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
    NotificationDetails(android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      0,
      'Test Title at ${time.hour}:${time.minute}.${time.second}',
      'Test Body', //null
      Day.saturday,
      time,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }
  Future<void> repeatNotification() async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 3',
      'CHANNEL_NAME 3',
      "CHANNEL_DESCRIPTION 3",
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
    NotificationDetails(android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'Repeating Test Title',
      'Repeating Test Body',
      RepeatInterval.everyMinute,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }


  Future _speak(String speechtext) async{

    var result = await flutterTts.speak(speechtext);
    await flutterTts.awaitSpeakCompletion(true);
  }


  int channelno=0;

  Future<void> makeNotified() async {
    int i=0;
    int j=200;
    int k=400;
    List<Event> wholeschedule = await DbConnect.instance.fetchEvents();
    for (Event e in wholeschedule) {
      String strtime = e.fromdate;
      var scheduleNotificationDateTime = Event.stringToDatetime(strtime);
      print("#####" + scheduleNotificationDateTime.toString());
      DateTime currenttime = DateTime.now();
      if (currenttime.hour == scheduleNotificationDateTime.hour &&
          currenttime.minute == scheduleNotificationDateTime.minute) {
        channelno++;

        int freq = e.repeat;
        if (freq == 1) {
          scheduleNotification(e,j,channelno);
        }
        else if (freq == 0) {
          showDailyAtTime(e,i,channelno);
        }
        else if (freq == 5) {
          showWeekDaysOnly(e,k,channelno);
        }
      }
    }
  }


  Future<void> showDailyAtTime(Event e,int num,int chnlno) async {
    DateTime dt=Event.stringToDatetime(e.fromdate);
    DateTime currenttime=DateTime.now();
    DateTime scheduled=DateTime(currenttime.year,currenttime.month,currenttime.day,dt.hour,dt.minute);

    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID '+chnlno.toString(),
      'CHANNEL_NAME '+chnlno.toString(),
      "CHANNEL_DESCRIPTION "+chnlno.toString(),
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: "@mipmap/logo_icon",
      //sound: RawResourceAndroidNotificationSound('my_sound'),
      largeIcon: DrawableResourceAndroidBitmap("@mipmap/logo_icon"),
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      //timeoutAfter: 10000,
      styleInformation: DefaultStyleInformation(true, true),

    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
    NotificationDetails(android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    /*await flutterLocalNotificationsPlugin.showDailyAtTime(
      chnlno,
      e.eventname,
      dt.hour.toString()+":"+dt.minute.toString(), //null
      Time(dt.hour,dt.minute,DateTime.now().second),
      platformChannelSpecifics,
      payload: 'Talkative is here!',
    );*/

    await flutterLocalNotificationsPlugin.schedule(
        chnlno,
        e.eventname,
        dt.hour.toString()+":"+dt.minute.toString(),
        scheduled,
        platformChannelSpecifics,
        payload: 'Talkative is Here!',
        androidAllowWhileIdle: true
    );
    _speak(e.eventname);
  }

  Future<void> scheduleNotification(Event e,int num,int chnlno) async {

        String strtime = e.fromdate;
        var scheduleNotificationDateTime = Event.stringToDatetime(strtime);
        print("##once###" + scheduleNotificationDateTime.toString());

        DateTime currenttime = DateTime.now();
        if (currenttime.year == scheduleNotificationDateTime.year &&
            currenttime.month == scheduleNotificationDateTime.month &&
            currenttime.day == scheduleNotificationDateTime.day) {
        print("if passesd in once ");
        var androidChannelSpecifics = AndroidNotificationDetails(
          'CHANNEL_ID '+chnlno.toString(),
          'CHANNEL_NAME '+chnlno.toString(),
          "CHANNEL_DESCRIPTION "+chnlno.toString(),
          icon: "@mipmap/logo_icon",
          //sound: RawResourceAndroidNotificationSound('my_sound'),
          largeIcon: DrawableResourceAndroidBitmap("@mipmap/logo_icon"),
          enableLights: true,
          color: const Color.fromARGB(255, 255, 0, 0),
          ledColor: const Color.fromARGB(255, 255, 0, 0),
          ledOnMs: 1000,
          ledOffMs: 500,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          //timeoutAfter: 10000,
          styleInformation: DefaultStyleInformation(true, true),
        );
        var iosChannelSpecifics = IOSNotificationDetails(
          sound: 'my_sound.aiff',
        );
        var platformChannelSpecifics = NotificationDetails(
          android: androidChannelSpecifics,
          iOS: iosChannelSpecifics,
        );

          await flutterLocalNotificationsPlugin.schedule(
            chnlno,
            e.eventname,
            e.fromdate,
            scheduleNotificationDateTime,
            platformChannelSpecifics,
            payload: 'Talkative is Here!',
            androidAllowWhileIdle: true
          );

          _speak(e.eventname);

          dbConnect.deleteEvent(e.id);

        }

  }

  Future<void> showWeekDaysOnly(Event e,int num,int chnlno) async {
    DateTime currenttime = DateTime.now();
    if (currenttime.weekday==1||currenttime.weekday==2||currenttime.weekday==3||currenttime.weekday==4||currenttime.weekday==5) {
      String strtime = e.fromdate;
      var scheduleNotificationDateTime = Event.stringToDatetime(strtime);
      DateTime scheduled=DateTime(currenttime.year,currenttime.month,currenttime.day,scheduleNotificationDateTime.hour,scheduleNotificationDateTime.minute);
      print("#####" + scheduleNotificationDateTime.toString());
      var androidChannelSpecifics = AndroidNotificationDetails(
        'CHANNEL_ID '+chnlno.toString(),
        'CHANNEL_NAME '+chnlno.toString(),
        "CHANNEL_DESCRIPTION "+chnlno.toString(),
        icon: "@mipmap/logo_icon",
        //sound: RawResourceAndroidNotificationSound('my_sound'),
        largeIcon: DrawableResourceAndroidBitmap("@mipmap/logo_icon"),
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        //timeoutAfter: 10000,
        styleInformation: DefaultStyleInformation(true, true),
      );
      var iosChannelSpecifics = IOSNotificationDetails(
        sound: 'my_sound.aiff',
      );
      var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics,
        iOS: iosChannelSpecifics,
      );

        await flutterLocalNotificationsPlugin.schedule(
          num++,
          e.eventname,
          scheduleNotificationDateTime.hour.toString()+":"+scheduleNotificationDateTime.minute.toString(),
          scheduled,
          platformChannelSpecifics,
          payload: 'Talkative is Here!',
          androidAllowWhileIdle: true
        );

        _speak(e.eventname);

      }

  }
  /*
   Future<void> scheduleNotification() async {

    var scheduleNotificationDateTime = DateTime.now().add(Duration(seconds: 5));
    print("#####"+scheduleNotificationDateTime.toString());
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 1',
      'CHANNEL_NAME 1',
      "CHANNEL_DESCRIPTION 1",
      icon: "@mipmap/logo_icon",
      //sound: RawResourceAndroidNotificationSound('my_sound'),
      largeIcon: DrawableResourceAndroidBitmap("@mipmap/logo_icon"),
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails(
      sound: 'my_sound.aiff',
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Test Title',
      'Test Body',
      scheduleNotificationDateTime,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }

  */
  Future<void> showNotificationWithAttachment() async {
    var attachmentPicturePath = await _downloadAndSaveFile(
        'https://via.placeholder.com/800x200', 'attachment_img.jpg');
    var iOSPlatformSpecifics = IOSNotificationDetails(
      attachments: [IOSNotificationAttachment(attachmentPicturePath)],
    );
    var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(attachmentPicturePath),
      contentTitle: '<b>Attached Image</b>',
      htmlFormatContentTitle: true,
      summaryText: 'Test Image',
      htmlFormatSummaryText: true,
    );
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL ID 2',
      'CHANNEL NAME 2',
      'CHANNEL DESCRIPTION 2',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation,
    );
    var notificationDetails =
    NotificationDetails(android: androidChannelSpecifics, iOS: iOSPlatformSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Title with attachment',
      'Body with Attachment',
      notificationDetails,
    );
  }
  _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await get(Uri(path: url));
    //await http.get(url);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
  Future<int> getPendingNotificationCount() async {
    List<PendingNotificationRequest> p =
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
  final String title;
  final String body;
  final String payload;
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}




/*
    Future<void> scheduleNotification() async {
    List<Event> wholeschedule = await DbConnect.instance.fetchEvents();
      for (Event e in wholeschedule) {
        String strtime = e.fromdate;
        var scheduleNotificationDateTime = Event.stringToDatetime(strtime);
        print("#####" + scheduleNotificationDateTime.toString());
        var androidChannelSpecifics = AndroidNotificationDetails(
          'CHANNEL_ID 1',
          'CHANNEL_NAME 1',
          "CHANNEL_DESCRIPTION 1",
          icon: "@mipmap/logo_icon",
          //sound: RawResourceAndroidNotificationSound('my_sound'),
          largeIcon: DrawableResourceAndroidBitmap("@mipmap/logo_icon"),
          enableLights: true,
          color: const Color.fromARGB(255, 255, 0, 0),
          ledColor: const Color.fromARGB(255, 255, 0, 0),
          ledOnMs: 1000,
          ledOffMs: 500,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          timeoutAfter: 10000,
          styleInformation: DefaultStyleInformation(true, true),
        );
        var iosChannelSpecifics = IOSNotificationDetails(
          sound: 'my_sound.aiff',
        );
        var platformChannelSpecifics = NotificationDetails(
          android: androidChannelSpecifics,
          iOS: iosChannelSpecifics,
        );

        DateTime currenttime = DateTime.now();
        if (currenttime.year == scheduleNotificationDateTime.year &&
            currenttime.month == scheduleNotificationDateTime.month &&
            currenttime.day == scheduleNotificationDateTime.day &&
            currenttime.hour == scheduleNotificationDateTime.hour &&
            currenttime.minute == scheduleNotificationDateTime.minute) {

          await flutterLocalNotificationsPlugin.schedule(
            0,
            e.eventname,
            e.fromdate,
            scheduleNotificationDateTime,
            platformChannelSpecifics,
            payload: 'Talkative is Here!',
          );
          _speak(e.eventname);

          if(e.repeat==1){
            dbConnect.deleteEvent(e.id);
          }
        }
      }
  }

  */