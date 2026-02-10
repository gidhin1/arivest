import 'dart:convert';

import 'package:arivest/data/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

void main() {
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
    final response = await api.searchAssets(query: 'Reliance', assetType: 'stock');

    expect(response.items.first.id, 'stock-reliance');
    expect(response.meta.mode, 'demo');
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
              'url': 'https://www.bseindia.com/markets/MarketInfo/BhavCopy.aspx',
              'coverage': 'BSE equities',
              'note': 'Daily end of day prices.',
            }
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
}
