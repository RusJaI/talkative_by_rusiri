import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'model/Event.dart';

class DbConnect{
  static const _databaseName = 'talkative.db';
  static const _databaseVersion = 1;

  DbConnect._();
  static final DbConnect instance = DbConnect._();

  Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await createDatabase();
    return _database;
  }

  createDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, _databaseName);
    print(dbPath);
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: onCreateDB);
  }
  Future onCreateDB(Database db, int version) async {
    //create tables
    //repeat : 1 for only once,7 for 7 days , 5 for week days, 2 for weekends, 0 for regular
    await db.execute('''
        CREATE TABLE ${Event.tblEvents}(
        ${Event.col_id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Event.col_event_name} TEXT NOT NULL,
        ${Event.col_from} TEXT NOT NULL,
        ${Event.col_repeat} INTEGER NOT NULL

    )
    ''');
  }


  Future<int> addCalenderEvent(Event event) async {
    Database db = await database;
    return await db.insert(Event.tblEvents,event.toMap());
  }



  Future<List<Event>> fetchEvents() async {
    Database db = await database;
    List<Map> events = await db.query(Event.tblEvents);
    //print("events : "+events.toString());
    return events.length == 0
        ? []
        : events.map((x) => Event.fromMap(x)).toList();
  }

  Future<List<Event>> fetchEventsWhenFreqencyGiven(int frq) async {
    Database db = await database;
    String whereString = '${Event.col_repeat} = ?';
    List<dynamic> whereArguments = [frq];
    List<Map> events = await db.query(Event.tblEvents,where:whereString,whereArgs:whereArguments);
    // print("events : "+events.toString());
    return events.length == 0
        ? []
        : events.map((x) => Event.fromMap(x)).toList();
  }


  Future<int> updateEvent(Event event) async {
    Database db = await database;
    return await db.update(Event.tblEvents, event.toMap(),
        where: '${Event.col_id}=?', whereArgs: [event.id]);
  }

  Future<int> deleteEvent(int id) async {
    Database db = await database;
    return await db.delete(Event.tblEvents,
        where: '${Event.col_id}=?', whereArgs: [id]);
  }


}