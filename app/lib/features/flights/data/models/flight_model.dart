import 'package:flightdeck/features/flights/domain/entities/flight.dart';

/// Data model representing a Flight, with JSON parsing and SQLite mapping.
class FlightModel extends Flight {
  const FlightModel({
    super.id,
    required super.airlineName,
    required super.airlineCode,
    required super.flightNumber,
    required super.departureAirport,
    required super.arrivalAirport,
    required super.departureTime,
    required super.arrivalTime,
    required super.duration,
    required super.stops,
    super.returnAirlineName,
    super.returnAirlineCode,
    super.returnFlightNumber,
    super.returnDepartureAirport,
    super.returnArrivalAirport,
    super.returnDepartureTime,
    super.returnArrivalTime,
    super.returnDuration,
    super.returnStops,
    required super.price,
    required super.currency,
    super.isRefundable = false,
  });

  /// Safely parses a single FlightTrip from API response JSON.
  factory FlightModel.fromApiJson(
    Map<String, dynamic> tripJson, {
    String defaultCurrency = 'KWD',
  }) {
    // 1. Fare details
    final fareDetails = tripJson['FareDetails'] as Map<String, dynamic>?;
    final priceStr = fareDetails?['Total']?.toString() ?? '0.0';
    final price = double.tryParse(priceStr) ?? 0.0;
    final currency = fareDetails?['Currency']?.toString() ?? defaultCurrency;

    // 2. Outbound Journey (Journey 0)
    final journeys = tripJson['FlightJourneys'] as List?;
    final firstJourney = (journeys != null && journeys.isNotEmpty)
        ? journeys[0] as Map<String, dynamic>?
        : null;

    final firstItems = firstJourney?['FlightItems'] as List?;
    final firstItem = (firstItems != null && firstItems.isNotEmpty)
        ? firstItems[0] as Map<String, dynamic>?
        : null;

    final firstFlightInfo = firstItem?['FlightInfo'] as Map<String, dynamic>?;
    final firstNameMap = firstFlightInfo?['Name'] as Map<String, dynamic>?;
    final airlineName =
        firstNameMap?['en']?.toString() ?? 'Unknown Airline';
    final airlineCode = firstFlightInfo?['Code']?.toString() ?? 'FL';
    final flightNumber = firstFlightInfo?['Number']?.toString() ?? '';

    final firstDeparture = firstItem?['Departure'] as Map<String, dynamic>?;
    final firstArrival = firstItem?['Arrival'] as Map<String, dynamic>?;
    final departureAirport = firstDeparture?['AirportCode']?.toString() ?? '';
    final arrivalAirport = firstArrival?['AirportCode']?.toString() ?? '';
    final departureTime = firstDeparture?['DateTime']?.toString() ?? '';
    final arrivalTime = firstArrival?['DateTime']?.toString() ?? '';

    final firstJourneyTime =
        firstJourney?['JourneyTime'] as Map<String, dynamic>?;
    final firstHours = firstJourneyTime?['Hours'] as int? ?? 0;
    final firstMinutes = firstJourneyTime?['Minutes'] as int? ?? 0;
    final duration = '${firstHours}h ${firstMinutes}m';
    final stops = firstJourney?['TotalStops'] as int? ?? 0;

    // 3. Return Journey (Journey 1, if available)
    String? returnAirlineName;
    String? returnAirlineCode;
    String? returnFlightNumber;
    String? returnDepartureAirport;
    String? returnArrivalAirport;
    String? returnDepartureTime;
    String? returnArrivalTime;
    String? returnDuration;
    int? returnStops;

    if (journeys != null && journeys.length > 1) {
      final secondJourney = journeys[1] as Map<String, dynamic>?;
      final secondItems = secondJourney?['FlightItems'] as List?;
      final secondItem = (secondItems != null && secondItems.isNotEmpty)
          ? secondItems[0] as Map<String, dynamic>?
          : null;

      final secondFlightInfo =
          secondItem?['FlightInfo'] as Map<String, dynamic>?;
      final secondNameMap = secondFlightInfo?['Name'] as Map<String, dynamic>?;
      returnAirlineName =
          secondNameMap?['en']?.toString() ?? airlineName;
      returnAirlineCode = secondFlightInfo?['Code']?.toString() ?? airlineCode;
      returnFlightNumber = secondFlightInfo?['Number']?.toString() ?? '';

      final secondDeparture = secondItem?['Departure'] as Map<String, dynamic>?;
      final secondArrival = secondItem?['Arrival'] as Map<String, dynamic>?;
      returnDepartureAirport = secondDeparture?['AirportCode']?.toString();
      returnArrivalAirport = secondArrival?['AirportCode']?.toString();
      returnDepartureTime = secondDeparture?['DateTime']?.toString();
      returnArrivalTime = secondArrival?['DateTime']?.toString();

      final secondJourneyTime =
          secondJourney?['JourneyTime'] as Map<String, dynamic>?;
      final secondHours = secondJourneyTime?['Hours'] as int? ?? 0;
      final secondMinutes = secondJourneyTime?['Minutes'] as int? ?? 0;
      returnDuration = '${secondHours}h ${secondMinutes}m';
      returnStops = secondJourney?['TotalStops'] as int? ?? 0;
    }

    return FlightModel(
      airlineName: airlineName,
      airlineCode: airlineCode,
      flightNumber: flightNumber,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      duration: duration,
      stops: stops,
      returnAirlineName: returnAirlineName,
      returnAirlineCode: returnAirlineCode,
      returnFlightNumber: returnFlightNumber,
      returnDepartureAirport: returnDepartureAirport,
      returnArrivalAirport: returnArrivalAirport,
      returnDepartureTime: returnDepartureTime,
      returnArrivalTime: returnArrivalTime,
      returnDuration: returnDuration,
      returnStops: returnStops,
      price: price,
      currency: currency,
      isRefundable: false,
    );
  }

