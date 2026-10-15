import 'package:flightdeck/features/flights/data/datasources/flight_local_data_source.dart';
import 'package:flightdeck/features/flights/data/datasources/flight_remote_data_source.dart';
import 'package:flightdeck/features/flights/domain/entities/flight.dart';
import 'package:flightdeck/features/flights/domain/repositories/flight_repository.dart';

/// Implementation of FlightRepository coordinating cache-first data retrieval.
class FlightRepositoryImpl implements FlightRepository {
  final FlightRemoteDataSource remoteDataSource;
  final FlightLocalDataSource localDataSource;

  FlightRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
  );

  @override
  Future<List<Flight>> getFlights() async {
    // Check SQLite first. Once flights are cached,
    // the machine-test requirement says the API
    // should not be called on later launches.
    final localFlights = await localDataSource.getFlights();

    if (localFlights.isNotEmpty) {
      return localFlights;
    }

    // SQLite is empty, so this is effectively
    // the first successful application load.
    final remoteFlights = await remoteDataSource.getFlights();

    // Cache the flights into SQLite for all subsequent launches.
    await localDataSource.saveFlights(remoteFlights);

    return remoteFlights;
  }
}
