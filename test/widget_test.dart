// Basic widget test for the simple calculator.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simplecalc/main.dart';

void main() {
  testWidgets('adds two numbers', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.widgetWithText(FilledButton, '7'));
    await tester.tap(find.widgetWithText(FilledButton, '+'));
    await tester.tap(find.widgetWithText(FilledButton, '5'));
    await tester.tap(find.widgetWithText(FilledButton, '='));
    await tester.pump();

    expect(find.text('12'), findsOneWidget);
  });
}
