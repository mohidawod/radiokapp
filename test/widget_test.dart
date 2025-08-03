import 'package:flutter_test/flutter_test.dart';
import 'package:audio_service/audio_service.dart';

import 'package:radiokapp/main.dart';

/// A minimal fake [AudioHandler] for widget tests.
class FakeAudioHandler extends BaseAudioHandler {}

void main() {
  testWidgets('loads home screen with app bar title', (tester) async {
    await tester.pumpWidget(MyApp(audioHandler: FakeAudioHandler()));
    expect(find.text('تطبيق الراديو'), findsOneWidget);
  });
}
