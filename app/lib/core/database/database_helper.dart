import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Helper class to manage SQLite database creation and lifecycle.
class DatabaseHelper {
  static const String _databaseName = 'flightdeck.db';
  static const int _databaseVersion = 1;

  /// Flights table name
  static const String tableFlights = 'flights';

  Database? _database;

  /// Returns the database instance, initializing it if not already open.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFlights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        airline_name TEXT NOT NULL,
        airline_code TEXT NOT NULL,
        flight_number TEXT,
        departure_airport TEXT,
        arrival_airport TEXT,
        departure_time TEXT,
        arrival_time TEXT,
        duration TEXT,
        stops INTEGER,
        price REAL,
        currency TEXT
      )
    ''');
  }

  /// Closes database connection if open.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
