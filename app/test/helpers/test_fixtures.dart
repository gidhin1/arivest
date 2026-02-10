import 'package:arivest/data/models.dart';

final sampleResearchFeed = [
  ResearchItem(
    id: 'sample-1',
    title: 'Reading market cycles',
    summary: 'A quick look at how cycles affect long-term investors.',
    tags: const ['basics', 'cycles'],
    publishedAt: DateTime(2026, 2, 10),
  ),
];

final samplePortfolios = [
  ModelPortfolio(
    id: 'model-1',
    name: 'Balanced Learner',
    riskLevel: 'moderate',
    description: 'Diversified allocation for steady learning.',
    allocations: [
      Allocation(label: 'Large Cap Index', weight: 40),
      Allocation(label: 'Mid Cap Index', weight: 30),
      Allocation(label: 'Sector Basket', weight: 20),
      Allocation(label: 'Cash (Education only)', weight: 10),
    ],
  ),
];

final sampleGlossary = [
  GlossaryTerm(
    term: 'Market Cap',
    definition: 'Total market value of outstanding shares.',
  ),
];
