import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flightdeck/app.dart';
import 'package:flightdeck/core/database/database_helper.dart';
import 'package:flightdeck/features/flights/data/datasources/flight_local_data_source.dart';
import 'package:flightdeck/features/flights/data/datasources/flight_remote_data_source.dart';
import 'package:flightdeck/features/flights/data/repositories/flight_repository_impl.dart';
import 'package:flightdeck/features/flights/domain/usecases/get_flights.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_bloc.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Simple manual constructor dependency injection
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  final databaseHelper = DatabaseHelper();
  final remoteDataSource = FlightRemoteDataSource(dio);
  final localDataSource = FlightLocalDataSource(databaseHelper);
  final repository = FlightRepositoryImpl(remoteDataSource, localDataSource);
  final getFlights = GetFlights(repository);

  runApp(
    BlocProvider(
      create: (_) => FlightBloc(getFlights)..add(const LoadFlights()),
      child: const App(),
    ),
  );
}
