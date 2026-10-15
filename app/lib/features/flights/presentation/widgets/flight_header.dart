import 'package:flutter/material.dart';
import 'package:flightdeck/core/theme/app_colors.dart';

/// Top header banner displaying flight route, date, travellers, and flight count.
class FlightHeader extends StatelessWidget {
  final String departureCode;
  final String arrivalCode;
  final String dateText;
  final String travellersText;
  final int flightCount;
  final VoidCallback? onBackPressed;
  final VoidCallback? onEditPressed;

  const FlightHeader({
    super.key,
    required this.departureCode,
    required this.arrivalCode,
    required this.dateText,
    this.travellersText = '2 Travellers',
    required this.flightCount,
    this.onBackPressed,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 16),
          child: Column(
            children: [
              // 1. Top Navigation Row: Back Arrow, Route, Edit Icon
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: onBackPressed ?? () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          departureCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              _buildDottedDash(),
                              const SizedBox(width: 4),
                              _buildDottedDash(),
                              const SizedBox(width: 4),
                              Transform.rotate(
                                angle: 1.5708,
                                child: const Icon(
                                  Icons.flight,
                                  color: AppColors.orange,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              _buildDottedDash(),
                              const SizedBox(width: 4),
                              _buildDottedDash(),
                            ],
                          ),
                        ),
                        Text(
                          arrivalCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: onEditPressed ?? () {},
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // 2. Second Row: Date | Travellers | Flights
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildSeparator(),
                  Text(
                    travellersText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildSeparator(),
                  Text(
                    '$flightCount Flights',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDottedDash() {
    return Container(
      width: 4,
      height: 2,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 1,
        height: 12,
        color: Colors.white.withValues(alpha: 0.4),
      ),
    );
  }
}
