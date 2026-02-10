import 'package:arivest/screens/asset_detail_screen.dart';
import 'package:arivest/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_api_client.dart';
import 'helpers/test_fixtures.dart';

void main() {
  testWidgets('Asset detail screen shows key sections', (tester) async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(FakeApiClient()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AssetDetailScreen(assetId: 'stock-reliance'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(sampleAssetDetailResponse.asset.summary.name), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
  });

  testWidgets('Asset detail screen shows plan highlights for funds', (tester) async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(
          FakeApiClient(assetDetailResponse: samplePlanAssetDetailResponse),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AssetDetailScreen(assetId: 'mf-sbi-bluechip'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Plan highlights'), findsOneWidget);
    expect(find.text('SBI Mutual Fund'), findsOneWidget);
  });
}
