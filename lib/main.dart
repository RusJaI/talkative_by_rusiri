import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tts_with_local_notif/LocalNotificationScreen.dart';

import 'NotificationPlugin.dart';
import 'Schedule.dart';

 void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
                color: Colors.indigo[300]
            ),
              tabs: [
                Tab(icon: Icon(Icons.calendar_today), text: "Calender"),
                Tab(icon: Icon(Icons.message), text: "Schedule"),
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


