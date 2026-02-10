class ResearchItem {
  ResearchItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.tags,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String summary;
  final List<String> tags;
  final DateTime publishedAt;

  factory ResearchItem.fromJson(Map<String, dynamic> json) {
    return ResearchItem(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      tags: List<String>.from(json['tags'] as List<dynamic>),
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }
}

class Allocation {
  Allocation({
    required this.label,
    required this.weight,
  });

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
  });

  final String term;
  final String definition;

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) {
    return GlossaryTerm(
      term: json['term'] as String,
      definition: json['definition'] as String,
    );
  }
}

class RiskProfileInput {
  RiskProfileInput({
    required this.appetite,
    this.horizonYears,
    this.monthlyInvestment,
  });

  final String appetite;
  final int? horizonYears;
  final int? monthlyInvestment;

  Map<String, dynamic> toJson() {
    return {
      'appetite': appetite,
      'horizon_years': horizonYears,
      'monthly_investment': monthlyInvestment,
    };
  }
}

class RiskProfileResponse extends RiskProfileInput {
  RiskProfileResponse({
    required super.appetite,
    super.horizonYears,
    super.monthlyInvestment,
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
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
