import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flightdeck/core/theme/app_colors.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_bloc.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_event.dart';

/// Bottom sheet allowing users to sort flights by Airline, Duration, and Price
/// in Ascending or Descending order matching the FlyWT Figma design.
class SortBottomSheet extends StatefulWidget {
  final FlightSortType? initialSortType;

  const SortBottomSheet({
    super.key,
    this.initialSortType,
  });

  static Future<void> show(
    BuildContext context, {
    FlightSortType? initialSortType,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<FlightBloc>(),
        child: SortBottomSheet(initialSortType: initialSortType),
      ),
    );
  }

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  FlightSortType? _selectedSortType;

  @override
  void initState() {
    super.initState();
    _selectedSortType = widget.initialSortType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header with Title and Orange Circular Close Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: [
                const SizedBox(width: 32),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Sort Flight By',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),

          // 2. Sort Options: Airline, Duration, Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                // Airline
                _buildSortRow(
                  label: 'Airline',
                  ascType: FlightSortType.airlineAscending,
                  descType: FlightSortType.airlineDescending,
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 24),

                // Duration
                _buildSortRow(
                  label: 'Duration',
                  ascType: FlightSortType.durationAscending,
                  descType: FlightSortType.durationDescending,
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 24),

                // Price
                _buildSortRow(
                  label: 'Price',
                  ascType: FlightSortType.priceAscending,
                  descType: FlightSortType.priceDescending,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Bottom Action Buttons: Reset and Done
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Reset Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        // Clear sorting by applying an event or null
                        context.read<FlightBloc>().add(
                              // Calling ClearFlightFilter with active airline retains filter
                              const ClearFlightFilter(),
                            );
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.orange,
                        side: const BorderSide(
                          color: AppColors.orange,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Done Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedSortType != null) {
                          context.read<FlightBloc>().add(
                                SortFlights(_selectedSortType!),
                              );
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortRow({
    required String label,
    required FlightSortType ascType,
    required FlightSortType descType,
  }) {
    final isAscSelected = _selectedSortType == ascType;
    final isDescSelected = _selectedSortType == descType;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        Row(
          children: [
            // Up Arrow (Ascending)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSortType = isAscSelected ? null : ascType;
                });
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isAscSelected
                      ? AppColors.orange
                      : const Color(0xFF1E293B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_drop_up,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Down Arrow (Descending)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSortType = isDescSelected ? null : descType;
                });
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDescSelected
                      ? AppColors.orange
                      : const Color(0xFF1E293B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
