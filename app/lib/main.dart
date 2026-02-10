import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'design_system.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DesignSystem.load();
  runApp(const ProviderScope(child: ArivestApp()));
}
