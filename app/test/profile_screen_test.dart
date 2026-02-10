import 'package:arivest/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Profile screen shows education-only message', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    expect(find.text('Education-only commitment'), findsOneWidget);
    expect(find.text('Research policy'), findsOneWidget);
    expect(find.text('Preferences'), findsOneWidget);
  });
}
