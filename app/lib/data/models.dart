class ResearchItem {
  ResearchItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.tags,
    required this.publishedAt,
    this.sourceName,
    this.sourceUrl,
    this.matchReasons = const [],
    this.matchScore = 0,
  });

  final String id;
  final String title;
  final String summary;
  final List<String> tags;
  final DateTime publishedAt;
  final String? sourceName;
  final String? sourceUrl;
  final List<String> matchReasons;
  final int matchScore;

  factory ResearchItem.fromJson(Map<String, dynamic> json) {
    return ResearchItem(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      tags: List<String>.from(json['tags'] as List<dynamic>),
      publishedAt: DateTime.parse(json['published_at'] as String),
      sourceName: json['source_name'] as String?,
      sourceUrl: json['source_url'] as String?,
      matchReasons: List<String>.from(
        (json['match_reasons'] as List<dynamic>? ?? const []),
      ),
      matchScore: json['match_score'] as int? ?? 0,
    );
  }
}

class Allocation {
  Allocation({required this.label, required this.weight});

  final String label;
  final double weight;

  factory Allocation.fromJson(Map<String, dynamic> json) {
    return Allocation(
      label: json['label'] as String,
      weight: (json['weight'] as num).toDouble(),
    );
  }
}

class ModelPortfolio {
  ModelPortfolio({
    required this.id,
    required this.name,
    required this.riskLevel,
    required this.description,
    required this.allocations,
  });

  final String id;
  final String name;
  final String riskLevel;
  final String description;
  final List<Allocation> allocations;

