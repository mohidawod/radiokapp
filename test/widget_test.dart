import 'package:flutter_test/flutter_test.dart';
import 'package:radiokapp/view/app.dart';

void main() {
  testWidgets('shows welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RadioKApp());

    expect(find.text('إيقاع اللحظة الآن'), findsOneWidget);
    expect(find.text('ابدأ الاستماع'), findsOneWidget);
  });
}
