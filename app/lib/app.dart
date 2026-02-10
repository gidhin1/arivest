import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'scroll_behavior.dart';
import 'theme.dart';

class ArivestApp extends ConsumerWidget {
  const ArivestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Arivest',
      theme: ArivestTheme.light(),
      scrollBehavior: const ArivestScrollBehavior(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
