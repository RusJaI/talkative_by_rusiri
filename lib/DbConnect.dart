import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'model/Event.dart';

class DbConnect {
  static const _databaseName = 'talkative.db';
  static const _databaseVersion = 1;

  DbConnect._();
  static final DbConnect instance = DbConnect._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _createDatabase();
    return _database!;
  }

  Future<Database> _createDatabase() async {
    final dataDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(dataDirectory.path, _databaseName);
    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreateDB,
    );
  }

  Future<void> _onCreateDB(Database db, int version) async {
    // repeat: 1 = once, 7 = weekly, 5 = weekdays, 2 = weekends, 0 = daily
    await db.execute('''
      CREATE TABLE ${Event.tblEvents} (
        ${Event.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Event.colEventName} TEXT NOT NULL,
        ${Event.colFrom} TEXT NOT NULL,
        ${Event.colTo} TEXT NOT NULL,
        ${Event.colRepeat} INTEGER NOT NULL
      )
    ''');
  }

  Future<int> addCalenderEvent(Event event) async {
    final db = await database;
    return await db.insert(Event.tblEvents, event.toMap());
  }

  Future<List<Event>> fetchEvents() async {
    final db = await database;
    final events = await db.query(Event.tblEvents);
    return events.isEmpty ? [] : events.map((x) => Event.fromMap(x)).toList();
  }

  Future<int> updateEvent(Event event) async {
    final db = await database;
    return await db.update(
      Event.tblEvents,
      event.toMap(),
      where: '${Event.colId}=?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete(
      Event.tblEvents,
      where: '${Event.colId}=?',
      whereArgs: [id],
    );
  }
}
