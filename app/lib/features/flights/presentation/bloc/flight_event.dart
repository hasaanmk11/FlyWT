/// Available sorting options for flights.
enum FlightSortType {
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  departureTime('Departure Time'),
  duration('Duration'),
  airlineAscending('Airline A → Z'),
  airlineDescending('Airline Z → A'),
  durationAscending('Duration: Shortest First'),
  durationDescending('Duration: Longest First'),
  priceAscending('Price: Low to High'),
  priceDescending('Price: High to Low');

  final String label;
  const FlightSortType(this.label);
}

/// Base abstract class for all flight BLoC events.
abstract class FlightEvent {
  const FlightEvent();
}

/// Event dispatched to load flights (from SQLite cache or remote API).
class LoadFlights extends FlightEvent {
  const LoadFlights();
}

/// Event dispatched when the user selects a single airline filter.
class FilterFlightsByAirline extends FlightEvent {
  final String? airline;
  const FilterFlightsByAirline(this.airline);
}

/// Event dispatched when the user selects multiple airlines via checkboxes.
class FilterFlightsByMultipleAirlines extends FlightEvent {
  final Set<String> airlines;
  const FilterFlightsByMultipleAirlines(this.airlines);
}

/// Event dispatched when the user selects a sorting criteria.
class SortFlights extends FlightEvent {
  final FlightSortType sortType;
  const SortFlights(this.sortType);
}

/// Event dispatched to clear all active airline filters.
class ClearFlightFilter extends FlightEvent {
  const ClearFlightFilter();
}
