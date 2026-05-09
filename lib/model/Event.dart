import 'package:intl/intl.dart';

class Event {
  static const tblEvents = 'events';
  static const colId = 'id';
  static const colEventName = 'eventname';
  static const colFrom = 'fromdate';
  static const colTo = 'todate';
  static const colRepeat = 'repeat';

  Event({this.id, this.eventname, this.fromdate, this.todate, this.repeat});

  int? id;
  String? eventname;
  String? fromdate;
  String? todate;
  int? repeat;

  Event.fromMap(Map<String, dynamic> map)
      : id = map[colId] as int?,
        eventname = map[colEventName] as String?,
        fromdate = map[colFrom] as String?,
        todate = map[colTo] as String?,
        repeat = map[colRepeat] as int?;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      colEventName: eventname,
      colFrom: fromdate,
      colTo: todate,
      colRepeat: repeat,
    };
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }

  DateTime stringToDatetime(String str) {
    // Handle both "yyyy-MM-dd HH:mm:ss.SSSSSS" and "yyyy-MM-dd HH:mm:ss" formats
    String normalized = str.contains('.')
        ? str.split('.').first       // strip microseconds
        : str.length == 16
            ? '$str:00'              // "yyyy-MM-dd HH:mm" → add seconds
            : str;
    return DateFormat("yyyy-MM-dd HH:mm:ss").parse(normalized);
  }
}
