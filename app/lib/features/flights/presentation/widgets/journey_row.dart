import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flightdeck/core/theme/app_colors.dart';

/// Reusable widget rendering a single flight journey leg (outbound or return)
/// matching the FlyWT Figma ticket specification.
class JourneyRow extends StatelessWidget {
  final String airlineCode;
  final String airlineName;
  final String departureTime;
  final String departureAirport;
  final String arrivalTime;
  final String arrivalAirport;
  final String duration;
  final int stops;
  final String? transitAirport;

  const JourneyRow({
    super.key,
    required this.airlineCode,
    required this.airlineName,
    required this.departureTime,
    required this.departureAirport,
    required this.arrivalTime,
    required this.arrivalAirport,
    required this.duration,
    required this.stops,
    this.transitAirport,
  });

  @override
  Widget build(BuildContext context) {
    final depFormatted = _formatTime(departureTime);
    final arrFormatted = _formatTime(arrivalTime);
    final durationFormatted = _formatDuration(duration);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Airline Logo on the left
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: SvgPicture.network(
            'https://souqsafaraiweb.caxita.ca/AirlineIcons/$airlineCode.svg',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            placeholderBuilder: (context) => const Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.orange,
                ),
              ),
            ),
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.flight,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 14),

        // 2. Flight Journey Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Labels: Departure & Arrival
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Departure',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Text(
                    'Arrival',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Timings and Route Path
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Departure Time & Code
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        depFormatted,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryText,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        departureAirport,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),

                  // Route Line with Orange Dot, Dotted Line, and Orange Airplane
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Starting Orange Dot
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 2),

                              // Dotted Line
                              Expanded(
                                child: _buildDottedLine(),
                              ),

                              // Orange Airplane Icon
                              Transform.rotate(
                                angle: 1.5708,
                                child: const Icon(
                                  Icons.flight,
                                  color: AppColors.orange,
                                  size: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Transit Airport (if any) and Duration
                          if (transitAirport != null &&
                              transitAirport!.isNotEmpty) ...[
                            Text(
                              transitAirport!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                          Text(
                            durationFormatted,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Arrival Time & Code
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        arrFormatted,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryText,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        arrivalAirport,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDottedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 3.0;
        const dashSpace = 3.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count > 0 ? count : 1,
            (_) => Container(
              width: dashWidth,
              height: 1.5,
              color: AppColors.divider,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '00:00';
    final parsed = DateTime.tryParse(timeStr);
    if (parsed != null) {
      final hour = parsed.hour.toString().padLeft(2, '0');
      final minute = parsed.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return timeStr;
  }

  String _formatDuration(String durationStr) {
    // Converts "1h 50m" to "01H:50M" to match the Figma format
    final parts = durationStr.split(' ');
    int hours = 0;
    int minutes = 0;
    for (final part in parts) {
      if (part.endsWith('h')) {
        hours = int.tryParse(part.replaceAll('h', '')) ?? 0;
      } else if (part.endsWith('m')) {
        minutes = int.tryParse(part.replaceAll('m', '')) ?? 0;
      }
    }
    if (hours > 0 || minutes > 0) {
      return '${hours.toString().padLeft(2, '0')}H:${minutes.toString().padLeft(2, '0')}M';
    }
    return durationStr;
  }
}
