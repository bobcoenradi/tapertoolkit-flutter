import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taper_toolkit_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaperToolkitApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
