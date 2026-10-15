import 'package:flutter_test/flutter_test.dart';
import 'package:utility_monitor/main.dart';

void main() {
  testWidgets('App loads LoginScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UtilityMonitorApp());
    expect(find.text('Монітор комунальних витрат'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
  });
}
