import 'package:arivest/data/api_client.dart';
import 'package:arivest/data/models.dart';

import 'test_fixtures.dart';

class FakeApiClient extends ApiClient {
  FakeApiClient({
    List<ResearchItem>? researchFeed,
    List<ModelPortfolio>? portfolios,
    List<GlossaryTerm>? glossary,
  })  : _researchFeed = researchFeed ?? sampleResearchFeed,
        _portfolios = portfolios ?? samplePortfolios,
        _glossary = glossary ?? sampleGlossary;

  final List<ResearchItem> _researchFeed;
  final List<ModelPortfolio> _portfolios;
  final List<GlossaryTerm> _glossary;

  @override
  Future<List<ResearchItem>> fetchResearchFeed() async {
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
}
