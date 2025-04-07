import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patentify/main.dart';

void main() {
  testWidgets('Patentify login screen loads and shows Google Sign In button',
          (WidgetTester tester) async {
        // Build the app
        await tester.pumpWidget( PatentifyApp());

        // Allow time for Firebase and widgets to build
        await tester.pumpAndSettle();

        // Check for presence of login buttons
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.text('Continue with Apple'), findsOneWidget);
        expect(find.text('Continue with Email'), findsOneWidget);

        // Check for the login screen title
        expect(find.text('Welcome to Patentify'), findsOneWidget);
      });
}
