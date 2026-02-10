import 'package:flutter/material.dart';

import '../design_system.dart';

class PolicyNotice extends StatelessWidget {
  const PolicyNotice({
    super.key,
    this.title = 'Past-only research',
    this.message =
        'We analyze and report only on past activities using credible sources. No future predictions.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = DesignSystem.tokens.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.history,
            color: colors.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.75),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
