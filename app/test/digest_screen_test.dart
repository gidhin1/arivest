import 'package:arivest/screens/digest_screen.dart';
import 'package:arivest/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_api_client.dart';
import 'helpers/test_fixtures.dart';

void main() {
  testWidgets('Digest screen renders weekly research highlights', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(FakeApiClient())],
        child: const MaterialApp(home: DigestScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Weekly digest'), findsOneWidget);
    expect(find.text(sampleResearchFeed.first.title), findsOneWidget);
    expect(find.text('Open source'), findsWidgets);
  });
}
