import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import 'models.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl => apiBaseUrl();

  Future<List<ResearchItem>> fetchResearchFeed() async {
    final response = await _client.get(Uri.parse('$_baseUrl/research/feed'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load research feed');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => ResearchItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ModelPortfolio>> fetchModelPortfolios() async {
    final response = await _client.get(Uri.parse('$_baseUrl/portfolios/models'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load model portfolios');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => ModelPortfolio.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<GlossaryTerm>> fetchGlossary() async {
    final response = await _client.get(Uri.parse('$_baseUrl/glossary'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load glossary');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => GlossaryTerm.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<RiskProfileResponse> createRiskProfile(RiskProfileInput input) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/risk-profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save risk profile');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return RiskProfileResponse.fromJson(data);
  }

  Future<SearchResponse> searchAssets({
    String query = '',
    String assetType = 'all',
  }) async {
    final uri = Uri.parse('$_baseUrl/search/assets').replace(
      queryParameters: {
        'query': query,
        'asset_type': assetType,
      },
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to search assets');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return SearchResponse.fromJson(data);
  }

  Future<AssetDetailResponse> fetchAssetDetail(String assetId) async {
    final response = await _client.get(Uri.parse('$_baseUrl/assets/$assetId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load asset detail');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AssetDetailResponse.fromJson(data);
  }
}
