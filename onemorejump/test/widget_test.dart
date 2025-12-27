import 'package:flutter_test/flutter_test.dart';
import 'package:onemorejump/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const OneMoreJumpApp());
    await tester.pump();

    // Verify main menu appears
    expect(find.text('ONE MORE'), findsOneWidget);
    expect(find.text('JUMP'), findsOneWidget);
    expect(find.text('TAP TO START'), findsOneWidget);
  });
}
