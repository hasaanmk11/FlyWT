import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flightdeck/core/constants/api_constants.dart';
import 'package:flightdeck/features/flights/data/models/flight_model.dart';

/// Remote data source responsible for fetching flights from the Dio API.
class FlightRemoteDataSource {
  final Dio dio;

  FlightRemoteDataSource(this.dio);

  /// Fetches flights from the remote API and parses them into [FlightModel] list.
  Future<List<FlightModel>> getFlights() async {
    try {
      final response = await dio.get(ApiConstants.flightUrl);

      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;

        if (rawData is Map<String, dynamic>) {
          final dataSection = rawData['Data'] as Map<String, dynamic>?;
          final defaultCurrency =
              dataSection?['Currency']?.toString() ?? 'KWD';
          final trips = dataSection?['FlightTrips'] as List?;

          if (trips != null) {
            // Iterate all flight trips returned by the API
            return trips
                .whereType<Map<String, dynamic>>()
                .map((trip) => FlightModel.fromApiJson(
                      trip,
                      defaultCurrency: defaultCurrency,
                    ))
                .toList();
          }
        }
      }

      throw Exception('Failed to load flights: Invalid response structure');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message ?? 'Connection failed'}');
    } catch (e) {
      throw Exception('Failed to load flights: $e');
    }
  }
}
