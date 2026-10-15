import 'package:flightdeck/features/flights/domain/entities/flight.dart';

/// Contract for the flight repository in the domain layer.
abstract class FlightRepository {
  /// Fetches flights, prioritizing SQLite cache over remote API.
  Future<List<Flight>> getFlights();
}
