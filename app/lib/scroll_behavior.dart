import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ArivestScrollBehavior extends MaterialScrollBehavior {
  const ArivestScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
