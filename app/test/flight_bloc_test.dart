import 'package:flightdeck/features/flights/domain/entities/flight.dart';
import 'package:flightdeck/features/flights/domain/repositories/flight_repository.dart';
import 'package:flightdeck/features/flights/domain/usecases/get_flights.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_bloc.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_event.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_state.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRepository implements FlightRepository {
  bool shouldThrow = false;
  List<Flight> mockFlights = [];

  @override
  Future<List<Flight>> getFlights() async {
    if (shouldThrow) {
      throw Exception('Simulated API failure');
    }
    return mockFlights;
  }
}

void main() {
  const flightA = Flight(
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

  const flightB = Flight(
    airlineName: 'Kuwait Airways',
    airlineCode: 'KU',
    flightNumber: '672',
    departureAirport: 'DXB',
    arrivalAirport: 'KWI',
    departureTime: '2026-10-08T13:05:00Z',
    arrivalTime: '2026-10-08T14:05:00Z',
    duration: '2h 0m',
    stops: 0,
    price: 154.8,
    currency: 'KWD',
  );

  const flightC = Flight(
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

  late MockRepository repository;
  late GetFlights getFlights;
  late FlightBloc bloc;

  setUp(() {
    repository = MockRepository();
    getFlights = GetFlights(repository);
    bloc = FlightBloc(getFlights);
  });

  tearDown(() {
    bloc.close();
  });

  test('Initial state is FlightInitial', () {
    expect(bloc.state, isA<FlightInitial>());
  });

  test('LoadFlights emits [FlightLoading, FlightLoaded] when successful',
      () async {
    repository.mockFlights = [flightA, flightB, flightC];

    final expectedStates = [
      isA<FlightLoading>(),
      isA<FlightLoaded>().having((s) => s.allFlights.length, 'allFlights', 3),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const LoadFlights());
  });

  test('LoadFlights emits [FlightLoading, FlightError] on failure', () async {
    repository.shouldThrow = true;

    final expectedStates = [
      isA<FlightLoading>(),
      isA<FlightError>().having(
        (s) => s.message,
        'message',
        contains('Unable to load flights'),
      ),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const LoadFlights());
  });

  test('FilterFlightsByAirline filters displayedFlights without altering allFlights',
      () async {
    repository.mockFlights = [flightA, flightB, flightC];

    bloc.add(const LoadFlights());
    await Future.delayed(const Duration(milliseconds: 50));

    bloc.add(const FilterFlightsByAirline('Jazeera Airways'));
    await Future.delayed(const Duration(milliseconds: 50));

    final state = bloc.state as FlightLoaded;
    expect(state.allFlights.length, equals(3));
    expect(state.displayedFlights.length, equals(1));
    expect(state.displayedFlights.first.airlineName, equals('Jazeera Airways'));

    // Clear filter
    bloc.add(const ClearFlightFilter());
    await Future.delayed(const Duration(milliseconds: 50));

    final clearedState = bloc.state as FlightLoaded;
    expect(clearedState.displayedFlights.length, equals(3));
  });

  test('SortFlights sorts displayedFlights correctly by price low-to-high',
      () async {
    repository.mockFlights = [flightA, flightB, flightC];

    bloc.add(const LoadFlights());
    await Future.delayed(const Duration(milliseconds: 50));

    bloc.add(const SortFlights(FlightSortType.priceLowToHigh));
    await Future.delayed(const Duration(milliseconds: 50));

    final state = bloc.state as FlightLoaded;
    expect(state.displayedFlights.first.price, equals(77.534)); // flightC
    expect(state.displayedFlights.last.price, equals(154.8)); // flightB
  });

  test('Filtering and sorting work together', () async {
    repository.mockFlights = [
      flightA,
      flightB,
      flightC,
      const Flight(
        airlineName: 'Jazeera Airways',
        airlineCode: 'J9',
        flightNumber: '124',
        departureAirport: 'DXB',
        arrivalAirport: 'KWI',
        departureTime: '2026-10-08T16:45:00Z',
        arrivalTime: '2026-10-08T17:35:00Z',
        duration: '1h 50m',
        stops: 0,
        price: 99.0,
        currency: 'KWD',
      ),
    ];

    bloc.add(const LoadFlights());
    await Future.delayed(const Duration(milliseconds: 50));

    // Filter by Jazeera Airways
    bloc.add(const FilterFlightsByAirline('Jazeera Airways'));
    await Future.delayed(const Duration(milliseconds: 50));

    // Sort price high to low
    bloc.add(const SortFlights(FlightSortType.priceHighToLow));
    await Future.delayed(const Duration(milliseconds: 50));

    final state = bloc.state as FlightLoaded;
    expect(state.displayedFlights.length, equals(2));
    expect(state.displayedFlights.first.price, equals(99.0));
    expect(state.displayedFlights.last.price, equals(77.534));
  });
}
