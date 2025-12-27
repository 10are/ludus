import 'package:flutter_test/flutter_test.dart';
import 'package:onemorejump/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const GladiatorApp());
    await tester.pump();

    // Verify main menu appears
    expect(find.text('GLADYATÖR'), findsOneWidget);
    expect(find.text('LUDUS'), findsOneWidget);
  });
}
