import 'package:flutter/material.dart';

import '../design_system.dart';
import '../widgets/page_layout.dart';
import '../widgets/section_header.dart';

class ResponsivePreviewScreen extends StatelessWidget {
  const ResponsivePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final tokens = DesignSystem.tokens;
    final breakpoint = _breakpointLabel(width, tokens);

    return PageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Responsive Preview',
            subtitle: 'Check spacing, typography, and layout behavior.',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Viewport details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('Width: ${width.toStringAsFixed(0)} px'),
                  Text('Breakpoint: $breakpoint'),
                  const SizedBox(height: 12),
                  Text(
                    'Padding: ${ResponsiveLayout.pagePadding(context)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
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
          const SizedBox(height: 20),
          Text(
            'Type scale',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          _TypeSample(
            label: 'Headline',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          _TypeSample(
            label: 'Title',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          _TypeSample(
            label: 'Body',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            'Card grid sample',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = ResponsiveLayout.isDesktop(context);
              final columnCount = isDesktop ? 2 : 1;
              final spacing = 16.0;
              final cardWidth =
                  (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(
                  4,
                  (index) => SizedBox(
                    width: cardWidth,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Card ${index + 1}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'This block helps validate spacing and responsive layout rules.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _breakpointLabel(double width, DesignTokens tokens) {
    if (tokens.breakpoints.mobile.contains(width)) {
      return 'Mobile';
    }
    if (tokens.breakpoints.tablet.contains(width)) {
      return 'Tablet';
    }
    if (tokens.breakpoints.desktop.contains(width)) {
      return 'Desktop';
    }
    return 'Wide';
  }
}

class _TypeSample extends StatelessWidget {
  const _TypeSample({required this.label, required this.style});

  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(letterSpacing: 1.1),
            ),
          ),
          Expanded(
            child: Text('The quick brown fox jumps over the lazy dog', style: style),
          ),
        ],
      ),
    );
  }
}
