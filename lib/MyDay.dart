import 'dart:core';

import 'package:flutter/material.dart';
import 'DbConnect.dart';
import 'model/Event.dart';
class MyDay extends StatefulWidget {
  final DateTime focuseddate;
  List<Event>evlist;

  MyDay({Key key, @required this.focuseddate,this.evlist}) : super(key: key);
  @override
  MyDayState createState() => new MyDayState(focuseddate: focuseddate,evlist: evlist);
}
class MyDayState extends State<MyDay> {
  final DateTime focuseddate;
  List<Event>evlist;
  DbConnect dbConnect = DbConnect.instance;
  var evntlist;
  DateTime currtime=DateTime.now();

  MyDayState({Key key, @required this.focuseddate, this.evlist});


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Schedule : "+focuseddate.year.toString()+"-"+focuseddate.month.toString()+"-"+focuseddate.day.toString()),
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
        ),
        body: ListView.builder(
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
        ),
      ),
    );
  }


}