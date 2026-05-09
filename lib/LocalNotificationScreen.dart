import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:tts_with_local_notif/NotificationPlugin.dart';

class LocalNotificationScreen extends StatefulWidget {
  const LocalNotificationScreen({super.key});

  @override
  LocalNotificationScreenState createState() => LocalNotificationScreenState();
}

class LocalNotificationScreenState extends State<LocalNotificationScreen> {
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
    notificationPlugin.setListenerForLowerVersions(onNotificationInLowerVersions);
  }

  Future<void> _checkAndRequestPermission() async {
    final granted = await notificationPlugin.requestPermissions();
    if (mounted) {
      setState(() {
        _permissionGranted = granted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_permissionGranted && Platform.isAndroid)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.amber[100],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text(
                          'Notification permission is required to send reminders.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _checkAndRequestPermission,
                          child: const Text('Grant Permission'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            FloatingActionButton.extended(
              onPressed: () async {
                await notificationPlugin.showNotification();
                await notificationPlugin.scheduleNotification();
              },
              label: const Text("Send Notification"),
              icon: const Icon(Icons.notifications_active),
            ),
          ],
        ),
      ),
    );
  }

  void onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
    debugPrint('Notification received: ${receivedNotification.title}');
  }
}