  /// Converts a SQLite database row Map into a FlightModel.
  factory FlightModel.fromDatabase(Map<String, dynamic> map) {
    return FlightModel(
      id: map['id'] as int?,
      airlineName: map['airline_name'] as String? ?? 'Unknown Airline',
      airlineCode: map['airline_code'] as String? ?? 'FL',
      flightNumber: map['flight_number'] as String? ?? '',
      departureAirport: map['departure_airport'] as String? ?? '',
      arrivalAirport: map['arrival_airport'] as String? ?? '',
      departureTime: map['departure_time'] as String? ?? '',
      arrivalTime: map['arrival_time'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      stops: map['stops'] as int? ?? 0,
      returnAirlineName: map['return_airline_name'] as String?,
      returnAirlineCode: map['return_airline_code'] as String?,
      returnFlightNumber: map['return_flight_number'] as String?,
      returnDepartureAirport: map['return_departure_airport'] as String?,
      returnArrivalAirport: map['return_arrival_airport'] as String?,
      returnDepartureTime: map['return_departure_time'] as String?,
      returnArrivalTime: map['return_arrival_time'] as String?,
      returnDuration: map['return_duration'] as String?,
      returnStops: map['return_stops'] as int?,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'KWD',
      isRefundable: (map['is_refundable'] as int? ?? 0) == 1,
    );
  }

  /// Converts this FlightModel into a Map for SQLite insertion.
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'airline_name': airlineName,
      'airline_code': airlineCode,
      'flight_number': flightNumber,
      'departure_airport': departureAirport,
      'arrival_airport': arrivalAirport,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'duration': duration,
      'stops': stops,
      'return_airline_name': returnAirlineName,
      'return_airline_code': returnAirlineCode,
      'return_flight_number': returnFlightNumber,
      'return_departure_airport': returnDepartureAirport,
      'return_arrival_airport': returnArrivalAirport,
      'return_departure_time': returnDepartureTime,
      'return_arrival_time': returnArrivalTime,
      'return_duration': returnDuration,
      'return_stops': returnStops,
      'price': price,
      'currency': currency,
      'is_refundable': isRefundable ? 1 : 0,
    };
  }
}
