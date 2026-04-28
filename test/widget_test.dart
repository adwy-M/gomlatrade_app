import 'package:flutter_test/flutter_test.dart';

import 'package:gomlatrade_app/main.dart';

void main() {
  testWidgets('shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GomlatradeApp());

    expect(find.text('Gomlatrade App'), findsOneWidget);
  });
}
