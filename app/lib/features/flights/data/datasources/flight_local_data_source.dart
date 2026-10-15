import 'package:flightdeck/core/database/database_helper.dart';
import 'package:flightdeck/features/flights/data/models/flight_model.dart';
import 'package:sqflite/sqflite.dart';

/// Local data source responsible for caching and retrieving flights in SQLite.
class FlightLocalDataSource {
  final DatabaseHelper databaseHelper;

  FlightLocalDataSource(this.databaseHelper);

  /// Retrieves all cached flights from the SQLite flights table.
  Future<List<FlightModel>> getFlights() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableFlights,
      orderBy: 'id ASC',
    );

    return maps.map((map) => FlightModel.fromDatabase(map)).toList();
  }

  /// Saves a list of flights into SQLite.
  Future<void> saveFlights(List<FlightModel> flights) async {
    final db = await databaseHelper.database;

    // Insert flights in a batch because multiple rows
    // can be written efficiently in one database operation.
    final batch = db.batch();
    for (final flight in flights) {
      batch.insert(
        DatabaseHelper.tableFlights,
        flight.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Clears all flights from the local database.
  Future<void> clearFlights() async {
    final db = await databaseHelper.database;
    await db.delete(DatabaseHelper.tableFlights);
  }
}
