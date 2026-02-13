import 'package:arivest/data/api_client.dart';
import 'package:arivest/data/models.dart';

import 'test_fixtures.dart';

class FakeApiClient extends ApiClient {
  FakeApiClient({
    List<ResearchItem>? researchFeed,
    List<ModelPortfolio>? portfolios,
    List<GlossaryTerm>? glossary,
    SearchResponse? searchResponse,
    AssetDetailResponse? assetDetailResponse,
    AuthSessionResponse? authSessionResponse,
    AuthSessionStatus? authSessionStatus,
  }) : _researchFeed = researchFeed ?? sampleResearchFeed,
       _portfolios = portfolios ?? samplePortfolios,
       _glossary = glossary ?? sampleGlossary,
       _searchResponse = searchResponse ?? sampleSearchResponse,
       _assetDetailResponse = assetDetailResponse ?? sampleAssetDetailResponse,
       _authSessionResponse = authSessionResponse ?? sampleAuthSessionResponse,
       _authSessionStatus = authSessionStatus ?? sampleAuthSessionStatus;

  final List<ResearchItem> _researchFeed;
  final List<ModelPortfolio> _portfolios;
  final List<GlossaryTerm> _glossary;
  final SearchResponse _searchResponse;
  final AssetDetailResponse _assetDetailResponse;
  final AuthSessionResponse _authSessionResponse;
  final AuthSessionStatus _authSessionStatus;

  @override
  Future<List<ResearchItem>> fetchResearchFeed({
    String? appetite,
    String? experienceLevel,
    String? primaryGoal,
    List<String> preferredSectors = const [],
  }) async {
    return _researchFeed;
  }

  @override
  Future<List<ModelPortfolio>> fetchModelPortfolios() async {
    return _portfolios;
  }

  @override
  Future<List<GlossaryTerm>> fetchGlossary() async {
    return _glossary;
  }

  @override
  Future<RiskProfileResponse> createRiskProfile(RiskProfileInput input) async {
    return RiskProfileResponse(
      id: 1,
      appetite: input.appetite,
      horizonYears: input.horizonYears,
      monthlyInvestment: input.monthlyInvestment,
      createdAt: DateTime(2026, 2, 10),
    );
  }

  @override
  Future<SearchResponse> searchAssets({
    String query = '',
    String assetType = 'all',
  }) async {
    return _searchResponse;
  }

  @override
  Future<AssetDetailResponse> fetchAssetDetail(String assetId) async {
    return _assetDetailResponse;
  }

  @override
  Future<AuthSessionResponse> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return AuthSessionResponse(
      user: AuthUser(
        id: _authSessionResponse.user.id,
        email: email,
        displayName: displayName,
        createdAt: _authSessionResponse.user.createdAt,
      ),
      sessionToken: _authSessionResponse.sessionToken,
      expiresAt: _authSessionResponse.expiresAt,
    );
  }

  @override
  Future<AuthSessionResponse> login({
    required String email,
    required String password,
  }) async {
    return AuthSessionResponse(
      user: AuthUser(
        id: _authSessionResponse.user.id,
        email: email,
        displayName: _authSessionResponse.user.displayName,
        createdAt: _authSessionResponse.user.createdAt,
      ),
      sessionToken: _authSessionResponse.sessionToken,
      expiresAt: _authSessionResponse.expiresAt,
    );
  }

  @override
  Future<AuthSessionStatus> fetchSession({required String token}) async {
    return _authSessionStatus;
  }

  @override
  Future<void> logout({required String token}) async {}
}
