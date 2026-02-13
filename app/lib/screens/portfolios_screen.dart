import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../widgets/page_layout.dart';
import '../widgets/policy_notice.dart';
import '../widgets/section_header.dart';

class PortfoliosScreen extends ConsumerWidget {
  const PortfoliosScreen({super.key, this.riskFilter});

  final String? riskFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfoliosAsync = ref.watch(modelPortfoliosProvider);

    return PageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Model Portfolios',
            subtitle: 'Educational allocations for different risk levels.',
          ),
          const SizedBox(height: 12),
          Text(
            'These are example allocations for learning. They describe past-only research themes, not predictions.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          const PolicyNotice(),
          const SizedBox(height: 20),
          portfoliosAsync.when(
            data: (portfolios) {
              final normalizedFilter = riskFilter?.trim().toLowerCase();
              final filteredPortfolios =
                  normalizedFilter == null || normalizedFilter.isEmpty
                  ? portfolios
                  : portfolios
                        .where(
                          (portfolio) =>
                              portfolio.riskLevel.toLowerCase() ==
                              normalizedFilter,
                        )
                        .toList();

              if (filteredPortfolios.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No portfolios found for "${riskFilter ?? ''}" risk.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            context.go('/portfolios');
                          },
                          child: const Text('Show all portfolios'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  if (normalizedFilter != null &&
                      normalizedFilter.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Showing ${normalizedFilter.toUpperCase()} portfolios',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.go('/portfolios');
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ...filteredPortfolios.map(
                    (portfolio) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isNarrow = constraints.maxWidth < 420;
                                final title = Text(
                                  portfolio.name,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                );
                                final badge = Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    portfolio.riskLevel.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          letterSpacing: 1.1,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                );

                                if (isNarrow) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      title,
                                      const SizedBox(height: 8),
                                      badge,
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(child: title),
                                    const SizedBox(width: 12),
                                    badge,
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              portfolio.description,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: portfolio.allocations
                                  .map(
                                    (allocation) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(allocation.label),
                                              ),
                                              Text(
                                                '${allocation.weight.toStringAsFixed(0)}%',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          LinearProgressIndicator(
                                            value: allocation.weight / 100,
                                            minHeight: 6,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withValues(alpha: 0.6),
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Education only. Not an investment recommendation.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Could not load portfolios right now.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
