# Arivest Responsive Layout Guide
Last updated: 2026-02-10

## Breakpoints
- Mobile: 0–599
- Tablet: 600–899
- Desktop: 900–1199
- Wide: 1200+

## Layout Rules
1. Use a single content column by default.
2. Maintain the same information order across all breakpoints.
3. Increase whitespace on tablet and desktop, but do not add new content blocks.
4. Keep max content width at 960.
5. Use two columns only for summary cards at 900+.

## Navigation Behavior
- Mobile: Bottom navigation with labels.
- Tablet: Bottom navigation with labels. Optional nav rail only if the screen is data-heavy.
- Desktop: Bottom navigation remains unless a nav rail improves discoverability.

## Page Templates
### Onboarding
- Mobile: Single column form, stacked sections.
- Tablet: Same layout, increase padding to 20.
- Desktop: Centered card with max width 640, left-aligned text.

### Home
- Mobile: Profile card, then research feed list.
- Tablet: Same, increase spacing between sections.
- Desktop: Profile card full width, research list below. Optional two-column summary row only for quick stats.

### Model Portfolios
- Mobile: One portfolio per card stacked.
- Tablet: Same, add spacing between cards.
- Desktop: Two-column grid allowed if cards are short. Keep allocation details in full width when expanded.

### Glossary
- Mobile: One term per card stacked.
- Tablet: Same, add spacing.
- Desktop: Two-column only if term list is long and cards are short.

### Profile
- Mobile: Cards stacked, primary actions at bottom.
- Tablet: Same layout with increased padding.
- Desktop: Cards remain stacked to avoid fragmentation.

## Component Responsiveness
- Buttons: Full-width on mobile for primary actions. Auto width on tablet and desktop.
- Forms: Input fields are full width. Avoid multi-column forms unless screen is 1200+.
- Lists: Use ListTile layout; avoid dense rows on mobile.
- Cards: Keep 16–20 padding on mobile, 20–24 on tablet/desktop.

## Typography Responsiveness
- Headings scale up by one step at 900+ width.
- Body text size remains stable for readability.
- Keep line length at 45–80 characters.

## Motion and Performance
- Avoid heavy animations on web.
- Prefer staggered list reveals with 120–180ms delay.
- Use skeletons instead of complex placeholders.

## QA Checklist
1. All screens readable at 320px width.
2. No clipped text at 200% text scale.
3. Bottom nav does not overlap content.
4. Max width enforced on desktop.
5. Tap targets remain 44x44 or larger.
