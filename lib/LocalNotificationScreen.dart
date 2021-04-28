import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tts_with_local_notif/DbConnect.dart';
import 'package:tts_with_local_notif/NotificationPlugin.dart';
import 'package:tts_with_local_notif/model/Event.dart';

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
  DbConnect dbConnect=DbConnect.instance;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:Text("Your Planned Tasks"),
      ),
      body: FutureBuilder(
        future: dbConnect.fetchEvents(),
        builder: (context, snapshot) {
          return Center(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Event ev=snapshot.data[index];
                String evDate=ev.fromdate;
                String formattedDate=evDate.substring(0,evDate.length);
                return Container(
                  height: 50,
                  color: Colors.lightBlue[index],
                  child: Center(
                      child: ListTile(
                        title: Text('${ev.eventname}'),
                        leading: Icon(Icons.next_plan),
                        subtitle:Text(formattedDate) ,
                        onTap: (){
                          //navigate to a new page to edit or delete
                        },
                      )
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            )
          );
        }
      ),
    );
  }




  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
  }

  onNotificationClick(String payload) {
    print('Payload $payload');
  }

}