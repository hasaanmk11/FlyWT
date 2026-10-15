import 'package:flightdeck/features/flights/domain/entities/flight.dart';
import 'package:flightdeck/features/flights/domain/repositories/flight_repository.dart';
import 'package:flightdeck/features/flights/domain/usecases/get_flights.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_bloc.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_event.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_state.dart';
import 'package:flutter_test/flutter_test.dart';

class CountingRepository implements FlightRepository {
  int fetchCount = 0;

  @override
  Future<List<Flight>> getFlights() async {
    fetchCount++;
    return const [
      Flight(
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
      ),
      Flight(
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
      ),
    ];
  }
}

void main() {
  test('Filtering operates purely on in-memory flights and does NOT call repository/API',
      () async {
    final repo = CountingRepository();
    final bloc = FlightBloc(GetFlights(repo));

    // 1. Initial load calls repository once
    bloc.add(const LoadFlights());
    await Future.delayed(const Duration(milliseconds: 50));
    expect(repo.fetchCount, equals(1));

    // 2. Filter by Emirates Airlines
    bloc.add(const FilterFlightsByAirline('Emirates Airlines'));
    await Future.delayed(const Duration(milliseconds: 50));

    // Repository fetch count MUST STILL BE 1
    expect(repo.fetchCount, equals(1));
    final state = bloc.state as FlightLoaded;
    expect(state.displayedFlights.length, equals(1));
    expect(state.displayedFlights.first.airlineName, equals('Emirates Airlines'));

    // 3. Clear filter back to All Airlines
    bloc.add(const FilterFlightsByAirline('All Airlines'));
    await Future.delayed(const Duration(milliseconds: 50));

    // Repository fetch count MUST STILL BE 1
    expect(repo.fetchCount, equals(1));
    final restoredState = bloc.state as FlightLoaded;
    expect(restoredState.displayedFlights.length, equals(2));

    await bloc.close();
  });
}
