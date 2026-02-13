import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/external_link.dart';
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
    final selectedTag = ref.watch(researchTagFilterProvider);

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
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
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
                            onTap: () {
                              context.go(
                                '/portfolios?risk=${profile.appetite}',
                              );
                            },
                          ),
                          if (profile.horizonYears != null)
                            StatChip(
                              label: 'Horizon',
                              value: '${profile.horizonYears} yrs',
                              onTap: () {
                                context.go('/onboarding');
                              },
                            ),
                          StatChip(
                            label: 'Experience',
                            value: profile.experienceLevel.toUpperCase(),
                          ),
                          StatChip(
                            label: 'Goal',
                            value: profile.primaryGoal
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                          ),
                          if (profile.monthlyInvestment != null)
                            StatChip(
                              label: 'Monthly',
                              value: 'INR ${profile.monthlyInvestment}',
                              onTap: () {
                                context.go('/onboarding');
                              },
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
              onPressed: () {
                context.go('/digest');
              },
              child: const Text('Weekly digest'),
            ),
          ),
          const SizedBox(height: 12),
          feedAsync.when(
            data: (items) {
              final filteredItems = selectedTag == null
                  ? items
                  : items
                        .where(
                          (item) => item.tags.any(
                            (tag) =>
                                tag.trim().toLowerCase() ==
                                selectedTag.trim().toLowerCase(),
                          ),
                        )
                        .toList();

              if (filteredItems.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No notes found for "$selectedTag".',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.read(researchTagFilterProvider.notifier).state =
                                null;
                          },
                          child: const Text('Clear tag filter'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedTag != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Filtered by tag: $selectedTag',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ref
                                        .read(
                                          researchTagFilterProvider.notifier,
                                        )
                                        .state =
                                    null;
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ...filteredItems.map(
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
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                );
                                final date = Text(
                                  '${item.publishedAt.day}/${item.publishedAt.month}/${item.publishedAt.year}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                );

                                if (isNarrow) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                            ),
                            if (item.sourceName != null) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                runSpacing: 6,
                                children: [
                                  Text(
                                    'Source: ${item.sourceName}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.65),
                                        ),
                                  ),
                                  if (item.sourceUrl != null)
                                    TextButton.icon(
                                      onPressed: () {
                                        openExternalLink(
                                          context,
                                          item.sourceUrl,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.open_in_new,
                                        size: 16,
                                      ),
                                      label: const Text('Open source'),
                                    ),
                                ],
                              ),
                            ],
                            if (item.matchReasons.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Why shown: ${item.matchReasons.join(' • ')}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: item.tags
                                  .map(
                                    (tag) => ChoiceChip(
                                      label: Text(tag),
                                      selected:
                                          selectedTag?.toLowerCase() ==
                                          tag.toLowerCase(),
                                      onSelected: (_) {
                                        ref
                                                .read(
                                                  researchTagFilterProvider
                                                      .notifier,
                                                )
                                                .state =
                                            tag;
                                      },
                                    ),
                                  )
                                  .toList(),
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
