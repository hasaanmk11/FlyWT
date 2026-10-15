import 'package:flightdeck/features/flights/data/datasources/flight_local_data_source.dart';
import 'package:flightdeck/features/flights/data/datasources/flight_remote_data_source.dart';
import 'package:flightdeck/features/flights/data/models/flight_model.dart';
import 'package:flightdeck/features/flights/data/repositories/flight_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple interview-friendly Fake implementations for testing without complex mock libraries
class FakeRemoteDataSource implements FlightRemoteDataSource {
  int callCount = 0;
  List<FlightModel> stubbedFlights = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<FlightModel>> getFlights() async {
    callCount++;
    return stubbedFlights;
  }
}

class FakeLocalDataSource implements FlightLocalDataSource {
  int getFlightsCallCount = 0;
  int saveFlightsCallCount = 0;
  List<FlightModel> storedFlights = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<FlightModel>> getFlights() async {
    getFlightsCallCount++;
    return storedFlights;
  }

  @override
  Future<void> saveFlights(List<FlightModel> flights) async {
    saveFlightsCallCount++;
    storedFlights = flights;
  }
}

void main() {
  const sampleFlight = FlightModel(
    airlineName: 'Emirates Airlines',
    airlineCode: 'EK',
    flightNumber: '2050',
    departureAirport: 'DXB',
    arrivalAirport: 'KWI',
    departureTime: '2026-10-08T15:30:00Z',
    arrivalTime: '2026-10-08T16:25:00Z',
    duration: '1h 55m',
    stops: 0,
    price: 148.9,
    currency: 'KWD',
  );

  test('First launch: SQLite empty -> calls API -> saves to SQLite -> returns data',
      () async {
    final fakeRemote = FakeRemoteDataSource()..stubbedFlights = [sampleFlight];
    final fakeLocal = FakeLocalDataSource()..storedFlights = [];
    final repository = FlightRepositoryImpl(fakeRemote, fakeLocal);

    final result = await repository.getFlights();

    expect(result.length, equals(1));
    expect(fakeLocal.getFlightsCallCount, equals(1));
    expect(fakeRemote.callCount, equals(1)); // API was called
    expect(fakeLocal.saveFlightsCallCount, equals(1)); // Saved to SQLite
    expect(fakeLocal.storedFlights.length, equals(1));
  });

  test('Second launch: SQLite has data -> does NOT call API -> returns SQLite data',
      () async {
    final fakeRemote = FakeRemoteDataSource()..stubbedFlights = [sampleFlight];
    final fakeLocal = FakeLocalDataSource()..storedFlights = [sampleFlight];
    final repository = FlightRepositoryImpl(fakeRemote, fakeLocal);

    final result = await repository.getFlights();

    expect(result.length, equals(1));
    expect(fakeLocal.getFlightsCallCount, equals(1));
    expect(fakeRemote.callCount, equals(0)); // API was NOT called!
    expect(fakeLocal.saveFlightsCallCount, equals(0));
  });
}
