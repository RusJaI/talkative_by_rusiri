import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Event {
  static const tblEvents = 'events';
  static const col_id = 'id';
  static const col_event_name = 'eventname';
  static const col_from = 'fromdate';
  static const col_repeat='repeat';

  Event({this.id,this.eventname, this.fromdate,this.repeat});

  int id;
  String eventname;
  String fromdate;
  int repeat;

  Event.fromMap(Map<String, dynamic> map) {
    id = map[col_id];
    eventname=map[col_event_name];
    fromdate=map[col_from];
    repeat=map[col_repeat];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{col_event_name: eventname, col_from: fromdate,col_repeat:repeat};
    if (id != null) {
      map[col_id] = id;
    }
    return map;
  }

  static DateTime stringToDatetime(String str){
    var dateTimeObj = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(
        str + ":00.000000");
    print("Converted at model##"+dateTimeObj.toString());
    return dateTimeObj;
  }

  static String getStringValueofFrequency(int value){
    if(value==0){
      return "Repeat Daily";
    }else if(value==1){
      return "No Repeat-Only Once";
    }else if(value==5){
      return "Repeat for WeekDays";
    }else if(value==2){
      return "Repeat for WeekEnds";
    }
  }

  static int getIntValueofFrequency(String value){
    if(value=="Repeat Daily"){
      return 0;
    }else if(value=="No Repeat-Only Once"){
      return 1;
    }else if(value=="Repeat for WeekDays"){
      return 5;
    }else if(value=="Repeat for WeekEnds"){
      return 2;
    }else if(value=="All"){
      return -1;
    }
  }


}