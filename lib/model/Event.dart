import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Event {
  static const tblEvents = 'events';
  static const col_id = 'id';
  static const col_event_name = 'eventname';
  static const col_from = 'fromdate';
  static const col_to = 'todate';
  static const col_repeat='repeat';

  Event({this.id,this.eventname, this.fromdate, this.todate,this.repeat});

  int id;
  String eventname;
  String fromdate;
  String todate;
  int repeat;

  Event.fromMap(Map<String, dynamic> map) {
    id = map[col_id];
    eventname=map[col_event_name];
    fromdate=map[col_from];
    todate=map[col_to];
    repeat=map[col_repeat];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{col_event_name: eventname, col_from: fromdate,col_to:todate,col_repeat:repeat};
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
}