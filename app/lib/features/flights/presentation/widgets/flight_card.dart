import 'package:flutter/material.dart';
import 'package:flightdeck/core/theme/app_colors.dart';
import 'package:flightdeck/features/flights/domain/entities/flight.dart';
import 'package:flightdeck/features/flights/presentation/widgets/journey_row.dart';

/// Flight ticket card displaying outbound & return legs with decorative ticket cutouts
/// and price/refundability footer matching the FlyWT Figma design.
class FlightCard extends StatelessWidget {
  final Flight flight;

  const FlightCard({
    super.key,
    required this.flight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // 1. Top Journeys Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                children: [
                  // Outbound Journey Row
                  JourneyRow(
                    airlineCode: flight.airlineCode,
                    airlineName: flight.airlineName,
                    departureTime: flight.departureTime,
                    departureAirport: flight.departureAirport,
                    arrivalTime: flight.arrivalTime,
                    arrivalAirport: flight.arrivalAirport,
                    duration: flight.duration,
                    stops: flight.stops,
                  ),

                  // Return Journey Row (if round-trip data exists)
                  if (flight.isRoundTrip) ...[
                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFFF1F5F9), height: 1),
                    const SizedBox(height: 14),
                    JourneyRow(
                      airlineCode: flight.returnAirlineCode ?? flight.airlineCode,
                      airlineName: flight.returnAirlineName ?? flight.airlineName,
                      departureTime: flight.returnDepartureTime ?? flight.arrivalTime,
                      departureAirport: flight.returnDepartureAirport ?? flight.arrivalAirport,
                      arrivalTime: flight.returnArrivalTime ?? flight.departureTime,
                      arrivalAirport: flight.returnArrivalAirport ?? flight.departureAirport,
                      duration: flight.returnDuration ?? flight.duration,
                      stops: flight.returnStops ?? flight.stops,
                    ),
                  ],
                ],
              ),
            ),

            // 2. Decorative Ticket Cutout with Dotted Divider
            _buildTicketDivider(),

            // 3. Card Footer: "Non Refundable" & "EGP / KWD 596.230"
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    flight.isRefundable ? 'Refundable' : 'Non Refundable',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${flight.currency} ',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        TextSpan(
                          text: flight.price.toStringAsFixed(3),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryText,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDivider() {
    return SizedBox(
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dotted divider in the middle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const dashWidth = 4.0;
                const dashSpace = 4.0;
                final count =
                    (constraints.maxWidth / (dashWidth + dashSpace)).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    count > 0 ? count : 1,
                    (_) => Container(
                      width: dashWidth,
                      height: 1,
                      color: AppColors.divider,
                    ),
                  ),
                );
              },
            ),
          ),

          // Left semicircular cutout
          Positioned(
            left: -8,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Right semicircular cutout
          Positioned(
            right: -8,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
