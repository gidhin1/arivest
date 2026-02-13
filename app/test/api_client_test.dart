import 'dart:convert';

import 'package:arivest/data/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

void main() {
  test(
    'ApiClient.fetchResearchFeed sends profile filters and parses fields',
    () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/research/feed');
        expect(request.url.queryParameters['appetite'], 'moderate');
        expect(request.url.queryParameters['experience_level'], 'beginner');
        expect(request.url.queryParameters['primary_goal'], 'wealth_creation');
        expect(
          request.url.queryParameters['preferred_sectors'],
          'technology,banking',
        );
        final payload = [
          {
            'id': 'feed-001',
            'title': 'Reading balance sheets in Indian equities',
            'summary': 'A practical walkthrough.',
            'tags': ['basics', 'fundamentals'],
            'published_at': '2026-02-01',
            'source_name': 'SEBI Circulars',
            'source_url': 'https://www.sebi.gov.in/legal/circulars/',
            'match_reasons': ['Matches your experience level'],
            'match_score': 3,
          },
        ];
        return http.Response(jsonEncode(payload), 200);
      });

      final api = ApiClient(client: client);
      final response = await api.fetchResearchFeed(
        appetite: 'moderate',
        experienceLevel: 'beginner',
        primaryGoal: 'wealth_creation',
        preferredSectors: const ['technology', 'banking'],
      );

      expect(response.first.sourceName, 'SEBI Circulars');
      expect(response.first.matchScore, 3);
    },
  );

  test('ApiClient.searchAssets parses response', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/search/assets');
      final payload = {
        'items': [
          {
            'id': 'stock-reliance',
            'name': 'Reliance Industries Ltd',
            'symbol': 'RELIANCE',
            'exchange': 'NSE/BSE',
            'asset_type': 'stock',
            'category': 'Large Cap',
            'currency': 'INR',
            'as_of': '2026-02-10',
            'value_label': 'Close',
            'value': 2940.25,
            'change_pct': 0.8,
            'risk_level': 'moderate',
            'tags': ['energy', 'conglomerate'],
          },
        ],
        'meta': {
          'mode': 'demo',
          'note': 'Sample values for UI development only.',
          'as_of': '2026-02-10',
        },
      };
      return http.Response(jsonEncode(payload), 200);
    });

    final api = ApiClient(client: client);
    final response = await api.searchAssets(
      query: 'Reliance',
      assetType: 'stock',
    );

    expect(response.items.first.id, 'stock-reliance');
    expect(response.meta.mode, 'demo');
  });

  test('ApiClient.fetchGlossary parses rich glossary fields', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/glossary');
      final payload = [
        {
          'term': 'Market Cap',
          'definition': 'Total value of listed equity.',
          'why_it_matters': 'Helps classify business scale.',
          'example': 'Price multiplied by outstanding shares.',
          'risk_note': 'Size does not remove risk.',
          'related_terms': ['Large Cap', 'Mid Cap'],
          'source_name': 'SEBI',
          'source_url': 'https://www.sebi.gov.in/',
        },
      ];
      return http.Response(jsonEncode(payload), 200);
    });

    final api = ApiClient(client: client);
    final response = await api.fetchGlossary();

    expect(response.first.term, 'Market Cap');
    expect(response.first.relatedTerms, ['Large Cap', 'Mid Cap']);
    expect(response.first.sourceUrl, 'https://www.sebi.gov.in/');
  });

  test('ApiClient.fetchAssetDetail parses response', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/assets/stock-reliance');
      final payload = {
        'asset': {
          'summary': {
            'id': 'stock-reliance',
            'name': 'Reliance Industries Ltd',
            'symbol': 'RELIANCE',
            'exchange': 'NSE/BSE',
            'asset_type': 'stock',
            'category': 'Large Cap',
            'currency': 'INR',
            'as_of': '2026-02-10',
            'value_label': 'Close',
            'value': 2940.25,
            'change_pct': 0.8,
            'risk_level': 'moderate',
            'tags': ['energy', 'conglomerate'],
          },
          'description': 'Diversified conglomerate.',
          'listings': [
            {
              'exchange': 'NSE',
              'symbol': 'RELIANCE',
              'ticker': 'RELIANCE',
              'isin': 'INE002A01018',
            },
          ],
          'snapshot': {
            'as_of': '2026-02-10',
            'value_label': 'Close',
            'value': 2940.25,
            'prev_value': 2916.0,
            'change': 24.25,
            'change_pct': 0.8,
            'open': 2922.5,
            'high': 2958.0,
            'low': 2904.3,
            'volume': 8123456,
          },
          'metrics': {'market_cap': 1900000, 'pe_ratio': 24.5},
          'plan_details': null,
          'sources': [
            {
              'id': '1',
              'name': 'BSE BhavCopy',
              'kind': 'market_data',
              'url':
                  'https://www.bseindia.com/markets/MarketInfo/BhavCopy.aspx',
              'coverage': 'BSE equities',
              'note': 'Daily end of day prices.',
            },
          ],
        },
        'meta': {
          'mode': 'demo',
          'note': 'Sample values for UI development only.',
          'as_of': '2026-02-10',
        },
      };
      return http.Response(jsonEncode(payload), 200);
    });

    final api = ApiClient(client: client);
    final response = await api.fetchAssetDetail('stock-reliance');

    expect(response.asset.summary.name, 'Reliance Industries Ltd');
    expect(response.meta.asOf.year, 2026);
  });

  test('ApiClient.login parses auth response', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/auth/login');
      expect(request.method, 'POST');
      final payload = {
        'user': {
          'id': 1,
          'email': 'demo@arivest.in',
          'display_name': 'Demo User',
          'created_at': '2026-02-10T10:00:00Z',
        },
        'session_token': 'sample-token',
        'expires_at': '2026-02-20T10:00:00Z',
      };
      return http.Response(jsonEncode(payload), 200);
    });

    final api = ApiClient(client: client);
    final response = await api.login(
      email: 'demo@arivest.in',
      password: 'StrongPass123',
    );

    expect(response.user.email, 'demo@arivest.in');
    expect(response.sessionToken, 'sample-token');
  });

  test('ApiClient.fetchSession uses bearer token', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/auth/session');
      expect(request.headers['Authorization'], 'Bearer sample-token');
      final payload = {
        'user': {
          'id': 1,
          'email': 'demo@arivest.in',
          'display_name': 'Demo User',
          'created_at': '2026-02-10T10:00:00Z',
        },
        'expires_at': '2026-02-20T10:00:00Z',
      };
      return http.Response(jsonEncode(payload), 200);
    });

    final api = ApiClient(client: client);
    final response = await api.fetchSession(token: 'sample-token');

    expect(response.user.displayName, 'Demo User');
    expect(response.expiresAt.year, 2026);
  });
}
