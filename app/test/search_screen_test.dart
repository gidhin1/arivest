import 'package:arivest/screens/search_screen.dart';
import 'package:arivest/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_api_client.dart';
import 'helpers/test_fixtures.dart';

void main() {
  testWidgets('Search screen shows results', (tester) async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(FakeApiClient()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Search & research'), findsOneWidget);
    expect(find.text(sampleSearchResponse.items.first.name), findsOneWidget);
    expect(find.text('Stocks'), findsOneWidget);
  });

  testWidgets('Search screen updates when filter selected', (tester) async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(FakeApiClient()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('ETFs'));
    await tester.pumpAndSettle();

    expect(find.text('ETFs'), findsOneWidget);
  });

  testWidgets('Search screen shows minimum length hint', (tester) async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(FakeApiClient()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ab');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.text('Type at least 3 letters to search.'), findsOneWidget);
  });

  testWidgets('Search screen reset clears short query hint', (tester) async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(FakeApiClient()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ab');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.text('Type at least 3 letters to search.'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(find.text('Type at least 3 letters to search.'), findsNothing);
  });
}
