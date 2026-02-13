import 'package:arivest/data/models.dart';

final sampleResearchFeed = [
  ResearchItem(
    id: 'sample-1',
    title: 'Reading market cycles',
    summary: 'A quick look at how cycles affect long-term investors.',
    tags: const ['basics', 'cycles'],
    publishedAt: DateTime(2026, 2, 10),
    sourceName: 'NSE Milestones',
    sourceUrl: 'https://www.nseindia.com/about/milestones',
    matchReasons: const ['Matches your experience level'],
    matchScore: 3,
  ),
  ResearchItem(
    id: 'sample-2',
    title: 'Mutual fund disclosures that matter',
    summary: 'How risk-adjusted disclosures help compare funds.',
    tags: const ['mutual-fund', 'risk'],
    publishedAt: DateTime(2026, 2, 9),
    sourceName: 'SEBI Circulars',
    sourceUrl:
        'https://www.sebi.gov.in/legal/circulars/jan-2025/disclosure-of-risk-adjusted-return-by-mutual-funds_89961.html',
    matchReasons: const ['Aligned with your risk appetite'],
    matchScore: 2,
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
    whyItMatters: 'Helps compare company size and risk profile.',
    example:
        'If 100 crore shares trade at INR 500, market cap is INR 50,000 crore.',
    riskNote:
        'Large companies can still underperform during sector or governance stress.',
    relatedTerms: const ['Large Cap', 'Mid Cap', 'Small Cap'],
    sourceName: 'SEBI Master Circular - Mutual Funds',
    sourceUrl:
        'https://www.sebi.gov.in/legal/master-circulars/jun-2024/master-circular-for-mutual-funds_83277.html',
  ),
];

final sampleSearchResponse = SearchResponse(
  items: [
    AssetSummary(
      id: 'stock-reliance',
      name: 'Reliance Industries Ltd',
      symbol: 'RELIANCE',
      exchange: 'NSE/BSE',
      assetType: 'stock',
      category: 'Large Cap',
      currency: 'INR',
      asOf: DateTime(2026, 2, 10),
      valueLabel: 'Close',
      value: 2940.25,
      changePct: 0.8,
      riskLevel: 'moderate',
      tags: const ['energy', 'conglomerate'],
    ),
  ],
  meta: SearchMeta(
    mode: 'demo',
    note: 'Sample values for UI development only.',
    asOf: DateTime(2026, 2, 10),
  ),
);

final sampleAssetDetailResponse = AssetDetailResponse(
  asset: AssetDetail(
    summary: sampleSearchResponse.items.first,
    description: 'Diversified Indian conglomerate with energy and retail arms.',
    listings: [
      AssetListing(
        exchange: 'NSE',
        symbol: 'RELIANCE',
        ticker: 'RELIANCE',
        isin: 'INE002A01018',
      ),
      AssetListing(
        exchange: 'BSE',
        symbol: '500325',
        ticker: 'RELIANCE',
        isin: 'INE002A01018',
      ),
    ],
    snapshot: AssetSnapshot(
      asOf: DateTime(2026, 2, 10),
      valueLabel: 'Close',
      value: 2940.25,
      prevValue: 2916.0,
      change: 24.25,
      changePct: 0.8,
      open: 2922.5,
      high: 2958.0,
      low: 2904.3,
      volume: 8123456,
    ),
    metrics: AssetMetrics(
      marketCap: 1900000,
      peRatio: 24.5,
      pbRatio: 2.1,
      dividendYield: 0.4,
      roe: 9.6,
    ),
    planDetails: null,
    sources: [
      SourceAttribution(
        id: 'bse-bhavcopy',
        name: 'BSE BhavCopy',
        kind: 'market_data',
        url: 'https://www.bseindia.com/markets/MarketInfo/BhavCopy.aspx',
        coverage: 'BSE equities',
        note: 'Daily end of day prices.',
      ),
    ],
  ),
  meta: SearchMeta(
    mode: 'demo',
    note: 'Sample values for UI development only.',
    asOf: DateTime(2026, 2, 10),
  ),
);

final samplePlanAssetDetailResponse = AssetDetailResponse(
  asset: AssetDetail(
    summary: AssetSummary(
      id: 'mf-sbi-bluechip',
      name: 'SBI Bluechip Fund Direct Plan Growth',
      symbol: 'SBIBLUECHIP',
      exchange: 'AMFI',
      assetType: 'mutual_fund',
      category: 'Large Cap Fund',
      currency: 'INR',
      asOf: DateTime(2026, 2, 10),
      valueLabel: 'NAV',
      value: 78.45,
      changePct: 0.35,
      riskLevel: 'moderate',
      tags: const ['mutual fund', 'large cap'],
    ),
    description:
        'Large cap equity mutual fund focused on established companies.',
    listings: [
      AssetListing(
        exchange: 'AMFI',
        symbol: 'SBIBLUECHIP',
        ticker: 'SBI Bluechip Direct',
        isin: 'INF200K01T95',
      ),
    ],
    snapshot: AssetSnapshot(
      asOf: DateTime(2026, 2, 10),
      valueLabel: 'NAV',
      value: 78.45,
      prevValue: 78.18,
      change: 0.27,
      changePct: 0.35,
      open: null,
      high: null,
      low: null,
      volume: null,
    ),
    metrics: AssetMetrics(expenseRatio: 0.7, aum: 35000),
    planDetails: PlanDetails(
      planType: 'mutual_fund',
      provider: 'SBI Mutual Fund',
      minInvestment: 500,
      minSip: 500,
      lockInMonths: 0,
      payoutFrequency: 'daily NAV',
      taxBenefit: 'None',
      riskLevel: 'moderate',
      expenseRatio: 0.7,
    ),
    sources: [
      SourceAttribution(
        id: 'amfi-nav',
        name: 'AMFI NAVAll',
        kind: 'market_data',
        url: 'https://www.amfiindia.com/spages/NAVAll.txt',
        coverage: 'Indian mutual funds',
        note: 'Official daily NAV file.',
      ),
    ],
  ),
  meta: SearchMeta(
    mode: 'demo',
    note: 'Sample values for UI development only.',
    asOf: DateTime(2026, 2, 10),
  ),
);

final sampleAuthUser = AuthUser(
  id: 1,
  email: 'demo@arivest.in',
  displayName: 'Demo User',
  createdAt: DateTime(2026, 2, 10),
);

final sampleAuthSessionResponse = AuthSessionResponse(
  user: sampleAuthUser,
  sessionToken: 'sample-session-token',
  expiresAt: DateTime(2026, 2, 20),
);

final sampleAuthSessionStatus = AuthSessionStatus(
  user: sampleAuthUser,
  expiresAt: DateTime(2026, 2, 20),
);
