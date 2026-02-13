class RiskProfileDraft {
  const RiskProfileDraft({
    this.appetite = 'moderate',
    this.experienceLevel = 'beginner',
    this.primaryGoal = 'wealth_creation',
    this.ageGroup = '26-35',
    this.preferredSectors = const [],
    this.weeklyLearningMinutes,
    this.horizonYears,
    this.monthlyInvestment,
  });

  final String appetite;
  final String experienceLevel;
  final String primaryGoal;
  final String ageGroup;
  final List<String> preferredSectors;
  final int? weeklyLearningMinutes;
  final int? horizonYears;
  final int? monthlyInvestment;

  RiskProfileDraft copyWith({
    String? appetite,
    String? experienceLevel,
    String? primaryGoal,
    String? ageGroup,
    List<String>? preferredSectors,
    int? weeklyLearningMinutes,
    int? horizonYears,
    int? monthlyInvestment,
  }) {
    return RiskProfileDraft(
      appetite: appetite ?? this.appetite,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      ageGroup: ageGroup ?? this.ageGroup,
      preferredSectors: preferredSectors ?? this.preferredSectors,
      weeklyLearningMinutes:
          weeklyLearningMinutes ?? this.weeklyLearningMinutes,
      horizonYears: horizonYears ?? this.horizonYears,
      monthlyInvestment: monthlyInvestment ?? this.monthlyInvestment,
    );
  }
}
