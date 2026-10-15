import 'package:flutter_test/flutter_test.dart';
import 'package:flightdeck/app.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('FlightDeck'), findsOneWidget);
  });
}
