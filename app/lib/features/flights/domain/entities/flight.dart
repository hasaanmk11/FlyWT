import 'package:flightdeck/core/constants/api_constants.dart';

/// Represents a flight entity in the domain layer.
/// Contains only business fields required by the UI and filters.
class Flight {
  final int? id;
  final String airlineName;
  final String airlineCode;
  final String flightNumber;
  final String departureAirport;
  final String arrivalAirport;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final int stops;
  final double price;
  final String currency;

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
    required this.price,
    required this.currency,
  });

  /// URL for the airline's SVG logo from CDN.
  String get airlineLogoUrl =>
      '${ApiConstants.airlineLogoBaseUrl}$airlineCode.svg';

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
