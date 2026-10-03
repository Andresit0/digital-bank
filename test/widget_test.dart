import 'package:digital_bank/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays the Digital Bank application', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Digital Bank'), findsWidgets);
  });
}