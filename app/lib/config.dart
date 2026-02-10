import 'package:flutter/foundation.dart';

const String apiBaseOverride = String.fromEnvironment(
  'ARIVEST_API_BASE_URL',
  defaultValue: '',
);

String apiBaseUrl() {
  if (apiBaseOverride.isNotEmpty) {
    return apiBaseOverride;
  }

  if (kReleaseMode) {
    throw StateError(
      'ARIVEST_API_BASE_URL must be set for release builds using HTTPS.',
    );
  }

  if (kIsWeb) {
    return 'http://localhost:8000';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:8000';
    default:
      return 'http://localhost:8000';
  }
}
