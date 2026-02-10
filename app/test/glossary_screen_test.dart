import 'package:arivest/screens/glossary_screen.dart';
import 'package:arivest/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_api_client.dart';
import 'helpers/test_fixtures.dart';

void main() {
  testWidgets('Glossary screen renders terms', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(FakeApiClient()),
        ],
        child: const MaterialApp(
          home: GlossaryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(sampleGlossary.first.term), findsOneWidget);
    expect(find.text(sampleGlossary.first.definition), findsOneWidget);
  });
}
