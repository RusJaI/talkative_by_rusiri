import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tts_with_local_notif/LocalNotificationScreen.dart';

import 'NotificationPlugin.dart';
import 'Schedule.dart';

void printHello() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  notificationPlugin.makeNotified();
}


 void main()async{
   WidgetsFlutterBinding.ensureInitialized();
   final int helloAlarmID = 0;
   await AndroidAlarmManager.initialize();
   runApp(MyApp());
   await AndroidAlarmManager.periodic(const Duration(seconds: 40), helloAlarmID, printHello);
  /* const oneMin = const Duration(seconds:40);
   new Timer.periodic(oneMin, (Timer t) => notificationPlugin.makeNotified());
   */
}

class MyApp extends StatelessWidget {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talkative',
      theme: ThemeData(
        //primarySwatch: Colors.yellow,
        primaryColor: Colors.blueGrey[700],
        accentColor: Colors.indigo[900],
      ),
      //home: LocalNotificationScreen(),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
            centerTitle: true,
            title: Text("Talkative"),

    //backgroundColor: Colors.transparent,
            bottom: TabBar(
    //  unselectedLabelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)
                ),
                color: Colors.indigo[900]
            ),
              tabs: [
                Tab(icon: Icon(Icons.add), text: "Add New"),
                Tab(icon: Icon(Icons.schedule), text: "Planned"),
                //Tab(icon: Icon(Icons.settings), text: "Settings")
              ],
              ),
            ),
          body:TabBarView(
              children: [
                Schedule(),
               LocalNotificationScreen()
               // Settings(),
            ],
          )
    )
    )
    );
  }
}


