# Arivest UI/UX Rules
Last updated: 2026-02-10

## Purpose
Arivest is an education and research product. The UI must feel calm, trustworthy, and bias-free while guiding beginners and intermediates. The experience must be consistent across mobile, web, and tablet, with responsive layouts that preserve the same hierarchy.

## Principles
1. Clarity first. Reduce cognitive load and avoid busy layouts.
2. Educational tone. Use neutral language, avoid buy/sell framing.
3. Past-only research. Content must be historical, source-backed, and time-stamped.
4. No predictions. Do not forecast the future; the future is in the customer's hands.
5. Visual hierarchy. Titles, summaries, and actions must be scannable.
6. Consistency. Same tokens, components, and spacing on all platforms.
7. Calm motion. Motion should support comprehension, not entertain.
8. Accessibility. Contrast, tap sizes, and readable type are mandatory.

## Cross-Platform Consistency
- Use the same design tokens across all platforms.
- Keep the same layout hierarchy and component styles on mobile and web.
- Allow layout adjustments by breakpoint, but do not change meaning or order.
- Preserve identical spacing, typography sizes, and component shapes.

## Layout and Grid
- Use an 8-pt spacing grid.
- Default page padding: 24 on web, 20 on tablet, 16 on mobile.
- Max content width: 960.
- Text line length: 45–80 characters for body content.
- Align cards, lists, and sections to a single content column.

## Responsive Behavior
- Breakpoints
- 0–599: mobile layout
- 600–899: tablet layout
- 900–1199: compact desktop layout
- 1200+: wide desktop layout

- Navigation
- Mobile: bottom navigation bar
- Tablet and desktop: bottom nav by default, optional navigation rail if screen width is 900+

- Cards and lists
- Mobile: 1 column
- Tablet: 1 column, increase spacing
- Desktop: 2 columns only for non-critical overview cards

## Typography
- Use the Arivest type scale and tokens.
- Headings use a serif to convey trust.
- Body uses a clean sans to improve readability.
- Keep heading weights at 600–700. Avoid extra bold body text.

## Color Usage
- Primary color is reserved for key actions.
- Secondary color is for highlights and informational chips.
- Backgrounds are warm and neutral. No pure white panels.
- Error color must be used for validation and critical messages only.

## Components
- All components must be documented in COMPONENTS.md.
- If a component does not exist, build it once and reuse.
- Avoid one-off styling inside screens.

## Data and Charts
- Use neutral, educational phrasing.
- Always show date range and data freshness label.
- Use a limited palette and avoid red/green only for meaning.

## States and Feedback
- Loading: show skeleton or inline loader.
- Empty: explain why it is empty and what to do next.
- Error: show a friendly message and allow retry.

## Motion
- Page transitions: 200–250ms, easeOut.
- Micro-interactions: 120–180ms.
- Avoid bounce or dramatic motion.

## Accessibility
- Minimum tap target: 44x44.
- Contrast ratio: 4.5:1 for body text.
- Support system text scaling without breaking layout.

## Governance
- Source of truth for tokens is `app/assets/design_tokens.json`.
- Flutter maps tokens through `app/lib/design_system.dart`.
- Any new component must be documented before it is used in production screens.
- Changes to typography or colors must be updated in both docs and design tokens JSON.
