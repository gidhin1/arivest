import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../widgets/page_layout.dart';
import '../widgets/policy_notice.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(researchFeedProvider);
    final profile = ref.watch(riskProfileDraftProvider);

    return PageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Arivest Research',
            subtitle: 'Arivu for smart investing.',
          ),
          const SizedBox(height: 20),
          Builder(
            builder: (context) {
              final isDesktop = ResponsiveLayout.isDesktop(context);
              final profileCard = Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your learning profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We keep your research feed aligned to your comfort level.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          StatChip(
                            label: 'Risk',
                            value: profile.appetite.toUpperCase(),
                          ),
                          if (profile.horizonYears != null)
                            StatChip(
                              label: 'Horizon',
                              value: '${profile.horizonYears} yrs',
                            ),
                          if (profile.monthlyInvestment != null)
                            StatChip(
                              label: 'Monthly',
                              value: 'INR ${profile.monthlyInvestment}',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: profileCard),
                    const SizedBox(width: 16),
                    const Expanded(child: PolicyNotice()),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileCard,
                  const SizedBox(height: 16),
                  const PolicyNotice(),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Research feed',
            subtitle: 'Past-only notes backed by credible sources.',
            trailing: OutlinedButton(
              onPressed: () {},
              child: const Text('Weekly digest'),
            ),
          ),
          const SizedBox(height: 12),
          feedAsync.when(
            data: (items) {
              return Column(
                children: items
                    .map(
                      (item) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isNarrow = constraints.maxWidth < 420;
                                  final title = Text(
                                    item.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  );
                                  final date = Text(
                                    '${item.publishedAt.day}/${item.publishedAt.month}/${item.publishedAt.year}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                  );

                                  if (isNarrow) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        title,
                                        const SizedBox(height: 6),
                                        date,
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      Expanded(child: title),
                                      const SizedBox(width: 12),
                                      date,
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.summary,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: item.tags
                                    .map(
                                      (tag) => Chip(
                                        label: Text(tag),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Could not load research right now.',
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
