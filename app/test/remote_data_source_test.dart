import 'package:dio/dio.dart';
import 'package:flightdeck/features/flights/data/datasources/flight_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FlightRemoteDataSource retrieves and parses real flights from API',
      () async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    final dataSource = FlightRemoteDataSource(dio);

    final flights = await dataSource.getFlights();

    expect(flights, isNotEmpty);
    expect(flights.length, equals(6));

    final first = flights.first;
    expect(first.airlineName, isNotEmpty);
    expect(first.airlineCode, isNotEmpty);
    expect(first.departureAirport, isNotEmpty);
    expect(first.arrivalAirport, isNotEmpty);
    expect(first.price, greaterThan(0));
    expect(first.currency, equals('KWD'));
  });
}
