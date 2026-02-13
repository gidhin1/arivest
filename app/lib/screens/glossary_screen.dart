import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/external_link.dart';
import '../state/providers.dart';
import '../widgets/page_layout.dart';
import '../widgets/section_header.dart';

class GlossaryScreen extends ConsumerWidget {
  const GlossaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glossaryAsync = ref.watch(glossaryProvider);

    return PageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Glossary',
            subtitle: 'Simple explanations of market terms.',
          ),
          const SizedBox(height: 12),
          Text(
            'Built for beginners and intermediate investors. Each term includes practical context, risk notes, and official references.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          glossaryAsync.when(
            data: (terms) {
              if (terms.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      'No glossary terms available right now.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              }

              return Column(
                children: terms
                    .map(
                      (term) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final termTitle = Text(
                                    term.term,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  );

                                  final sourceBadge = term.sourceName == null
                                      ? null
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withValues(alpha: 0.14),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            term.sourceName!,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                          ),
                                        );

                                  if (constraints.maxWidth < 460 ||
                                      sourceBadge == null) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        termTitle,
                                        if (sourceBadge != null) ...[
                                          const SizedBox(height: 8),
                                          sourceBadge,
                                        ],
                                      ],
                                    );
                                  }

                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: termTitle),
                                      const SizedBox(width: 12),
                                      sourceBadge,
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                term.definition,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                              if (term.whyItMatters != null) ...[
                                const SizedBox(height: 14),
                                Text(
                                  'Why it matters',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  term.whyItMatters!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                              if (term.example != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Example: ${term.example!}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                              if (term.riskNote != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Risk note: ${term.riskNote!}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                  ),
                                ),
                              ],
                              if (term.relatedTerms.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: term.relatedTerms
                                      .map(
                                        (item) => Chip(
                                          label: Text(item),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                              if (term.sourceUrl != null) ...[
                                const SizedBox(height: 10),
                                TextButton.icon(
                                  onPressed: () {
                                    openExternalLink(context, term.sourceUrl);
                                  },
                                  icon: const Icon(Icons.open_in_new, size: 16),
                                  label: const Text('Read source'),
                                ),
                              ],
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
                'Could not load glossary right now.',
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
