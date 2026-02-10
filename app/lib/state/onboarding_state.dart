class RiskProfileDraft {
  const RiskProfileDraft({
    this.appetite = 'moderate',
    this.horizonYears,
    this.monthlyInvestment,
  });

  final String appetite;
  final int? horizonYears;
  final int? monthlyInvestment;

  RiskProfileDraft copyWith({
    String? appetite,
    int? horizonYears,
    int? monthlyInvestment,
  }) {
    return RiskProfileDraft(
      appetite: appetite ?? this.appetite,
      horizonYears: horizonYears ?? this.horizonYears,
      monthlyInvestment: monthlyInvestment ?? this.monthlyInvestment,
    );
  }
}
