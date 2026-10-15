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
    required super.price,
    required super.currency,
  });

  /// Safely parses a single FlightTrip from API response JSON.
  factory FlightModel.fromApiJson(
    Map<String, dynamic> tripJson, {
    String defaultCurrency = 'KWD',
  }) {
    // 1. Extract fare details
    final fareDetails = tripJson['FareDetails'] as Map<String, dynamic>?;
    final priceStr = fareDetails?['Total']?.toString() ?? '0.0';
    final price = double.tryParse(priceStr) ?? 0.0;
    final currency = fareDetails?['Currency']?.toString() ?? defaultCurrency;

    // 2. Extract primary journey & flight items
    final journeys = tripJson['FlightJourneys'] as List?;
    final firstJourney = (journeys != null && journeys.isNotEmpty)
        ? journeys[0] as Map<String, dynamic>?
        : null;

    final items = firstJourney?['FlightItems'] as List?;
    final firstItem = (items != null && items.isNotEmpty)
        ? items[0] as Map<String, dynamic>?
        : null;

    // 3. Airline and flight info
    final flightInfo = firstItem?['FlightInfo'] as Map<String, dynamic>?;
    final nameMap = flightInfo?['Name'] as Map<String, dynamic>?;
    final airlineName =
        nameMap?['en']?.toString() ?? 'Unknown Airline';
    final airlineCode = flightInfo?['Code']?.toString() ?? 'FL';
    final flightNumber = flightInfo?['Number']?.toString() ?? '';

    // 4. Departure and arrival airports & times
    final departure = firstItem?['Departure'] as Map<String, dynamic>?;
    final arrival = firstItem?['Arrival'] as Map<String, dynamic>?;
    final departureAirport = departure?['AirportCode']?.toString() ?? '';
    final arrivalAirport = arrival?['AirportCode']?.toString() ?? '';
    final departureTime = departure?['DateTime']?.toString() ?? '';
    final arrivalTime = arrival?['DateTime']?.toString() ?? '';

    // 5. Duration and stops
    final journeyTime = firstJourney?['JourneyTime'] as Map<String, dynamic>?;
    final hours = journeyTime?['Hours'] as int? ?? 0;
    final minutes = journeyTime?['Minutes'] as int? ?? 0;
    final duration = '${hours}h ${minutes}m';
    final stops = firstJourney?['TotalStops'] as int? ?? 0;

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
      price: price,
      currency: currency,
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
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'KWD',
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
      'price': price,
      'currency': currency,
    };
  }
}
