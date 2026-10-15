import 'package:flightdeck/core/constants/api_constants.dart';

/// Represents a flight entity in the domain layer.
/// Supports both one-way and round-trip journeys with outbound & return legs.
class Flight {
  final int? id;

  // Outbound Journey Leg
  final String airlineName;
  final String airlineCode;
  final String flightNumber;
  final String departureAirport;
  final String arrivalAirport;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final int stops;

  // Return Journey Leg (for round-trip searches)
  final String? returnAirlineName;
  final String? returnAirlineCode;
  final String? returnFlightNumber;
  final String? returnDepartureAirport;
  final String? returnArrivalAirport;
  final String? returnDepartureTime;
  final String? returnArrivalTime;
  final String? returnDuration;
  final int? returnStops;

  // Pricing & Conditions
  final double price;
  final String currency;
  final bool isRefundable;

  const Flight({
    this.id,
    required this.airlineName,
    required this.airlineCode,
    required this.flightNumber,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.stops,
    this.returnAirlineName,
    this.returnAirlineCode,
    this.returnFlightNumber,
    this.returnDepartureAirport,
    this.returnArrivalAirport,
    this.returnDepartureTime,
    this.returnArrivalTime,
    this.returnDuration,
    this.returnStops,
    required this.price,
    required this.currency,
    this.isRefundable = false,
  });

  /// True if this flight contains a return journey leg.
  bool get isRoundTrip =>
      returnDepartureAirport != null && returnDepartureAirport!.isNotEmpty;

  /// URL for the outbound airline's SVG logo from CDN.
  String get airlineLogoUrl =>
      '${ApiConstants.airlineLogoBaseUrl}$airlineCode.svg';

  /// URL for the return airline's SVG logo from CDN.
  String get returnAirlineLogoUrl =>
      '${ApiConstants.airlineLogoBaseUrl}${returnAirlineCode ?? airlineCode}.svg';

  /// Parsed DateTime for departure time comparison / sorting.
  DateTime get departureDateTime =>
      DateTime.tryParse(departureTime) ?? DateTime(2000);

  /// Approximate duration in minutes for duration sorting.
  int get durationInMinutes {
    final parts = duration.split(' ');
    int total = 0;
    for (final part in parts) {
      if (part.endsWith('h')) {
        total += (int.tryParse(part.replaceAll('h', '')) ?? 0) * 60;
      } else if (part.endsWith('m')) {
        total += int.tryParse(part.replaceAll('m', '')) ?? 0;
      }
    }
    return total;
  }
}
