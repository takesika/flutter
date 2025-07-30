import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:beer_app_mvvm/views/pages/home_page.dart';
import 'package:beer_app_mvvm/viewmodels/home_viewmodel.dart';
import 'package:beer_app_mvvm/utils/constants.dart';

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('should display app title and description', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => HomeViewModel(),
            child: const HomePage(),
          ),
        ),
      );

      expect(find.text(AppConstants.appTitle), findsOneWidget);
      expect(find.text(AppConstants.appDescription), findsOneWidget);
    });

    testWidgets('should display navigation buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => HomeViewModel(),
            child: const HomePage(),
          ),
        ),
      );

      expect(find.text(AppConstants.selectBeerButton), findsOneWidget);
      expect(find.text(AppConstants.generateBeerButton), findsOneWidget);
    });

    testWidgets('should display bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => HomeViewModel(),
            child: const HomePage(),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text(AppConstants.homeLabel), findsOneWidget);
      expect(find.text(AppConstants.selectLabel), findsOneWidget);
      expect(find.text(AppConstants.generateLabel), findsOneWidget);
    });

    testWidgets('should have proper icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => HomeViewModel(),
            child: const HomePage(),
          ),
        ),
      );

      expect(find.byIcon(Icons.local_drink), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.list_alt), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });
}