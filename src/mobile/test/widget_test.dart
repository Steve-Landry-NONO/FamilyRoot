import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flutter test harness renders FamilyRoots smoke widget',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('FamilyRoots'),
        ),
      ),
    );

    expect(find.text('FamilyRoots'), findsOneWidget);
  });
}
