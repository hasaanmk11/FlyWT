import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_bloc.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_event.dart';

/// Button providing a popup menu to select flight sorting criteria.
class SortButton extends StatelessWidget {
  final FlightSortType? selectedSortType;

  const SortButton({
    super.key,
    this.selectedSortType,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FlightSortType>(
      initialValue: selectedSortType,
      tooltip: 'Sort flights',
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (sortType) {
        context.read<FlightBloc>().add(SortFlights(sortType));
      },
      itemBuilder: (context) {
        return FlightSortType.values.map((sortType) {
          final isSelected = sortType == selectedSortType;
          return PopupMenuItem<FlightSortType>(
            value: sortType,
            child: Row(
              children: [
                Icon(
                  _iconForSortType(sortType),
                  size: 18,
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    sortType.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedSortType != null
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
            width: selectedSortType != null ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 18,
              color: selectedSortType != null
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              selectedSortType != null ? selectedSortType!.label : 'Sort',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selectedSortType != null
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForSortType(FlightSortType type) {
    switch (type) {
      case FlightSortType.priceLowToHigh:
        return Icons.arrow_upward_rounded;
      case FlightSortType.priceHighToLow:
        return Icons.arrow_downward_rounded;
      case FlightSortType.departureTime:
        return Icons.access_time_rounded;
      case FlightSortType.duration:
        return Icons.timer_outlined;
    }
  }
}
