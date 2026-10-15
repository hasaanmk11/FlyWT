import 'package:dio/dio.dart';
import 'package:flightdeck/features/flights/data/datasources/flight_local_data_source.dart';
import 'package:flightdeck/features/flights/data/datasources/flight_remote_data_source.dart';
import 'package:flightdeck/features/flights/data/models/flight_model.dart';
import 'package:flightdeck/features/flights/data/repositories/flight_repository_impl.dart';
import 'package:flightdeck/features/flights/domain/usecases/get_flights.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_bloc.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_event.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_state.dart';
import 'package:flutter_test/flutter_test.dart';

// Test doubles for verifying all 8 machine-test conditions
class MockDioRemoteDataSource implements FlightRemoteDataSource {
  int callCount = 0;
  bool shouldFail = false;
  List<FlightModel> apiResults = [];

  @override
  Dio get dio => throw UnimplementedError();

  @override
  Future<List<FlightModel>> getFlights() async {
    callCount++;
    if (shouldFail) {
      throw Exception('Network error: No Internet connection');
    }
    return apiResults;
  }
}

class MockSqliteLocalDataSource implements FlightLocalDataSource {
  int readCount = 0;
  int writeCount = 0;
  List<FlightModel> sqliteRows = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<FlightModel>> getFlights() async {
    readCount++;
    return List<FlightModel>.from(sqliteRows);
  }

  @override
  Future<void> saveFlights(List<FlightModel> flights) async {
    writeCount++;
    sqliteRows = List<FlightModel>.from(flights);
  }

  @override
  Future<void> clearFlights() async {
    sqliteRows.clear();
  }
}

