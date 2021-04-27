import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tts_with_local_notif/NotificationPlugin.dart';

class LocalNotificationScreen extends StatefulWidget{
  @override
  LocalNotificationScreenState createState()=>LocalNotificationScreenState();

}
 class LocalNotificationScreenState extends State<LocalNotificationScreen>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationPlugin.setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("Local Notification Screen"),
      ),
      body: Center(
        child: FloatingActionButton.extended(
            onPressed:()async{
              await notificationPlugin.showNotification();
              await notificationPlugin.scheduleNotification();
            },
            label: Text("Send Notification")
        ),
      ),
    );
  }




  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
  }

  onNotificationClick(String payload) {
    print('Payload $payload');
  }

}