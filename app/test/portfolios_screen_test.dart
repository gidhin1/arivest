import 'package:arivest/data/models.dart';
import 'package:arivest/screens/portfolios_screen.dart';
import 'package:arivest/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_api_client.dart';
import 'helpers/test_fixtures.dart';

void main() {
  testWidgets('Portfolios screen renders model allocations', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(FakeApiClient())],
        child: const MaterialApp(home: PortfoliosScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(samplePortfolios.first.name), findsOneWidget);
    expect(
      find.text(samplePortfolios.first.allocations.first.label),
      findsOneWidget,
    );
  });

  testWidgets('Portfolios screen applies risk filter', (tester) async {
    final portfolios = [
      ModelPortfolio(
        id: 'moderate-1',
        name: 'Balanced Learner',
        riskLevel: 'moderate',
        description: 'Balanced sample',
        allocations: [Allocation(label: 'Large Cap', weight: 50)],
      ),
      ModelPortfolio(
        id: 'aggressive-1',
        name: 'Growth Explorer',
        riskLevel: 'aggressive',
        description: 'Aggressive sample',
        allocations: [Allocation(label: 'Mid Cap', weight: 60)],
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(
            FakeApiClient(portfolios: portfolios),
          ),
        ],
        child: const MaterialApp(
          home: PortfoliosScreen(riskFilter: 'moderate'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Balanced Learner'), findsOneWidget);
    expect(find.text('Growth Explorer'), findsNothing);
    expect(find.text('Showing MODERATE portfolios'), findsOneWidget);
  });
}
