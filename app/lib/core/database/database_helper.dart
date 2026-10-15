import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Helper class to manage SQLite database creation, schema, and lifecycle.
class DatabaseHelper {
  static const String _databaseName = 'flightdeck.db';
  static const int _databaseVersion = 2;

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
      onUpgrade: _onUpgrade,
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
        return_airline_name TEXT,
        return_airline_code TEXT,
        return_flight_number TEXT,
        return_departure_airport TEXT,
        return_arrival_airport TEXT,
        return_departure_time TEXT,
        return_arrival_time TEXT,
        return_duration TEXT,
        return_stops INTEGER,
        price REAL,
        currency TEXT,
        is_refundable INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS $tableFlights');
    await _onCreate(db, newVersion);
  }

  /// Closes database connection if open.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
