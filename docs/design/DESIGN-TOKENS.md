# Arivest Design Tokens
Last updated: 2026-02-10

Source of truth: `app/assets/design_tokens.json`

Any token change should be done in the JSON file first. Flutter reads this file at runtime via `DesignSystem.load()`. If you change the JSON, restart the app to see updates.

## Colors
| Token | Hex | Usage |
| --- | --- | --- |
| primary | #0F6C5C | Primary actions, highlights |
| secondary | #C0762B | Accent, chips, highlights |
| background | #F4F1EA | App background |
| surface | #F7F3EC | Cards, sheets |
| onSurface | #1E2B23 | Primary text |
| outline | #9C948A | Borders, dividers |
| error | #B3261E | Error text, error states |
| success | #1E7B4B | Success messaging |
| warning | #C78B1B | Warning messaging |
| info | #2B5FC0 | Informational messaging |

## Typography
Fonts
- Headings: Merriweather
- Body: Work Sans

Type scale
| Token | Size | Line Height | Weight |
| --- | --- | --- | --- |
| displayLarge | 32 | 40 | 700 |
| headlineLarge | 26 | 34 | 700 |
| headlineMedium | 22 | 30 | 700 |
| titleLarge | 18 | 26 | 600 |
| titleMedium | 16 | 24 | 600 |
| bodyLarge | 16 | 24 | 400 |
| bodyMedium | 14 | 22 | 400 |
| labelLarge | 13 | 18 | 600 |
| labelSmall | 11 | 16 | 600 |

## Spacing
- Base grid: 8
- Scale: 4, 8, 12, 16, 20, 24, 32, 40, 48

## Radius
- Input fields: 16
- Cards: 20
- Chips: 12
- Buttons: 16

## Elevation
- Default cards: 0
- Floating surfaces: 1–2

## Iconography
- Use Material Icons Outlined for default, filled for selected states.
- Icon size: 20 in lists, 24 in nav.

## Breakpoints
- Mobile: 0–599
- Tablet: 600–899
- Desktop: 900–1199
- Wide: 1200+
