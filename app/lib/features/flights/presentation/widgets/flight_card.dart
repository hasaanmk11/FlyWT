import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flightdeck/features/flights/domain/entities/flight.dart';

/// Card widget presenting individual flight itinerary, airline branding,
/// timings, route path, and fare details.
class FlightCard extends StatelessWidget {
  final Flight flight;

  const FlightCard({
    super.key,
    required this.flight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            _showFlightDetailsSheet(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. Airline Header
                _buildAirlineHeader(),
                const SizedBox(height: 18),

                // 2. Journey Details (Departure -> Path -> Arrival)
                _buildJourneyRoute(),
                const SizedBox(height: 16),

                // 3. Subtle Divider
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 14),

                // 4. Pricing & Booking Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAirlineHeader() {
    return Row(
      children: [
        // Airline SVG Logo with network fallback
        Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: SvgPicture.network(
            flight.airlineLogoUrl,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            placeholderBuilder: (BuildContext context) => const Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.flight,
              color: Color(0xFF2563EB),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Airline Name and Flight Number
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                flight.airlineName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                flight.flightNumber.isNotEmpty
                    ? '${flight.airlineCode} • #${flight.flightNumber}'
                    : flight.airlineCode,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),

        // Stops Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: flight.stops == 0
                ? const Color(0xFFECFDF5)
                : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            flight.stops == 0 ? 'Non-stop' : '${flight.stops} Stop',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: flight.stops == 0
                  ? const Color(0xFF059669)
                  : const Color(0xFFD97706),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyRoute() {
    final depParsed = DateTime.tryParse(flight.departureTime);
    final arrParsed = DateTime.tryParse(flight.arrivalTime);

    final depTimeFormatted = depParsed != null
        ? '${depParsed.hour.toString().padLeft(2, '0')}:${depParsed.minute.toString().padLeft(2, '0')}'
        : flight.departureTime;

    final arrTimeFormatted = arrParsed != null
        ? '${arrParsed.hour.toString().padLeft(2, '0')}:${arrParsed.minute.toString().padLeft(2, '0')}'
        : flight.arrivalTime;

    final depDateFormatted = depParsed != null
        ? '${_monthAbbr(depParsed.month)} ${depParsed.day.toString().padLeft(2, '0')}'
        : '';

    final arrDateFormatted = arrParsed != null
        ? '${_monthAbbr(arrParsed.month)} ${arrParsed.day.toString().padLeft(2, '0')}'
        : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Departure Airport & Time
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flight.departureAirport,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              depTimeFormatted,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2563EB),
              ),
            ),
            if (depDateFormatted.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                depDateFormatted,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ],
        ),

        // Route path graphic
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    flight.duration,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Color(0xFFCBD5E1),
                        thickness: 1.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Transform.rotate(
                        angle: 1.5708, // 90 degrees rightward
                        child: const Icon(
                          Icons.flight,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Color(0xFFCBD5E1),
                        thickness: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  flight.stops == 0 ? 'Direct Flight' : '${flight.stops} Stop',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Arrival Airport & Time
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              flight.arrivalAirport,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              arrTimeFormatted,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2563EB),
              ),
            ),
            if (arrDateFormatted.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                arrDateFormatted,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Fare',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  flight.price.toStringAsFixed(3),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  flight.currency,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Select',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _showFlightDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    flight.airlineName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${flight.price.toStringAsFixed(3)} ${flight.currency}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Flight Number: ${flight.airlineCode} ${flight.flightNumber}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 8),
              Text(
                'Route: ${flight.departureAirport} ➔ ${flight.arrivalAirport}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: ${flight.duration}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 8),
              Text(
                'Departure: ${flight.departureTime}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 8),
              Text(
                'Arrival: ${flight.arrivalTime}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _monthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
