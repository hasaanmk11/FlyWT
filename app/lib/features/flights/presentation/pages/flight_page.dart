import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flightdeck/core/theme/app_colors.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_bloc.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_event.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_state.dart';
import 'package:flightdeck/features/flights/presentation/widgets/filter_bottom_sheet.dart';
import 'package:flightdeck/features/flights/presentation/widgets/flight_card.dart';
import 'package:flightdeck/features/flights/presentation/widgets/flight_header.dart';
import 'package:flightdeck/features/flights/presentation/widgets/sort_bottom_sheet.dart';
import 'package:flightdeck/features/flights/presentation/widgets/sort_filter_bar.dart';

/// Main flight listing screen reproducing the FlyWT Figma design.
class FlightPage extends StatelessWidget {
  const FlightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<FlightBloc, FlightState>(
        builder: (context, state) {
          final firstFlight =
              state is FlightLoaded && state.allFlights.isNotEmpty
                  ? state.allFlights.first
                  : null;

          final departureCode = firstFlight?.departureAirport ?? 'DXB';
          final arrivalCode = firstFlight?.arrivalAirport ?? 'KWI';
          final dateText = _formatHeaderDate(firstFlight?.departureTime);
          final flightCount =
              state is FlightLoaded ? state.displayedFlights.length : 0;

          return Column(
            children: [
              // 1. Blue Flight Header Banner
              FlightHeader(
                departureCode: departureCode,
                arrivalCode: arrivalCode,
                dateText: dateText,
                flightCount: flightCount,
                onBackPressed: () => Navigator.maybePop(context),
                onEditPressed: () {
                  context.read<FlightBloc>().add(const LoadFlights());
                },
              ),

              // 2. Flight List Area with Floating Controls
              Expanded(
                child: Stack(
                  children: [
                    if (state is FlightLoading || state is FlightInitial)
                      _buildLoadingView()
                    else if (state is FlightError)
                      _buildErrorView(context, state.message)
                    else if (state is FlightLoaded)
                      _buildFlightList(context, state),

                    // 3. Floating Bottom Sort/Filter Bar
                    if (state is FlightLoaded)
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SortFilterBar(
                            isFilterActive: state.selectedAirline != null,
                            isSortActive: state.sortType != null,
                            onSortTap: () => _openSortBottomSheet(context, state),
                            onFilterTap: () =>
                                _openFilterBottomSheet(context, state),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Searching best flights...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Checking local cache and live schedules',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.danger,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to load flights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<FlightBloc>().add(const LoadFlights());
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightList(BuildContext context, FlightLoaded state) {
    if (state.displayedFlights.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'No flights found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try selecting a different airline or resetting the filter.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<FlightBloc>().add(const ClearFlightFilter());
                },
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Show All Airlines'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.orange,
      onRefresh: () async {
        context.read<FlightBloc>().add(const LoadFlights());
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // Extra bottom padding for floating bar
        itemCount: state.displayedFlights.length,
        itemBuilder: (context, index) {
          final flight = state.displayedFlights[index];
          return FlightCard(flight: flight);
        },
      ),
    );
  }

  void _openFilterBottomSheet(BuildContext context, FlightLoaded state) {
    FilterBottomSheet.show(
      context,
      availableAirlines: state.availableAirlines,
      initialSelectedAirlines: state.selectedAirlines.isNotEmpty
          ? state.selectedAirlines
          : (state.selectedAirline != null ? {state.selectedAirline!} : {}),
    );
  }

  void _openSortBottomSheet(BuildContext context, FlightLoaded state) {
    SortBottomSheet.show(
      context,
      initialSortType: state.sortType,
    );
  }

  String _formatHeaderDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '17 October';
    final date = DateTime.tryParse(isoString);
    if (date == null) return '17 October';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final monthName = date.month >= 1 && date.month <= 12
        ? months[date.month - 1]
        : 'October';
    return '${date.day.toString().padLeft(2, '0')} $monthName';
  }
}
