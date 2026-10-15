import 'package:flightdeck/features/flights/domain/entities/flight.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_event.dart';

/// Base abstract class for all flight BLoC states.
abstract class FlightState {
  const FlightState();
}

/// Initial state before flights are loaded.
class FlightInitial extends FlightState {
  const FlightInitial();
}

/// State while flights are being fetched from SQLite or API.
class FlightLoading extends FlightState {
  const FlightLoading();
}

/// State when flights have loaded successfully.
/// Maintains [allFlights] as the single source of truth,
/// while [displayedFlights] reflects current filters and sorting.
class FlightLoaded extends FlightState {
  final List<Flight> allFlights;
  final List<Flight> displayedFlights;
  final String? selectedAirline;
  final Set<String> selectedAirlines;
  final FlightSortType? sortType;

  const FlightLoaded({
    required this.allFlights,
    required this.displayedFlights,
    this.selectedAirline,
    this.selectedAirlines = const {},
    this.sortType,
  });

  /// Derives list of unique airline names from all flights for filter UI.
  List<String> get availableAirlines {
    final airlines = allFlights
        .map((flight) => flight.airlineName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
    airlines.sort();
    return airlines;
  }
}

/// State when an error occurs loading flights.
class FlightError extends FlightState {
  final String message;
  const FlightError(this.message);
}
