// Basic Flutter widget test for CodeVald Fortex

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:codevald_fortex/main.dart';
import 'package:codevald_fortex/config/app_constants.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ProviderScope(child: CodeValdFortexApp()));

    // Verify that app name is displayed
    expect(find.text(AppConstants.appName), findsWidgets);
    
    // Verify welcome message
    expect(find.text('Welcome to ${AppConstants.appName}'), findsOneWidget);
    
    // Verify Get Started button
    expect(find.text('Get Started'), findsOneWidget);
  });
}
