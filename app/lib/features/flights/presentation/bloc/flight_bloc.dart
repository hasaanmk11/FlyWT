import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flightdeck/features/flights/domain/entities/flight.dart';
import 'package:flightdeck/features/flights/domain/usecases/get_flights.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_event.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_state.dart';

/// BLoC that manages the flight listing, filtering, and sorting state.
class FlightBloc extends Bloc<FlightEvent, FlightState> {
  final GetFlights getFlights;

  FlightBloc(this.getFlights) : super(const FlightInitial()) {
    on<LoadFlights>(_onLoadFlights);
    on<FilterFlightsByAirline>(_onFilterFlightsByAirline);
    on<SortFlights>(_onSortFlights);
    on<ClearFlightFilter>(_onClearFlightFilter);
  }

  Future<void> _onLoadFlights(
    LoadFlights event,
    Emitter<FlightState> emit,
  ) async {
    emit(const FlightLoading());
    try {
      final flights = await getFlights();
      emit(
        FlightLoaded(
          allFlights: flights,
          displayedFlights: flights,
        ),
      );
    } catch (e) {
      emit(const FlightError('Unable to load flights. Please try again.'));
    }
  }

  void _onFilterFlightsByAirline(
    FilterFlightsByAirline event,
    Emitter<FlightState> emit,
  ) {
    if (state is! FlightLoaded) return;
    final currentState = state as FlightLoaded;

    // Normalizing selection: null or 'All Airlines' clears the filter
    final selectedAirline =
        (event.airline == null || event.airline == 'All Airlines')
            ? null
            : event.airline;

    // Filter and sort are combined seamlessly without mutating original data
    final updatedList = _applyFilterAndSort(
      currentState.allFlights,
      selectedAirline,
      currentState.sortType,
    );

    // Keep allFlights unchanged so filters can
    // always be cleared without querying the database again.
    emit(
      FlightLoaded(
        allFlights: currentState.allFlights,
        displayedFlights: updatedList,
        selectedAirline: selectedAirline,
        sortType: currentState.sortType,
      ),
    );
  }

  void _onSortFlights(
    SortFlights event,
    Emitter<FlightState> emit,
  ) {
    if (state is! FlightLoaded) return;
    final currentState = state as FlightLoaded;

    final updatedList = _applyFilterAndSort(
      currentState.allFlights,
      currentState.selectedAirline,
      event.sortType,
    );

    emit(
      FlightLoaded(
        allFlights: currentState.allFlights,
        displayedFlights: updatedList,
        selectedAirline: currentState.selectedAirline,
        sortType: event.sortType,
      ),
    );
  }

  void _onClearFlightFilter(
    ClearFlightFilter event,
    Emitter<FlightState> emit,
  ) {
    if (state is! FlightLoaded) return;
    final currentState = state as FlightLoaded;

    final updatedList = _applyFilterAndSort(
      currentState.allFlights,
      null,
      currentState.sortType,
    );

    emit(
      FlightLoaded(
        allFlights: currentState.allFlights,
        displayedFlights: updatedList,
        selectedAirline: null,
        sortType: currentState.sortType,
      ),
    );
  }

  /// Helper to apply both airline filtering and sorting in a single pipeline.
  List<Flight> _applyFilterAndSort(
    List<Flight> source,
    String? airline,
    FlightSortType? sortType,
  ) {
    // 1. Filter by airline
    List<Flight> result;
    if (airline != null && airline.isNotEmpty && airline != 'All Airlines') {
      result = source
          .where((f) => f.airlineName.toLowerCase() == airline.toLowerCase())
          .toList();
    } else {
      result = List<Flight>.from(source);
    }

    // 2. Sort by selected criteria
    if (sortType != null) {
      switch (sortType) {
        case FlightSortType.priceLowToHigh:
          result.sort((a, b) => a.price.compareTo(b.price));
          break;
        case FlightSortType.priceHighToLow:
          result.sort((a, b) => b.price.compareTo(a.price));
          break;
        case FlightSortType.departureTime:
          result.sort(
            (a, b) => a.departureDateTime.compareTo(b.departureDateTime),
          );
          break;
        case FlightSortType.duration:
          result.sort(
            (a, b) => a.durationInMinutes.compareTo(b.durationInMinutes),
          );
          break;
      }
    }

    return result;
  }
}
