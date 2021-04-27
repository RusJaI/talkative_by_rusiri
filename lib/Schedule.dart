import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'AddEvent.dart';
import 'DbConnect.dart';
import 'model/Event.dart';
class Schedule extends StatefulWidget {
  @override
  ScheduleState createState() => new ScheduleState();
}
class ScheduleState extends State<Schedule>{

  @override
  void initState() {
    super.initState();
    extractFuture();
  }

  DbConnect dbConnect=DbConnect.instance;
  String eventname="";
  var eventlist;
  var meetinglist;
  int year=DateTime.now().year;
  int month=DateTime.now().month;
  int day=DateTime.now().day;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Container(
               // height: MediaQuery.of(context).size.height * 0.65,
                child: TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: DateTime.now(),
                )
              ),
            ),
            Container(
              child: FloatingActionButton.extended(
                  onPressed:()=>{
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => AddEvent(year: year,month: month,day: day)
                        )
                    )
                  },
                  label: Text("Add Event"),
                heroTag: "btn3",
              ),
              padding: EdgeInsets.all(15.0),
            )
          ],
        )
    );
  }

  Future<void> extractFuture()async{
    eventlist= await dbConnect.fetchEvents();
    meetinglist=List<Event>(eventlist.length);
    try{
      int y=0;
      for(var x in eventlist) {
        setState(() {
          eventname = x.eventname+","+eventname;
          meetinglist[y]=x;
        });
        y++;
      }
    }catch(e){}
   // print("String "+eventname);
  }

}