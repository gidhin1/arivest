import 'package:arivest/screens/responsive_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Responsive preview shows mobile breakpoint', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(size: Size(375, 800)),
          child: child ?? const SizedBox.shrink(),
        ),
        home: const ResponsivePreviewScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Breakpoint: Mobile'), findsOneWidget);
    expect(find.text('Responsive Preview'), findsOneWidget);
  });

  testWidgets('Responsive preview shows desktop breakpoint', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(size: Size(1024, 800)),
          child: child ?? const SizedBox.shrink(),
        ),
        home: const ResponsivePreviewScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Breakpoint: Desktop'), findsOneWidget);
    expect(find.text('Card 1'), findsOneWidget);
  });
}
