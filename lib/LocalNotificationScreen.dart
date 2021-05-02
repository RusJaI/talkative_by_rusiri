import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tts_with_local_notif/DbConnect.dart';
import 'package:tts_with_local_notif/NotificationPlugin.dart';
import 'package:tts_with_local_notif/UpdateEvent.dart';
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
  String dropdownValue = "All";
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title:Text("Your Planned Tasks"),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10.0,top: 20.0,right: 5.0,bottom: 5.0),
              child: DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.check),
                iconSize: 34,
                elevation: 26,
                focusColor: Colors.lightBlue,
                style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 20.0
                ),
                underline: Container(
                  height: 2,
                  color: Colors.indigo[900],
                ),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                },
                items: <String>['All','No Repeat-Only Once', 'Repeat Daily', 'Repeat for WeekDays']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                        value,
                      style: TextStyle(color: Colors.indigo),
                    ),
                  );
                }).toList(),
              ),
            ),

            FutureBuilder(
              future: getEvents(),
              builder: (context, snapshot) {
                if(!snapshot.hasData){
                  return Center(
                    child: Text("No upcoming tasks scheduled!"),
                  );
                }else {
                  return Center(
                      child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          Event ev = snapshot.data[index];
                          String evDate = ev.fromdate;
                          String formattedDate = evDate.substring(0, evDate.length);
                          return Container(
                            height: 50,
                            color: Colors.lightBlue[index],
                            child: Center(
                                child: ListTile(
                                  title: Text('${ev.eventname}'),
                                  leading: Icon(Icons.edit),
                                  subtitle: ev.repeat==1?Text(ev.fromdate.toString()):(ev.repeat==5?Text("Weekly Reminder"):Text("Regular Reminder")),
                                  onTap: () {
                                    //navigate to a new page to edit or delete
                                    Navigator.push(context,
                                        MaterialPageRoute(
                                            builder: (context) => UpdateEvent(event: ev)
                                        )
                                    );
                                  },
                                )
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context,
                            int index) => const Divider(),
                      )
                  );
                }
              }
            ),
          ],
        ),
      ),
    );
  }



  Future<List<Event>>getEvents()async{
    int ddl=Event.getIntValueofFrequency(dropdownValue);
   if(ddl==-1){
     return await dbConnect.fetchEvents();
   }else{
     return await dbConnect.fetchEventsWhenFreqencyGiven(ddl);
   }
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
  }

  onNotificationClick(String payload) {
   // print('Payload $payload');
  }

}