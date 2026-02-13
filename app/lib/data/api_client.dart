import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import 'models.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl => apiBaseUrl();

  Map<String, String> _jsonHeaders({String? token}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<AuthSessionResponse> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
        if (displayName != null && displayName.trim().isNotEmpty)
          'display_name': displayName.trim(),
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to register');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthSessionResponse.fromJson(data);
  }

  Future<AuthSessionResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _jsonHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to login');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthSessionResponse.fromJson(data);
  }

  Future<AuthSessionStatus> fetchSession({required String token}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/auth/session'),
      headers: _jsonHeaders(token: token),
    );
    if (response.statusCode != 200) {
      throw Exception('Session is invalid');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthSessionStatus.fromJson(data);
  }

  Future<void> logout({required String token}) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/logout'),
      headers: _jsonHeaders(token: token),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to logout');
    }
  }

  Future<List<ResearchItem>> fetchResearchFeed({
    String? appetite,
    String? experienceLevel,
    String? primaryGoal,
    List<String> preferredSectors = const [],
  }) async {
    final queryParameters = <String, String>{};
    if (appetite != null && appetite.trim().isNotEmpty) {
      queryParameters['appetite'] = appetite.trim();
    }
    if (experienceLevel != null && experienceLevel.trim().isNotEmpty) {
      queryParameters['experience_level'] = experienceLevel.trim();
    }
    if (primaryGoal != null && primaryGoal.trim().isNotEmpty) {
      queryParameters['primary_goal'] = primaryGoal.trim();
    }
    if (preferredSectors.isNotEmpty) {
      queryParameters['preferred_sectors'] = preferredSectors.join(',');
    }

    final uri = Uri.parse('$_baseUrl/research/feed').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load research feed');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => ResearchItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ModelPortfolio>> fetchModelPortfolios() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/portfolios/models'),
    );
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
    final uri = Uri.parse(
      '$_baseUrl/search/assets',
    ).replace(queryParameters: {'query': query, 'asset_type': assetType});
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
