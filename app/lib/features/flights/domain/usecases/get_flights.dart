import 'package:flightdeck/features/flights/domain/entities/flight.dart';
import 'package:flightdeck/features/flights/domain/repositories/flight_repository.dart';

/// Use case that encapsulates the business logic for fetching flights.
class GetFlights {
  final FlightRepository repository;

  GetFlights(this.repository);

  /// Executes the use case to retrieve flights.
  Future<List<Flight>> call() {
    return repository.getFlights();
  }
}