  factory ModelPortfolio.fromJson(Map<String, dynamic> json) {
    return ModelPortfolio(
      id: json['id'] as String,
      name: json['name'] as String,
      riskLevel: json['risk_level'] as String,
      description: json['description'] as String,
      allocations: (json['allocations'] as List<dynamic>)
          .map((item) => Allocation.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GlossaryTerm {
  GlossaryTerm({
    required this.term,
    required this.definition,
    this.whyItMatters,
    this.example,
    this.riskNote,
    this.relatedTerms = const [],
    this.sourceName,
    this.sourceUrl,
  });

  final String term;
  final String definition;
  final String? whyItMatters;
  final String? example;
  final String? riskNote;
  final List<String> relatedTerms;
  final String? sourceName;
  final String? sourceUrl;

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) {
    return GlossaryTerm(
      term: json['term'] as String,
      definition: json['definition'] as String,
      whyItMatters: json['why_it_matters'] as String?,
      example: json['example'] as String?,
      riskNote: json['risk_note'] as String?,
      relatedTerms: List<String>.from(
        (json['related_terms'] as List<dynamic>? ?? const []),
      ),
      sourceName: json['source_name'] as String?,
      sourceUrl: json['source_url'] as String?,
    );
  }
}

class RiskProfileInput {
  RiskProfileInput({
    required this.appetite,
    this.horizonYears,
    this.monthlyInvestment,
    this.experienceLevel,
    this.primaryGoal,
    this.ageGroup,
    this.preferredSectors = const [],
    this.weeklyLearningMinutes,
  });

  final String appetite;
  final int? horizonYears;
  final int? monthlyInvestment;
  final String? experienceLevel;
  final String? primaryGoal;
  final String? ageGroup;
  final List<String> preferredSectors;
  final int? weeklyLearningMinutes;

  Map<String, dynamic> toJson() {
    return {
      'appetite': appetite,
      'horizon_years': horizonYears,
      'monthly_investment': monthlyInvestment,
      'experience_level': experienceLevel,
      'primary_goal': primaryGoal,
      'age_group': ageGroup,
      'preferred_sectors': preferredSectors,
      'weekly_learning_minutes': weeklyLearningMinutes,
    };
  }
}

class RiskProfileResponse extends RiskProfileInput {
  RiskProfileResponse({
    required super.appetite,
    super.horizonYears,
    super.monthlyInvestment,
    super.experienceLevel,
    super.primaryGoal,
    super.ageGroup,
    super.preferredSectors,
    super.weeklyLearningMinutes,
    required this.id,
    required this.createdAt,
  });

  final int id;
  final DateTime createdAt;

  factory RiskProfileResponse.fromJson(Map<String, dynamic> json) {
    return RiskProfileResponse(
      id: json['id'] as int,
      appetite: json['appetite'] as String,
      horizonYears: json['horizon_years'] as int?,
      monthlyInvestment: json['monthly_investment'] as int?,
      experienceLevel: json['experience_level'] as String?,
      primaryGoal: json['primary_goal'] as String?,
      ageGroup: json['age_group'] as String?,
      preferredSectors: List<String>.from(
        (json['preferred_sectors'] as List<dynamic>? ?? const []),
      ),
      weeklyLearningMinutes: json['weekly_learning_minutes'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class AuthUser {
  AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
  });

  final int id;
  final String email;
  final String? displayName;
  final DateTime createdAt;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class AuthSessionResponse {
  AuthSessionResponse({
    required this.user,
    required this.sessionToken,
    required this.expiresAt,
  });

  final AuthUser user;
  final String sessionToken;
  final DateTime expiresAt;

  factory AuthSessionResponse.fromJson(Map<String, dynamic> json) {
    return AuthSessionResponse(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      sessionToken: json['session_token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}

class AuthSessionStatus {
  AuthSessionStatus({required this.user, required this.expiresAt});

  final AuthUser user;
  final DateTime expiresAt;

  factory AuthSessionStatus.fromJson(Map<String, dynamic> json) {
    return AuthSessionStatus(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}

class SearchMeta {
  SearchMeta({required this.mode, required this.note, required this.asOf});

  final String mode;
  final String? note;
  final DateTime asOf;

  factory SearchMeta.fromJson(Map<String, dynamic> json) {
    return SearchMeta(
      mode: json['mode'] as String,
      note: json['note'] as String?,
      asOf: DateTime.parse(json['as_of'] as String),
    );
  }
}

class AssetSummary {
  AssetSummary({
    required this.id,
    required this.name,
    this.symbol,
    this.exchange,
    required this.assetType,
    this.category,
    required this.currency,
    required this.asOf,
    required this.valueLabel,
    required this.value,
    this.changePct,
    this.riskLevel,
    required this.tags,
  });

  final String id;
  final String name;
  final String? symbol;
  final String? exchange;
  final String assetType;
  final String? category;
  final String currency;
  final DateTime asOf;
  final String valueLabel;
  final double value;
  final double? changePct;
  final String? riskLevel;
  final List<String> tags;

  factory AssetSummary.fromJson(Map<String, dynamic> json) {
    return AssetSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String?,
      exchange: json['exchange'] as String?,
      assetType: json['asset_type'] as String,
      category: json['category'] as String?,
      currency: json['currency'] as String? ?? 'INR',
      asOf: DateTime.parse(json['as_of'] as String),
      valueLabel: json['value_label'] as String,
      value: (json['value'] as num).toDouble(),
      changePct: (json['change_pct'] as num?)?.toDouble(),
      riskLevel: json['risk_level'] as String?,
      tags: List<String>.from((json['tags'] as List<dynamic>? ?? const [])),
    );
  }
}

class SearchResponse {
  SearchResponse({required this.items, required this.meta});

  final List<AssetSummary> items;
  final SearchMeta meta;

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      items: (json['items'] as List<dynamic>)
          .map((item) => AssetSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: SearchMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class SourceAttribution {
  SourceAttribution({
    required this.id,
    required this.name,
    required this.kind,
    this.url,
    this.coverage,
    this.note,
  });

  final String id;
  final String name;
  final String kind;
  final String? url;
  final String? coverage;
  final String? note;

  factory SourceAttribution.fromJson(Map<String, dynamic> json) {
    return SourceAttribution(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: json['kind'] as String,
      url: json['url'] as String?,
      coverage: json['coverage'] as String?,
      note: json['note'] as String?,
    );
  }
}

class AssetListing {
  AssetListing({
    required this.exchange,
    required this.symbol,
    this.ticker,
    this.isin,
  });

  final String exchange;
  final String symbol;
  final String? ticker;
  final String? isin;

  factory AssetListing.fromJson(Map<String, dynamic> json) {
    return AssetListing(
      exchange: json['exchange'] as String,
      symbol: json['symbol'] as String,
      ticker: json['ticker'] as String?,
      isin: json['isin'] as String?,
    );
  }
}

class AssetSnapshot {
  AssetSnapshot({
    required this.asOf,
    required this.valueLabel,
    required this.value,
    this.prevValue,
    this.change,
    this.changePct,
    this.open,
    this.high,
    this.low,
    this.volume,
  });

  final DateTime asOf;
  final String valueLabel;
  final double value;
  final double? prevValue;
  final double? change;
  final double? changePct;
  final double? open;
  final double? high;
  final double? low;
  final double? volume;

  factory AssetSnapshot.fromJson(Map<String, dynamic> json) {
    return AssetSnapshot(
      asOf: DateTime.parse(json['as_of'] as String),
      valueLabel: json['value_label'] as String,
      value: (json['value'] as num).toDouble(),
      prevValue: (json['prev_value'] as num?)?.toDouble(),
      change: (json['change'] as num?)?.toDouble(),
      changePct: (json['change_pct'] as num?)?.toDouble(),
      open: (json['open'] as num?)?.toDouble(),
      high: (json['high'] as num?)?.toDouble(),
      low: (json['low'] as num?)?.toDouble(),
      volume: (json['volume'] as num?)?.toDouble(),
    );
  }
}

class AssetMetrics {
  AssetMetrics({
    this.marketCap,
    this.peRatio,
    this.pbRatio,
    this.dividendYield,
    this.eps,
    this.roe,
    this.debtToEquity,
    this.expenseRatio,
    this.aum,
  });

  final double? marketCap;
  final double? peRatio;
  final double? pbRatio;
  final double? dividendYield;
  final double? eps;
  final double? roe;
  final double? debtToEquity;
  final double? expenseRatio;
  final double? aum;

  factory AssetMetrics.fromJson(Map<String, dynamic> json) {
    return AssetMetrics(
      marketCap: (json['market_cap'] as num?)?.toDouble(),
      peRatio: (json['pe_ratio'] as num?)?.toDouble(),
      pbRatio: (json['pb_ratio'] as num?)?.toDouble(),
      dividendYield: (json['dividend_yield'] as num?)?.toDouble(),
      eps: (json['eps'] as num?)?.toDouble(),
      roe: (json['roe'] as num?)?.toDouble(),
      debtToEquity: (json['debt_to_equity'] as num?)?.toDouble(),
      expenseRatio: (json['expense_ratio'] as num?)?.toDouble(),
      aum: (json['aum'] as num?)?.toDouble(),
    );
  }
}

class PlanDetails {
  PlanDetails({
    this.planType,
    this.provider,
    this.minInvestment,
    this.minSip,
    this.lockInMonths,
    this.payoutFrequency,
    this.taxBenefit,
    this.riskLevel,
    this.expenseRatio,
  });

  final String? planType;
  final String? provider;
  final int? minInvestment;
  final int? minSip;
  final int? lockInMonths;
  final String? payoutFrequency;
  final String? taxBenefit;
  final String? riskLevel;
  final double? expenseRatio;

  factory PlanDetails.fromJson(Map<String, dynamic> json) {
    return PlanDetails(
      planType: json['plan_type'] as String?,
      provider: json['provider'] as String?,
      minInvestment: json['min_investment'] as int?,
      minSip: json['min_sip'] as int?,
      lockInMonths: json['lock_in_months'] as int?,
      payoutFrequency: json['payout_frequency'] as String?,
      taxBenefit: json['tax_benefit'] as String?,
      riskLevel: json['risk_level'] as String?,
      expenseRatio: (json['expense_ratio'] as num?)?.toDouble(),
    );
  }
}

class AssetDetail {
  AssetDetail({
    required this.summary,
    this.description,
    required this.listings,
    required this.snapshot,
    this.metrics,
    this.planDetails,
    required this.sources,
  });

  final AssetSummary summary;
  final String? description;
  final List<AssetListing> listings;
  final AssetSnapshot snapshot;
  final AssetMetrics? metrics;
  final PlanDetails? planDetails;
  final List<SourceAttribution> sources;

  factory AssetDetail.fromJson(Map<String, dynamic> json) {
    return AssetDetail(
      summary: AssetSummary.fromJson(json['summary'] as Map<String, dynamic>),
      description: json['description'] as String?,
      listings: (json['listings'] as List<dynamic>? ?? const [])
          .map((item) => AssetListing.fromJson(item as Map<String, dynamic>))
          .toList(),
      snapshot: AssetSnapshot.fromJson(
        json['snapshot'] as Map<String, dynamic>,
      ),
      metrics: json['metrics'] == null
          ? null
          : AssetMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      planDetails: json['plan_details'] == null
          ? null
          : PlanDetails.fromJson(json['plan_details'] as Map<String, dynamic>),
      sources: (json['sources'] as List<dynamic>? ?? const [])
          .map(
            (item) => SourceAttribution.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class AssetDetailResponse {
  AssetDetailResponse({required this.asset, required this.meta});

  final AssetDetail asset;
  final SearchMeta meta;

  factory AssetDetailResponse.fromJson(Map<String, dynamic> json) {
    return AssetDetailResponse(
      asset: AssetDetail.fromJson(json['asset'] as Map<String, dynamic>),
      meta: SearchMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}
