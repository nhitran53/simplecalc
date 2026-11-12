// Basic widget tests for the simple calculator.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simplecalc/main.dart';

void main() {
  // Taps every character of [keys] in order, pumping between each one.
  Future<void> tapKeys(WidgetTester tester, String keys) async {
    for (final key in keys.split('')) {
      await tester.tap(find.widgetWithText(FilledButton, key));
      await tester.pump();
    }
  }

  // Runs one calculation on a fresh app and checks the display.
  Future<void> expectResult(
    WidgetTester tester,
    String keys,
    String expected,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tapKeys(tester, keys);
    expect(find.text(expected), findsOneWidget);
  }

  testWidgets('adds two whole numbers', (WidgetTester tester) async {
    await expectResult(tester, '7+8=', '15');
  });

  testWidgets('subtracts two decimals', (WidgetTester tester) async {
    await expectResult(tester, '12.5-4.25=', '8.25');
  });

  testWidgets('multiplies a whole number by a decimal',
      (WidgetTester tester) async {
    await expectResult(tester, '6×2.5=', '15');
  });

  testWidgets('divides into a decimal result', (WidgetTester tester) async {
    await expectResult(tester, '9÷4=', '2.25');
  });

  testWidgets('adds two decimals', (WidgetTester tester) async {
    await expectResult(tester, '3.5+1.25=', '4.75');
  });

  // Regression tests for bugs found in code review.
  group('regressions', () {
    testWidgets('pressing an operator after divide-by-zero does not crash',
        (WidgetTester tester) async {
      await expectResult(tester, '5÷0=', 'Error');
      await tapKeys(tester, '+%=');
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('+/- on the error screen leaves it unchanged',
        (WidgetTester tester) async {
      await expectResult(tester, '1÷0=', 'Error');
      await tester.tap(find.widgetWithText(FilledButton, '+/-'));
      await tester.pump();
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('a digit after an error starts a new calculation',
        (WidgetTester tester) async {
      await expectResult(tester, '1÷0=', 'Error');
      await tapKeys(tester, '12+3=');
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('chaining after % keeps the first number',
        (WidgetTester tester) async {
      await expectResult(tester, '50+10%+5=', '55.1');
    });

    testWidgets('hides floating-point rounding noise',
        (WidgetTester tester) async {
      await expectResult(tester, '.1+.2=', '0.3');
    });
  });
}
