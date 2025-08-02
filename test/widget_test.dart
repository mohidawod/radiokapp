import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_service/audio_service.dart';

import 'package:radiokapp/main.dart';

class FakeAudioHandler extends BaseAudioHandler {}

void main() {
  testWidgets('App builds and shows MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(audioHandler: FakeAudioHandler()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
