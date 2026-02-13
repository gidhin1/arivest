import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../state/onboarding_state.dart';
import '../state/providers.dart';
import '../widgets/gradient_background.dart';
import '../widgets/page_layout.dart';
import '../widgets/policy_notice.dart';
import '../widgets/section_header.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _goalOptions = <String, String>{
    'wealth_creation': 'Wealth creation',
    'retirement': 'Retirement corpus',
    'income': 'Regular income',
    'capital_preservation': 'Capital preservation',
  };

  static const _ageOptions = <String, String>{
    '18-25': '18-25',
    '26-35': '26-35',
    '36-50': '36-50',
    '50+': '50+',
  };

  static const _sectorOptions = <String>[
    'technology',
    'banking',
    'pharma',
    'energy',
    'infrastructure',
    'consumer',
    'auto',
    'capital-goods',
  ];

  final _formKey = GlobalKey<FormState>();
  final _horizonController = TextEditingController();
  final _monthlyController = TextEditingController();
  final _weeklyLearningController = TextEditingController();

  String _appetite = 'moderate';
  String _experienceLevel = 'beginner';
  String _primaryGoal = 'wealth_creation';
  String _ageGroup = '26-35';
  final Set<String> _selectedSectors = <String>{};
  bool _submitting = false;

  @override
  void dispose() {
    _horizonController.dispose();
    _monthlyController.dispose();
    _weeklyLearningController.dispose();
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
    final weeklyLearning = int.tryParse(_weeklyLearningController.text.trim());
    final selectedSectors = _selectedSectors.toList(growable: false);

    final payload = RiskProfileInput(
      appetite: _appetite,
      horizonYears: horizon,
      monthlyInvestment: monthly,
      experienceLevel: _experienceLevel,
      primaryGoal: _primaryGoal,
      ageGroup: _ageGroup,
      preferredSectors: selectedSectors,
      weeklyLearningMinutes: weeklyLearning,
    );

    ref.read(riskProfileDraftProvider.notifier).state = RiskProfileDraft(
      appetite: _appetite,
      experienceLevel: _experienceLevel,
      primaryGoal: _primaryGoal,
      ageGroup: _ageGroup,
      preferredSectors: selectedSectors,
      weeklyLearningMinutes: weeklyLearning,
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
      await ref.read(authControllerProvider.notifier).completeOnboarding();
      if (!mounted) {
        return;
      }
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
          child: PageLayout(
            maxWidth: 680,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Arivest',
                  subtitle: 'Arivu for smart investing.',
                ),
                const SizedBox(height: 20),
                Text(
                  'Start your learning plan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us your comfort level and goals. We curate past-only research and model portfolios to match your learning pace.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                const PolicyNotice(),
                const SizedBox(height: 24),
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
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildAppetiteChip(
                                'conservative',
                                'Conservative',
                              ),
                              _buildAppetiteChip('moderate', 'Moderate'),
                              _buildAppetiteChip('aggressive', 'Aggressive'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Experience level',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildExperienceChip('beginner', 'Beginner'),
                              _buildExperienceChip(
                                'intermediate',
                                'Intermediate',
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Primary goal',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _primaryGoal,
                            items: _goalOptions.entries
                                .map(
                                  (entry) => DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() => _primaryGoal = value);
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Age group',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _ageGroup,
                            items: _ageOptions.entries
                                .map(
                                  (entry) => DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              setState(() => _ageGroup = value);
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
                            validator: (value) =>
                                _validateOptionalInt(value, min: 1),
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
                            validator: (value) =>
                                _validateOptionalInt(value, min: 0),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Weekly learning time (minutes)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _weeklyLearningController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g., 90',
                            ),
                            validator: (value) =>
                                _validateOptionalInt(value, min: 15),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Preferred sectors (pick up to 3)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _sectorOptions
                                .map(
                                  (sector) => FilterChip(
                                    label: Text(_toTitleCase(sector)),
                                    selected: _selectedSectors.contains(sector),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          if (_selectedSectors.length >= 3) {
                                            return;
                                          }
                                          _selectedSectors.add(sector);
                                        } else {
                                          _selectedSectors.remove(sector);
                                        }
                                      });
                                    },
                                  ),
                                )
                                .toList(),
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Create learning plan'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Education and research only. Not investment advice.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
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
    );
  }

  Widget _buildAppetiteChip(String value, String label) {
    final isSelected = _appetite == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _appetite = value);
      },
    );
  }

  Widget _buildExperienceChip(String value, String label) {
    final isSelected = _experienceLevel == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _experienceLevel = value);
      },
    );
  }

  String _toTitleCase(String input) {
    return input
        .split('-')
        .map((chunk) {
          if (chunk.isEmpty) {
            return chunk;
          }
          return '${chunk[0].toUpperCase()}${chunk.substring(1)}';
        })
        .join(' ');
  }
}
