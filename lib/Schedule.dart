import 'dart:core';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'AddEvent.dart';
import 'MyDay.dart';
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
  List<Event>tosend=[];
  var eventlist;
  var meetinglist;
  var map =Map<DateTime,List<Event>>();

  DateTime _selectedDay=DateTime.now();
  DateTime _focusedDay=DateTime.now();
  var _selectedEvents;
  CalendarFormat _calendarFormat=CalendarFormat.month;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.20,
                  child: TableCalendar(
                    rowHeight:MediaQuery.of(context).size.height * 0.06 ,
                    firstDay: DateTime.utc(2016, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _selectedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay; // update `_focusedDay` here as well
                        _selectedEvents = _getEventsForDay(selectedDay);
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    eventLoader: (day) {
                      return _getEventsForDay(day);
                    },
                    onDayLongPressed: (day,time){
                      List<Event> listev=makelisttosend(day);
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => MyDay(focuseddate: day,evlist:listev)
                            )
                        );

                    },
                  )
                ),
              ),
              Container(
                child: FloatingActionButton.extended(
                    onPressed:()=>{
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => AddEvent(year: _focusedDay.year,month: _focusedDay.month,day: _focusedDay.day)
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
      ),
    );
  }

  Future<void> extractFuture()async{
    tosend.addAll(await dbConnect.fetchEventsWhenFreqencyGiven(0));
    tosend.addAll(await dbConnect.fetchEventsWhenFreqencyGiven(5));
    eventlist= await dbConnect.fetchEvents();

    //List<DateTime> datelist=[];
    List<Event> evlist=[];
    try{
      for(Event x in eventlist) {
        if(x.repeat==1){
        //  datelist.add(Event.stringToDatetime(x.fromdate));
          evlist.add(x);
        }
      }

      for (var item in evlist) {
        map.putIfAbsent(DateTime.parse(item.fromdate.substring(0,11)+"00:00:00.000z"), () => <Event>[]).add(item);
      }
     // print("!!!!!!"+map.entries.toString());

    }catch(e){}
   // print("String "+eventname);
  }

  List<Event> _getEventsForDay(DateTime day) {
    //print("#received day : "+day.toString());
    var x=map[day] ?? [];
    //print("################"+x.toString());
    return x;
  }

  List<Event> makelisttosend(DateTime dt){
     tosend.addAll(_getEventsForDay(dt));
     return tosend??[];
  }


}