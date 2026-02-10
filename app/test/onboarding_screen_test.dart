import 'package:arivest/screens/onboarding_screen.dart';
import 'package:arivest/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_api_client.dart';

void main() {
  testWidgets('Onboarding screen renders core fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(FakeApiClient()),
        ],
        child: const MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    expect(find.text('Arivest'), findsOneWidget);
    expect(find.text('Start your learning plan'), findsOneWidget);
    expect(find.text('Past-only research'), findsOneWidget);
    expect(find.text('Risk appetite'), findsOneWidget);
    expect(find.text('Time horizon (years)'), findsOneWidget);
    expect(find.text('Monthly investment (INR)'), findsOneWidget);
    expect(find.text('Create learning plan'), findsOneWidget);
  });
}
