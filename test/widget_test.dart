import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiokapp/main.dart';
import 'package:radiokapp/screens/audio_handler.dart';

class FakeAudioHandler extends AudioHandler {}

void main() {
  testWidgets('App builds and shows MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(audioHandler: FakeAudioHandler()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
