import 'dart:core';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'AddEvent.dart';
import 'MyDay.dart';
import 'DbConnect.dart';
import 'model/Event.dart';
class Today extends StatefulWidget {
  @override
  TodayState createState() => new TodayState();
}
class TodayState extends State<Today>{

  @override
  void initState() {
    super.initState();
    extractFuture();
  }

  DbConnect dbConnect=DbConnect.instance;
  DateTime currtime=DateTime.now();
  String eventname="";
  var eventlist;
  var map =Map<DateTime,List<Event>>();


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Schedule : "+currtime.year.toString()+"-"+currtime.month.toString()+"-"+currtime.day.toString()),

        ),
        body:FutureBuilder(
          future: getdaytasks(),
          builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
            List<Event>evlist=snapshot.data;
            //for(Event ee in evlist) {
              return ListView.builder(
                padding: EdgeInsets.only(top: 25,bottom: 10),
                itemCount: evlist==null?0:evlist.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1.8,color: Colors.indigo[900]),
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.grey[200]
                    ),
                    margin:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
                    child: ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text(evlist[index].eventname.toString()),
                      subtitle: evlist[index].repeat==1?Text(evlist[index].fromdate.toString()):(evlist[index].repeat==5?Text("Weekly Reminder"):Text("Regular Reminder")),
                    ),
                  );
                },
              );
           // }
          },

        )
      )
    );
  }

  Future<void> extractFuture()async{
    eventlist= await dbConnect.fetchEvents();
    // print("String "+eventname);
  }

  Future<List<Event>> getdaytasks()async{
    eventlist= await dbConnect.fetchEvents();
    List<Event> daytasks=[];
    for(Event evnt in eventlist){
      DateTime frmdate=Event.stringToDatetime(evnt.fromdate);
      if(evnt.repeat==0||evnt.repeat==5||(frmdate.year==currtime.year&&frmdate.month==currtime.month&&frmdate.day==currtime.day)){
        daytasks.add(evnt);
        print("Added to daytask#"+evnt.eventname);
      }
    }
   return daytasks;

  }

}