import 'package:arivest/screens/login_screen.dart';
import 'package:arivest/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_api_client.dart';
import 'helpers/in_memory_session_store.dart';

void main() {
  testWidgets('Login screen renders login mode by default', (tester) async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(FakeApiClient()),
        sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('New here? Create account'), findsOneWidget);
  });

  testWidgets('Login screen submits and stores session', (tester) async {
    final store = InMemorySessionStore();
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(FakeApiClient()),
        sessionStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'demo@arivest.in',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'StrongPass123',
    );
    await tester.tap(find.text('Login').last);
    await tester.pumpAndSettle();

    final session = container.read(authControllerProvider).asData?.value;
    expect(session, isNotNull);
    expect(session?.user.email, 'demo@arivest.in');

    final stored = await store.read();
    expect(stored, isNotNull);
    expect(stored?.token, isNotEmpty);
  });

  testWidgets('Register flow marks onboarding required', (tester) async {
    final store = InMemorySessionStore();
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(FakeApiClient()),
        sessionStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('New here? Create account'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Display name (optional)'),
      'Demo User',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'demo@arivest.in',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'StrongPass123',
    );
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(container.read(onboardingRequiredProvider), isTrue);
    expect(container.read(authControllerProvider).asData?.value, isNotNull);
  });
}
