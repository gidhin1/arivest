import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/page_layout.dart';
import '../widgets/policy_notice.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_chip.dart';

class AssetDetailScreen extends ConsumerStatefulWidget {
  const AssetDetailScreen({super.key, required this.assetId});

  final String assetId;

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen> {
  Future<AssetDetailResponse>? _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(apiClientProvider).fetchAssetDetail(widget.assetId);
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      child: FutureBuilder<AssetDetailResponse>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Asset details are unavailable right now.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          final data = snapshot.data!;
          final asset = data.asset;
          final summary = asset.summary;
          final snapshotData = asset.snapshot;
          final changePct = snapshotData.changePct ?? 0;
          final isPositive = changePct >= 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/search');
                      }
                    },
                  ),
                  Expanded(
                    child: SectionHeader(
                      title: summary.name,
                      subtitle:
                          '${summary.assetType.replaceAll('_', ' ').toUpperCase()}'
                          '${summary.exchange != null ? ' • ${summary.exchange}' : ''}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const PolicyNotice(),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${snapshotData.valueLabel} • '
                        '${summary.currency} ${snapshotData.value.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Change: ${changePct.toStringAsFixed(2)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isPositive
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'As of ${snapshotData.asOf.day}/${snapshotData.asOf.month}/${snapshotData.asOf.year}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              if (data.meta.mode == 'demo') ...[
                const SizedBox(height: 12),
                Text(
                  data.meta.note ?? 'Sample values for UI development only.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.65),
                      ),
                ),
              ],
              const SizedBox(height: 20),
              if (asset.description != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      asset.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              if (asset.metrics != null) ...[
                const SizedBox(height: 20),
                const SectionHeader(
                  title: 'Key metrics',
                  subtitle: 'High-level fundamentals for context.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _metricChips(asset.metrics!).toList(),
                ),
              ],
              if (asset.planDetails != null) ...[
                const SizedBox(height: 20),
                const SectionHeader(
                  title: 'Plan highlights',
                  subtitle: 'Key details for common investors.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _planChips(asset.planDetails!).toList(),
                ),
              ],
              if (asset.listings.isNotEmpty) ...[
                const SizedBox(height: 20),
                const SectionHeader(
                  title: 'Listings',
                  subtitle: 'Where this asset is available.',
                ),
                const SizedBox(height: 12),
                Column(
                  children: asset.listings
                      .map(
                        (listing) => Card(
                          child: ListTile(
                            title: Text(
                              '${listing.exchange} • ${listing.symbol}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: listing.isin == null
                                ? null
                                : Text('ISIN ${listing.isin}'),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (asset.sources.isNotEmpty) ...[
                const SizedBox(height: 20),
                const SectionHeader(
                  title: 'Sources',
                  subtitle: 'Credible references used for past-only analysis.',
                ),
                const SizedBox(height: 12),
                Column(
                  children: asset.sources
                      .map(
                        (source) => Card(
                          child: ListTile(
                            title: Text(source.name),
                            subtitle: Text(
                              [
                                source.coverage,
                                source.note,
                              ].where((item) => item != null && item.isNotEmpty).join(' • '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Iterable<Widget> _metricChips(AssetMetrics metrics) sync* {
    if (metrics.marketCap != null) {
      yield StatChip(
        label: 'Market Cap',
        value: 'INR ${metrics.marketCap!.toStringAsFixed(0)} Cr',
      );
    }
    if (metrics.peRatio != null) {
      yield StatChip(
        label: 'P/E',
        value: metrics.peRatio!.toStringAsFixed(1),
      );
    }
    if (metrics.pbRatio != null) {
      yield StatChip(
        label: 'P/B',
        value: metrics.pbRatio!.toStringAsFixed(1),
      );
    }
    if (metrics.dividendYield != null) {
      yield StatChip(
        label: 'Div Yield',
        value: '${metrics.dividendYield!.toStringAsFixed(2)}%',
      );
    }
    if (metrics.roe != null) {
      yield StatChip(
        label: 'ROE',
        value: '${metrics.roe!.toStringAsFixed(1)}%',
      );
    }
    if (metrics.expenseRatio != null) {
      yield StatChip(
        label: 'Expense',
        value: '${metrics.expenseRatio!.toStringAsFixed(2)}%',
      );
    }
    if (metrics.aum != null) {
      yield StatChip(
        label: 'AUM',
        value: 'INR ${metrics.aum!.toStringAsFixed(0)} Cr',
      );
    }
  }

  Iterable<Widget> _planChips(PlanDetails details) sync* {
    if (details.provider != null) {
      yield StatChip(label: 'Provider', value: details.provider!);
    }
    if (details.minInvestment != null) {
      yield StatChip(
        label: 'Min Inv',
        value: 'INR ${details.minInvestment}',
      );
    }
    if (details.minSip != null) {
      yield StatChip(
        label: 'Min SIP',
        value: 'INR ${details.minSip}',
      );
    }
    if (details.lockInMonths != null) {
      yield StatChip(
        label: 'Lock-in',
        value: '${details.lockInMonths} mo',
      );
    }
    if (details.payoutFrequency != null) {
      yield StatChip(
        label: 'Payout',
        value: details.payoutFrequency!,
      );
    }
    if (details.taxBenefit != null) {
      yield StatChip(
        label: 'Tax',
        value: details.taxBenefit!,
      );
    }
  }
}
