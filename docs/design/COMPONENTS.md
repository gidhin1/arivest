# Arivest Components
Last updated: 2026-02-10

## Buttons
- Primary: FilledButton with primary color
- Secondary: FilledButton.tonal with surface emphasis
- Outline: OutlinedButton for secondary actions
- Text: TextButton for low-priority actions
- Size: 48 height minimum, radius 16
- Disabled: reduce opacity, keep readable contrast

## App Bar
- Title in Merriweather, size 18–22
- No heavy shadows
- Actions on right, max 2

## Navigation
- Bottom navigation for mobile and web
- Optional navigation rail at 900+ width
- Always show labels

## Cards
- Surface color, radius 20, no elevation
- Card header uses title style, body uses bodyMedium
- Keep cards single-purpose

## Lists
- Use ListTile for research feed and glossary
- Leading icons optional, avoid icon overload
- Use clear trailing metadata only

## Forms
- Inputs are filled with subtle border
- Error text appears below, single line
- Validation must be specific and actionable

## Chips
- Use for tags, categories, and status
- Do not use chips as primary actions

## Section Headers
- Title + short subtitle
- Optional trailing action

## Policy Notice
- Use PolicyNotice for the past-only research rule
- Keep text short and neutral
- Use once per screen at most

## Loading States
- Use skeletons for list content
- Use inline progress indicator for forms

## Empty States
- Clear statement of why it is empty
- Provide one primary action

## Toasts and Alerts
- Use SnackBar for temporary messages
- Use Dialog only for destructive actions

## Data Cards
- Use StatChip or small summary cards
- Avoid heavy charting in small cards

## Responsive Rules
- Cards always full width on mobile
- Allow 2-column grids only for summary content at 900+
- Keep navigation consistent across platforms
