import 'package:arivest/screens/home_screen.dart';
import 'package:arivest/state/onboarding_state.dart';
import 'package:arivest/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_api_client.dart';
import 'helpers/test_fixtures.dart';

void main() {
  testWidgets('Home screen shows research feed', (tester) async {
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(FakeApiClient())],
    );

    container
        .read(riskProfileDraftProvider.notifier)
        .state = const RiskProfileDraft(
      appetite: 'moderate',
      horizonYears: 5,
      monthlyInvestment: 10000,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Your learning profile'), findsOneWidget);
    expect(
      find.text('Past-only notes backed by credible sources.'),
      findsOneWidget,
    );
    expect(find.text(sampleResearchFeed.first.title), findsOneWidget);
    expect(find.text('Open source'), findsWidgets);
  });

  testWidgets('Home screen applies tag filter from feed chips', (tester) async {
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(FakeApiClient())],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final basicsTag = find.text('basics').first;
    await tester.ensureVisible(basicsTag);
    await tester.tap(basicsTag);
    await tester.pumpAndSettle();

    expect(find.text('Filtered by tag: basics'), findsOneWidget);
    expect(container.read(researchTagFilterProvider), 'basics');
  });
}
