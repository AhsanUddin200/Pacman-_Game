// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacman_game/main.dart';

void main() {
  testWidgets('Game board renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(PacmanGame());

    // Verify that the game board is rendered
    expect(find.byType(GridView), findsOneWidget);

    // Verify Pacman is present
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.yellow),
        findsOneWidget);
  });
}
