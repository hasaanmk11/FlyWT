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
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Airline Header
            _buildAirlineHeader(),
            const SizedBox(height: 16),

            // 2. Journey Details (Departure -> Path -> Arrival)
            _buildJourneyRoute(),
            const SizedBox(height: 16),

            // 3. Divider
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 12),

            // 4. Pricing & Booking Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildAirlineHeader() {
    return Row(
      children: [
        // Airline SVG Logo with fallback icon
        Container(
          width: 44,
          height: 44,
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
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            placeholderBuilder: (BuildContext context) => const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.flight,
              color: Color(0xFF2563EB),
              size: 22,
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
              fontWeight: FontWeight.w600,
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Departure
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flight.departureAirport,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              depTimeFormatted,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),

        // Route path graphic
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  flight.duration,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
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
                        angle: 1.5708, // 90 degrees rightwards
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
                  flight.stops == 0 ? 'Direct' : '${flight.stops} Stop(s)',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Arrival
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              flight.arrivalAirport,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              arrTimeFormatted,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
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
              'Total Price',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  flight.price.toStringAsFixed(3),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  flight.currency,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Select',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
