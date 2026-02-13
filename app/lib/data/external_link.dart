import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openExternalLink(BuildContext context, String? rawUrl) async {
  final value = rawUrl?.trim() ?? '';
  final uri = Uri.tryParse(value);
  if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Source link is unavailable')));
    return;
  }

  final launched = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
    webOnlyWindowName: '_blank',
  );
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not open source link')));
  }
}
