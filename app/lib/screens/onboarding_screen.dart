import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../state/onboarding_state.dart';
import '../state/providers.dart';
import '../widgets/gradient_background.dart';
import '../widgets/section_header.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _horizonController = TextEditingController();
  final _monthlyController = TextEditingController();

  String _appetite = 'moderate';
  bool _submitting = false;

  @override
  void dispose() {
    _horizonController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  String? _validateOptionalInt(String? value, {int min = 1}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed < min) {
      return 'Enter a value of $min or more';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);

    final horizon = int.tryParse(_horizonController.text.trim());
    final monthly = int.tryParse(_monthlyController.text.trim());

    final payload = RiskProfileInput(
      appetite: _appetite,
      horizonYears: horizon,
      monthlyInvestment: monthly,
    );

    ref.read(riskProfileDraftProvider.notifier).state = RiskProfileDraft(
      appetite: _appetite,
      horizonYears: horizon,
      monthlyInvestment: monthly,
    );

    try {
      await ref.read(apiClientProvider).createRiskProfile(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved. Welcome to Arivest.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not reach the server. Saved locally for now.'),
          ),
        );
      }
    }

    if (mounted) {
      ref.read(onboardingCompleteProvider.notifier).state = true;
      context.go('/home');
    }

    if (mounted) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const SectionHeader(
                      title: 'Arivest',
                      subtitle: 'Arivu for smart investing.',
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Start your learning plan',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tell us your comfort level and goals. We will curate research and model portfolios to match your learning pace.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Risk appetite',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(
                                    value: 'conservative',
                                    label: Text('Conservative'),
                                  ),
                                  ButtonSegment(
                                    value: 'moderate',
                                    label: Text('Moderate'),
                                  ),
                                  ButtonSegment(
                                    value: 'aggressive',
                                    label: Text('Aggressive'),
                                  ),
                                ],
                                selected: {_appetite},
                                onSelectionChanged: (selection) {
                                  setState(() => _appetite = selection.first);
                                },
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Time horizon (years)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _horizonController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'e.g., 5',
                                ),
                                validator: (value) => _validateOptionalInt(value, min: 1),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Monthly investment (INR)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _monthlyController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'e.g., 10000',
                                ),
                                validator: (value) => _validateOptionalInt(value, min: 0),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _submitting ? null : _submit,
                                  child: _submitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Create learning plan'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Education and research only. Not investment advice.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
