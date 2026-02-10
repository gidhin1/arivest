import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../widgets/section_header.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _digestEnabled = true;
  bool _remindersEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Profile',
                subtitle: 'Personalize your learning journey.',
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Education-only commitment',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Arivest provides educational research and model portfolios for learning. It does not provide personalized investment advice.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preferences',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        value: _digestEnabled,
                        onChanged: (value) {
                          setState(() => _digestEnabled = value);
                        },
                        title: const Text('Weekly research digest'),
                        subtitle: const Text('Curated market notes every Friday.'),
                      ),
                      const Divider(),
                      SwitchListTile.adaptive(
                        value: _remindersEnabled,
                        onChanged: (value) {
                          setState(() => _remindersEnabled = value);
                        },
                        title: const Text('Learning reminders'),
                        subtitle: const Text('Short nudges to keep your streak.'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () {
                  ref.read(onboardingCompleteProvider.notifier).state = false;
                  context.go('/onboarding');
                },
                child: const Text('Revisit onboarding'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
