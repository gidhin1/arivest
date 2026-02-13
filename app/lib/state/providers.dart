import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/api_client.dart';
import '../data/models.dart';
import '../data/session_store.dart';
import 'onboarding_state.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SharedPreferencesSessionStore();
});

final riskProfileDraftProvider = StateProvider<RiskProfileDraft>((ref) {
  return const RiskProfileDraft();
});

final researchFeedProvider = FutureProvider<List<ResearchItem>>((ref) {
  final api = ref.watch(apiClientProvider);
  final profile = ref.watch(riskProfileDraftProvider);
  return api.fetchResearchFeed(
    appetite: profile.appetite,
    experienceLevel: profile.experienceLevel,
    primaryGoal: profile.primaryGoal,
    preferredSectors: profile.preferredSectors,
  );
});

final modelPortfoliosProvider = FutureProvider<List<ModelPortfolio>>((ref) {
  final api = ref.watch(apiClientProvider);
  return api.fetchModelPortfolios();
});

final glossaryProvider = FutureProvider<List<GlossaryTerm>>((ref) {
  final api = ref.watch(apiClientProvider);
  return api.fetchGlossary();
});

final researchTagFilterProvider = StateProvider<String?>((ref) {
  return null;
});

final onboardingCompleteProvider = StateProvider<bool>((ref) {
  return false;
});

final onboardingRequiredProvider = StateProvider<bool>((ref) {
  return false;
});

class UserSession {
  const UserSession({
    required this.user,
    required this.token,
    required this.expiresAt,
  });

  final AuthUser user;
  final String token;
  final DateTime expiresAt;
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserSession?>(AuthController.new);

class AuthController extends AsyncNotifier<UserSession?> {
  @override
  Future<UserSession?> build() async {
    final store = ref.read(sessionStoreProvider);
    final stored = await store.read();
    if (stored == null) {
      ref.read(onboardingRequiredProvider.notifier).state = false;
      return null;
    }
    if (stored.expiresAt.isBefore(DateTime.now().toUtc())) {
      await store.clear();
      ref.read(onboardingRequiredProvider.notifier).state = false;
      return null;
    }
    try {
      final status = await ref
          .read(apiClientProvider)
          .fetchSession(token: stored.token);
      final session = UserSession(
        user: status.user,
        token: stored.token,
        expiresAt: status.expiresAt.toUtc(),
      );
      await store.save(
        StoredSession(
          token: session.token,
          expiresAt: session.expiresAt,
          onboardingRequired: stored.onboardingRequired,
        ),
      );
      ref.read(onboardingRequiredProvider.notifier).state =
          stored.onboardingRequired;
      return session;
    } catch (_) {
      await store.clear();
      ref.read(onboardingRequiredProvider.notifier).state = false;
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(apiClientProvider)
          .login(email: email, password: password);
      final session = UserSession(
        user: response.user,
        token: response.sessionToken,
        expiresAt: response.expiresAt.toUtc(),
      );
      await ref
          .read(sessionStoreProvider)
          .save(
            StoredSession(
              token: session.token,
              expiresAt: session.expiresAt,
              onboardingRequired: false,
            ),
          );
      ref.read(onboardingRequiredProvider.notifier).state = false;
      return session;
    });
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(apiClientProvider)
          .register(email: email, password: password, displayName: displayName);
      final session = UserSession(
        user: response.user,
        token: response.sessionToken,
        expiresAt: response.expiresAt.toUtc(),
      );
      await ref
          .read(sessionStoreProvider)
          .save(
            StoredSession(
              token: session.token,
              expiresAt: session.expiresAt,
              onboardingRequired: true,
            ),
          );
      ref.read(onboardingRequiredProvider.notifier).state = true;
      return session;
    });
  }

  Future<void> completeOnboarding() async {
    final current = state.asData?.value;
    if (current == null) {
      ref.read(onboardingRequiredProvider.notifier).state = false;
      return;
    }
    await ref
        .read(sessionStoreProvider)
        .save(
          StoredSession(
            token: current.token,
            expiresAt: current.expiresAt,
            onboardingRequired: false,
          ),
        );
    ref.read(onboardingRequiredProvider.notifier).state = false;
  }

  Future<void> logout() async {
    final current = state.asData?.value;
    if (current != null) {
      try {
        await ref.read(apiClientProvider).logout(token: current.token);
      } catch (_) {
        // Ignore remote logout failures and still clear local state.
      }
    }
    await ref.read(sessionStoreProvider).clear();
    ref.read(onboardingRequiredProvider.notifier).state = false;
    state = const AsyncData(null);
  }
}
