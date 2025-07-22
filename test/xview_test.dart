import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyCustomWidget displays title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(),
      ),
    );

    expect(find.text('Test Title'), findsOneWidget);
  });
}
