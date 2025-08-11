import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beer_app_mvvm/views/pages/home_page.dart';
import 'package:beer_app_mvvm/utils/constants.dart';

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('should display app title and description', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text(AppConstants.appTitle), findsOneWidget);
      expect(find.text(AppConstants.appDescription), findsOneWidget);
    });

    testWidgets('should display generate button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text(AppConstants.generateBeerButton), findsOneWidget);
    });


    testWidgets('should have search icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}