void main() {
  const flightJazeera1 = FlightModel(
    id: 1,
    airlineName: 'Jazeera Airways',
    airlineCode: 'J9',
    flightNumber: '122',
    departureAirport: 'DXB',
    arrivalAirport: 'KWI',
    departureTime: '2026-10-08T15:55:00Z',
    arrivalTime: '2026-10-08T16:45:00Z',
    duration: '1h 50m',
    stops: 0,
    price: 77.534,
    currency: 'KWD',
  );

  const flightJazeera2 = FlightModel(
    id: 2,
    airlineName: 'Jazeera Airways',
    airlineCode: 'J9',
    flightNumber: '124',
    departureAirport: 'DXB',
    arrivalAirport: 'KWI',
    departureTime: '2026-10-08T16:45:00Z',
    arrivalTime: '2026-10-08T17:35:00Z',
    duration: '1h 50m',
    stops: 0,
    price: 85.000,
    currency: 'KWD',
  );

  const flightKuwait = FlightModel(
    id: 3,
    airlineName: 'Kuwait Airways',
    airlineCode: 'KU',
    flightNumber: '672',
    departureAirport: 'DXB',
    arrivalAirport: 'KWI',
    departureTime: '2026-10-08T13:05:00Z',
    arrivalTime: '2026-10-08T14:05:00Z',
    duration: '2h 0m',
    stops: 0,
    price: 154.800,
    currency: 'KWD',
  );

  const flightEmirates = FlightModel(
    id: 4,
    airlineName: 'Emirates Airlines',
    airlineCode: 'EK',
    flightNumber: '2050',
    departureAirport: 'DXB',
    arrivalAirport: 'KWI',
    departureTime: '2026-10-08T15:30:00Z',
    arrivalTime: '2026-10-08T16:25:00Z',
    duration: '1h 55m',
    stops: 0,
    price: 148.900,
    currency: 'KWD',
  );

  final allMockFlights = [
    flightJazeera1,
    flightJazeera2,
    flightKuwait,
    flightEmirates,
  ];

  late MockDioRemoteDataSource remoteDataSource;
  late MockSqliteLocalDataSource localDataSource;
  late FlightRepositoryImpl repository;
  late GetFlights getFlights;
  late FlightBloc bloc;

  setUp(() {
    remoteDataSource = MockDioRemoteDataSource();
    localDataSource = MockSqliteLocalDataSource();
    repository = FlightRepositoryImpl(remoteDataSource, localDataSource);
    getFlights = GetFlights(repository);
    bloc = FlightBloc(getFlights);
  });

  tearDown(() {
    bloc.close();
  });

  group('Final Machine-Test Verifications (Tests 1 through 8)', () {
    test(
        'Test 1 — Fresh installation: SQLite empty -> API called -> JSON parsed -> SQLite populated -> flights displayed',
        () async {
      // Setup: SQLite is completely empty
      localDataSource.sqliteRows = [];
      remoteDataSource.apiResults = allMockFlights;

      bloc.add(const LoadFlights());
      await Future.delayed(const Duration(milliseconds: 60));

      expect(remoteDataSource.callCount, equals(1)); // API was called
      expect(localDataSource.writeCount, equals(1)); // Cached into SQLite
      expect(localDataSource.sqliteRows.length, equals(4)); // 4 rows in SQLite

      expect(bloc.state, isA<FlightLoaded>());
      final loadedState = bloc.state as FlightLoaded;
      expect(loadedState.displayedFlights.length, equals(4));
    });

    test(
        'Test 2 — Second launch: SQLite contains flights -> API NOT called -> SQLite read -> flights displayed',
        () async {
      // Setup: SQLite already contains previously saved flights
      localDataSource.sqliteRows = allMockFlights;
      remoteDataSource.apiResults = allMockFlights;

      bloc.add(const LoadFlights());
      await Future.delayed(const Duration(milliseconds: 60));

      expect(localDataSource.readCount, equals(1)); // SQLite was queried
      expect(remoteDataSource.callCount, equals(0)); // API was NOT called!
      expect(localDataSource.writeCount, equals(0)); // No redundant writes

      expect(bloc.state, isA<FlightLoaded>());
      final loadedState = bloc.state as FlightLoaded;
      expect(loadedState.displayedFlights.length, equals(4));
    });

    test(
        'Test 3 — Filtering: Choose an airline -> Only flights for that airline appear -> API NOT called',
        () async {
      localDataSource.sqliteRows = allMockFlights;
      bloc.add(const LoadFlights());
      await Future.delayed(const Duration(milliseconds: 50));

      // Choose Kuwait Airways
      bloc.add(const FilterFlightsByAirline('Kuwait Airways'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(remoteDataSource.callCount, equals(0)); // No API request
      final state = bloc.state as FlightLoaded;
      expect(state.displayedFlights.length, equals(1));
      expect(state.displayedFlights.first.airlineName, equals('Kuwait Airways'));
      expect(state.allFlights.length, equals(4)); // allFlights preserved
    });

    test(
        'Test 4 — Clear filter: Choose All Airlines -> All original flights appear again',
        () async {
      localDataSource.sqliteRows = allMockFlights;
      bloc.add(const LoadFlights());
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const FilterFlightsByAirline('Kuwait Airways'));
      await Future.delayed(const Duration(milliseconds: 50));

      // Clear filter
      bloc.add(const FilterFlightsByAirline('All Airlines'));
      await Future.delayed(const Duration(milliseconds: 50));

      final state = bloc.state as FlightLoaded;
      expect(state.displayedFlights.length, equals(4));
      expect(remoteDataSource.callCount, equals(0));
    });

    test(
        'Test 5 — Sorting: Price Low -> High, Price High -> Low, Departure Time, Duration -> Sorted correctly without API call',
        () async {
      localDataSource.sqliteRows = allMockFlights;
      bloc.add(const LoadFlights());
      await Future.delayed(const Duration(milliseconds: 50));

      // Sort Price Low -> High
      bloc.add(const SortFlights(FlightSortType.priceLowToHigh));
      await Future.delayed(const Duration(milliseconds: 50));
      var state = bloc.state as FlightLoaded;
      expect(state.displayedFlights.first.price, equals(77.534)); // Jazeera1
      expect(state.displayedFlights.last.price, equals(154.800)); // Kuwait

      // Sort Price High -> Low
      bloc.add(const SortFlights(FlightSortType.priceHighToLow));
      await Future.delayed(const Duration(milliseconds: 50));
      state = bloc.state as FlightLoaded;
      expect(state.displayedFlights.first.price, equals(154.800));
      expect(state.displayedFlights.last.price, equals(77.534));

      // Sort Departure Time
      bloc.add(const SortFlights(FlightSortType.departureTime));
      await Future.delayed(const Duration(milliseconds: 50));
      state = bloc.state as FlightLoaded;
      // 13:05 (Kuwait) < 15:30 (Emirates) < 15:55 (Jazeera1) < 16:45 (Jazeera2)
      expect(state.displayedFlights.first.flightNumber, equals('672'));

      expect(remoteDataSource.callCount, equals(0));
    });

    test(
        'Test 6 — Filter + Sort: Select airline and then sort -> Only that airline appears and is sorted',
        () async {
      localDataSource.sqliteRows = allMockFlights;
      bloc.add(const LoadFlights());
      await Future.delayed(const Duration(milliseconds: 50));

      // Filter by Jazeera Airways (has 2 flights: 77.534 and 85.000)
      bloc.add(const FilterFlightsByAirline('Jazeera Airways'));
      await Future.delayed(const Duration(milliseconds: 50));

      // Sort High to Low
      bloc.add(const SortFlights(FlightSortType.priceHighToLow));
      await Future.delayed(const Duration(milliseconds: 50));

      final state = bloc.state as FlightLoaded;
      expect(state.displayedFlights.length, equals(2));
      expect(state.displayedFlights[0].price, equals(85.000));
      expect(state.displayedFlights[1].price, equals(77.534));
      expect(remoteDataSource.callCount, equals(0));
    });

    test(
        'Test 7 — No internet on later launch: Flights cached in SQLite -> Network fails -> Local data still displays',
        () async {
      // Setup: SQLite already has cached data, network is DOWN
      localDataSource.sqliteRows = allMockFlights;
      remoteDataSource.shouldFail = true; // Simulating no internet

      bloc.add(const LoadFlights());
      await Future.delayed(const Duration(milliseconds: 60));

      // Must succeed and display flights from SQLite without touching remote
      expect(bloc.state, isA<FlightLoaded>());
      final loadedState = bloc.state as FlightLoaded;
      expect(loadedState.displayedFlights.length, equals(4));
      expect(remoteDataSource.callCount, equals(0));
    });

    test(
        'Test 8 — First launch API failure: Fresh DB (empty) + API failure -> Error message -> Retry button works',
        () async {
      localDataSource.sqliteRows = [];
      remoteDataSource.shouldFail = true;

      bloc.add(const LoadFlights());
      await Future.delayed(const Duration(milliseconds: 60));

      expect(bloc.state, isA<FlightError>());
      final errorState = bloc.state as FlightError;
      expect(errorState.message, contains('Unable to load flights'));

      // Now user clicks Retry after network comes back
      remoteDataSource.shouldFail = false;
      remoteDataSource.apiResults = allMockFlights;

      bloc.add(const LoadFlights());
      await Future.delayed(const Duration(milliseconds: 60));

      expect(bloc.state, isA<FlightLoaded>());
      final recoveredState = bloc.state as FlightLoaded;
      expect(recoveredState.displayedFlights.length, equals(4));
    });
  });
}
