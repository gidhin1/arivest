from datetime import date

research_feed = [
    {
        "id": "feed-001",
        "title": "How to read a balance sheet (India)",
        "summary": "A beginner-friendly guide to assets, liabilities, and what matters most for equity research.",
        "tags": ["basics", "fundamentals"],
        "published_at": date(2026, 2, 1),
    },
    {
        "id": "feed-002",
        "title": "Understanding sector cycles in Indian equities",
        "summary": "Why sectors rotate, and how long-term investors can interpret these shifts without trading.",
        "tags": ["sectors", "cycles"],
        "published_at": date(2026, 2, 3),
    },
    {
        "id": "feed-003",
        "title": "Risk and return: what the numbers really mean",
        "summary": "Volatility, drawdowns, and why risk appetite should match your horizon.",
        "tags": ["risk", "basics"],
        "published_at": date(2026, 2, 6),
    },
]

model_portfolios = [
    {
        "id": "model-conservative",
        "name": "Conservative Learner",
        "risk_level": "conservative",
        "description": "Stability-first allocation with broad diversification.",
        "allocations": [
            {"label": "Large Cap Index (NIFTY 50 ETF)", "weight": 40},
            {"label": "Low Volatility Index", "weight": 20},
            {"label": "Banking & Financials Basket", "weight": 20},
            {"label": "Cash/Liquid (Education only)", "weight": 20},
        ],
    },
    {
        "id": "model-moderate",
        "name": "Balanced Learner",
        "risk_level": "moderate",
        "description": "Blend of stability and growth across caps and sectors.",
        "allocations": [
            {"label": "Large Cap Index (NIFTY 50 ETF)", "weight": 35},
            {"label": "Mid Cap Index", "weight": 25},
            {"label": "IT & Tech Basket", "weight": 20},
            {"label": "Consumer Basket", "weight": 10},
            {"label": "Cash/Liquid (Education only)", "weight": 10},
        ],
    },
    {
        "id": "model-aggressive",
        "name": "Growth Learner",
        "risk_level": "aggressive",
        "description": "Higher growth tilt with mid/small caps and themes.",
        "allocations": [
            {"label": "Mid Cap Index", "weight": 30},
            {"label": "Small Cap Index", "weight": 25},
            {"label": "Capital Goods & Infra Basket", "weight": 20},
            {"label": "Financials Basket", "weight": 15},
            {"label": "Renewables/Transition Theme", "weight": 10},
        ],
    },
]

glossary_terms = [
    {
        "term": "P/E Ratio",
        "definition": "Price-to-earnings ratio, a common valuation measure based on earnings per share.",
    },
    {
        "term": "Market Cap",
        "definition": "Total market value of a company's outstanding shares.",
    },
    {
        "term": "Volatility",
        "definition": "How much a price moves over time; a proxy for risk.",
    },
    {
        "term": "Diversification",
        "definition": "Spreading exposure across assets to reduce concentrated risk.",
    },
]
