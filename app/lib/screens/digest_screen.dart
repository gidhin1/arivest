import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/external_link.dart';
import '../state/providers.dart';
import '../widgets/page_layout.dart';
import '../widgets/policy_notice.dart';
import '../widgets/section_header.dart';

class DigestScreen extends ConsumerWidget {
  const DigestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(researchFeedProvider);

    return PageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Weekly digest',
            subtitle: 'Past-week research highlights from credible sources.',
            trailing: TextButton(
              onPressed: () {
                context.go('/home');
              },
              child: const Text('Back to home'),
            ),
          ),
          const SizedBox(height: 16),
          const PolicyNotice(),
          const SizedBox(height: 16),
          feedAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No digest items yet.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Once new research notes are published, this digest will summarize the week.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This week in research',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...items.map(
                    (item) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${item.publishedAt.day}/${item.publishedAt.month}/${item.publishedAt.year}',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.summary,
                              style: Theme.of(context).textTheme.bodyMedium,
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
                              const SizedBox(height: 8),
                              Text(
                                'Relevance: ${item.matchReasons.join(' • ')}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Could not load weekly digest right now.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
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
