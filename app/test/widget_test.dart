// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arivest/app.dart';
import 'package:arivest/state/providers.dart';

import 'helpers/fake_api_client.dart';
import 'helpers/in_memory_session_store.dart';

void main() {
  testWidgets('Arivest app loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(FakeApiClient()),
          sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
        ],
        child: ArivestApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Arivest'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
