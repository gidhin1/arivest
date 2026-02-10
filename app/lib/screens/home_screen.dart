import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(researchFeedProvider);
    final profile = ref.watch(riskProfileDraftProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Arivest Research',
                subtitle: 'Arivu for smart investing.',
              ),
              const SizedBox(height: 20),
              Card(
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
                                  .withOpacity(0.7),
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
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Today\'s research',
                subtitle: 'Curated reading to build your market instincts.',
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
                            child: ListTile(
                              title: Text(item.title),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(item.summary),
                              ),
                              trailing: Text(
                                '${item.publishedAt.day}/${item.publishedAt.month}/${item.publishedAt.year}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
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
        ),
      ),
    );
  }
}
