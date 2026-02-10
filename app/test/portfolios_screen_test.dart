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
        overrides: [
          apiClientProvider.overrideWithValue(FakeApiClient()),
        ],
        child: const MaterialApp(
          home: PortfoliosScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(samplePortfolios.first.name), findsOneWidget);
    expect(find.text(samplePortfolios.first.allocations.first.label), findsOneWidget);
  });
}
