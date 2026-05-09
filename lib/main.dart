import 'package:flutter/material.dart';
import 'package:tts_with_local_notif/LocalNotificationScreen.dart';
import 'NotificationPlugin.dart';
import 'Schedule.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notification plugin at startup
  await notificationPlugin.setOnNotificationClick(onNotificationClick);
  runApp(const MyApp());
}

void onNotificationClick(String payload) {
  debugPrint('Notification tapped with payload: $payload');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talkative',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Talkative"),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Colors.indigo[300],
            ),
            tabs: const [
              Tab(icon: Icon(Icons.calendar_today), text: "Calendar"),
              Tab(icon: Icon(Icons.message), text: "Schedule"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Schedule(),
            LocalNotificationScreen(),
          ],
        ),
      ),
    );
  }
}
