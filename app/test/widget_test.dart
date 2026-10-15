import 'package:flightdeck/app.dart';
import 'package:flightdeck/features/flights/domain/entities/flight.dart';
import 'package:flightdeck/features/flights/domain/repositories/flight_repository.dart';
import 'package:flightdeck/features/flights/domain/usecases/get_flights.dart';
import 'package:flightdeck/features/flights/presentation/bloc/flight_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTestRepository implements FlightRepository {
  @override
  Future<List<Flight>> getFlights() async {
    return [];
  }
}

void main() {
  testWidgets('App renders FlightDeck title', (WidgetTester tester) async {
    final repository = FakeTestRepository();
    final getFlights = GetFlights(repository);

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => FlightBloc(getFlights),
        child: const App(),
      ),
    );

    expect(find.text('FlightDeck'), findsOneWidget);
  });
}
