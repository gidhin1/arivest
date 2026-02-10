import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/page_layout.dart';
import '../widgets/policy_notice.dart';
import '../widgets/section_header.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const int _minQueryLength = 3;

  late final TextEditingController _controller;
  String _selectedFilter = 'all';
  Future<SearchResponse>? _future;
  bool _showShortQueryHint = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _future = _runSearch(query: '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<SearchResponse> _runSearch({required String query}) {
    final api = ref.read(apiClientProvider);
    return api.searchAssets(
      query: query,
      assetType: _selectedFilter,
    );
  }

  void _submitSearch() {
    _updateSearch();
  }

  void _resetSearch() {
    _controller.clear();
    setState(() {
      _selectedFilter = 'all';
      _showShortQueryHint = false;
      _future = _runSearch(query: '');
    });
  }

  void _updateSearch() {
    final query = _controller.text.trim();
    final isTooShort = query.isNotEmpty && query.length < _minQueryLength;
    setState(() {
      _showShortQueryHint = isTooShort;
      if (!isTooShort) {
        _future = _runSearch(query: query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filterOptions = _searchFilters;

    return PageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Search & research',
            subtitle: 'NSE/BSE stocks and everyday investment plans.',
          ),
          const SizedBox(height: 16),
          const PolicyNotice(),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _submitSearch(),
                    decoration: InputDecoration(
                      labelText: 'Search stocks or plans',
                      hintText: 'Try Reliance, SBI Bluechip, NIFTYBEES',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _submitSearch,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _resetSearch,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ),
                  if (_showShortQueryHint) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Type at least $_minQueryLength letters to search.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.65),
                            ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filterOptions
                          .map(
                            (filter) => ChoiceChip(
                              label: Text(filter.label),
                              selected: _selectedFilter == filter.value,
                              onSelected: (_) {
                                setState(() {
                                  _selectedFilter = filter.value;
                                });
                                _updateSearch();
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<SearchResponse>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Search is unavailable right now.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
              final data = snapshot.data;
              if (data == null || data.items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No matching assets yet. Try another term or filter.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchMetaBanner(meta: data.meta),
                  const SizedBox(height: 12),
                  Column(
                    children: data.items
                        .map(
                          (item) => _AssetResultCard(
                            item: item,
                            onTap: () {
                              context.go('/search/${item.id}');
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SearchFilter {
  const _SearchFilter(this.label, this.value);

  final String label;
  final String value;
}

const List<_SearchFilter> _searchFilters = [
  _SearchFilter('All', 'all'),
  _SearchFilter('Stocks', 'stock'),
  _SearchFilter('Mutual Funds', 'mutual_fund'),
  _SearchFilter('ETFs', 'etf'),
  _SearchFilter('Index Funds', 'index_fund'),
  _SearchFilter('Bonds', 'bond'),
  _SearchFilter('Gold', 'gold'),
  _SearchFilter('Deposits', 'deposit'),
  _SearchFilter('NPS/PPF', 'retirement'),
  _SearchFilter('Insurance', 'insurance'),
];

class _SearchMetaBanner extends StatelessWidget {
  const _SearchMetaBanner({required this.meta});

  final SearchMeta meta;

  @override
  Widget build(BuildContext context) {
    final note = meta.note;
    final date = meta.asOf;
    final dateText = '${date.day}/${date.month}/${date.year}';
    return Card(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              'As of $dateText',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (meta.mode == 'demo')
              Text(
                note ?? 'Sample data for UI only.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AssetResultCard extends StatelessWidget {
  const _AssetResultCard({required this.item, required this.onTap});

  final AssetSummary item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = (item.changePct ?? 0) >= 0;
    final changeText = item.changePct == null
        ? '—'
        : '${item.changePct!.toStringAsFixed(2)}%';
    final valueText = item.value.toStringAsFixed(2);
    final exchangeText =
        [item.exchange, item.symbol].where((value) => value != null).join(' • ');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;
              final title = Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              );
              final subtitle = Text(
                '${item.assetType.replaceAll('_', ' ').toUpperCase()}'
                '${exchangeText.isNotEmpty ? ' • $exchangeText' : ''}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              );
              final valueBlock = Column(
                crossAxisAlignment:
                    isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Text(
                    item.valueLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '$valueText ${item.currency}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    changeText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isPositive
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 6),
                    subtitle,
                    const SizedBox(height: 12),
                    valueBlock,
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: item.tags
                            .map((tag) => Chip(label: Text(tag)))
                            .toList(),
                      ),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        const SizedBox(height: 6),
                        subtitle,
                        if (item.tags.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: item.tags
                                .map((tag) => Chip(label: Text(tag)))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  valueBlock,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
