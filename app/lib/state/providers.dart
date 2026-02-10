import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/api_client.dart';
import '../data/models.dart';
import 'onboarding_state.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final researchFeedProvider = FutureProvider<List<ResearchItem>>((ref) {
  final api = ref.watch(apiClientProvider);
  return api.fetchResearchFeed();
});

final modelPortfoliosProvider = FutureProvider<List<ModelPortfolio>>((ref) {
  final api = ref.watch(apiClientProvider);
  return api.fetchModelPortfolios();
});

final glossaryProvider = FutureProvider<List<GlossaryTerm>>((ref) {
  final api = ref.watch(apiClientProvider);
  return api.fetchGlossary();
});

final riskProfileDraftProvider = StateProvider<RiskProfileDraft>((ref) {
  return const RiskProfileDraft();
});

final onboardingCompleteProvider = StateProvider<bool>((ref) {
  return false;
});
