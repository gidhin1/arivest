import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/login_screen.dart';
import 'screens/glossary_screen.dart';
import 'screens/digest_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/portfolios_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/responsive_preview_screen.dart';
import 'screens/search_screen.dart';
import 'screens/asset_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'state/providers.dart';
import 'widgets/gradient_background.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final onboardingRequired = ref.watch(onboardingRequiredProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final location = state.uri.path;
      final isSplash = location == '/splash';
      final isLogin = location == '/login';
      final isOnboarding = location == '/onboarding';

      if (authState.isLoading) {
        return isSplash ? null : '/splash';
      }

      final isAuthenticated = authState.asData?.value != null;
      if (!isAuthenticated) {
        return isLogin ? null : '/login';
      }

      if (onboardingRequired && !isOnboarding) {
        return '/onboarding';
      }

      if (isLogin || isSplash) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            _enterPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _enterPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _enterPage(key: state.pageKey, child: const OnboardingScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.toString(), child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                _enterPage(key: state.pageKey, child: const HomeScreen()),
          ),
          GoRoute(
            path: '/digest',
            pageBuilder: (context, state) =>
                _enterPage(key: state.pageKey, child: const DigestScreen()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) =>
                _enterPage(key: state.pageKey, child: const SearchScreen()),
            routes: [
              GoRoute(
                path: ':assetId',
                pageBuilder: (context, state) => _enterPage(
                  key: state.pageKey,
                  child: AssetDetailScreen(
                    assetId: state.pathParameters['assetId'] ?? '',
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/portfolios',
            pageBuilder: (context, state) => _enterPage(
              key: state.pageKey,
              child: PortfoliosScreen(
                riskFilter: state.uri.queryParameters['risk'],
              ),
            ),
          ),
          GoRoute(
            path: '/glossary',
            pageBuilder: (context, state) =>
                _enterPage(key: state.pageKey, child: const GlossaryScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                _enterPage(key: state.pageKey, child: const ProfileScreen()),
          ),
          GoRoute(
            path: '/preview',
            pageBuilder: (context, state) => _enterPage(
              key: state.pageKey,
              child: const ResponsivePreviewScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<void> _enterPage({
  required LocalKey key,
  required Widget child,
}) {
  const beginOffset = Offset(0, 0.035);
  const curve = Curves.easeOutCubic;

  return CustomTransitionPage<void>(
    key: key,
    opaque: true,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 160),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
      return ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        ),
      );
    },
  );
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  int _locationToIndex(String location) {
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/portfolios')) return 2;
    if (location.startsWith('/glossary')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  String _indexToLocation(int index) {
    switch (index) {
      case 1:
        return '/search';
      case 2:
        return '/portfolios';
      case 3:
        return '/glossary';
      case 4:
        return '/profile';
      default:
        return '/home';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _locationToIndex(location);

    return Scaffold(
      body: GradientBackground(child: SafeArea(child: child)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          final destination = _indexToLocation(index);
          if (destination != location) {
            context.go(destination);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_graph_outlined),
            selectedIcon: Icon(Icons.auto_graph),
            label: 'Portfolios',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Glossary',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
