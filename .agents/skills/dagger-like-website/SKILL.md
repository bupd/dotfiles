---
name: dagger-like-website
description: >
  Build dagger.io-inspired project landing pages and documentation sites using
  pure CSS (CSS Layers, OKLCH colors, BEM naming). Use when creating marketing
  websites, project homepages, docs sites, or landing pages that follow the
  dagger.io aesthetic: warm cream canvas, navy ink, generous whitespace, rounded
  white cards. Triggers: "landing page", "project site", "docs site",
  "dagger style", "marketing page", "product page", "harbor satellite site",
  or building any static site with this visual language. Works with Hugo or
  standalone HTML. Do NOT use for dashboard/app UI.
---

# Dagger-like Website

Build project landing pages and documentation sites following the dagger.io visual language: warm cream backgrounds, navy-tinted neutrals, generous whitespace, rounded card layouts.

## Workflow

1. **Determine page type**: Landing page, docs page, or blog layout
2. **Choose base**: Hugo integration or standalone HTML
3. **Build sections** using the component patterns below
4. **Apply design tokens** from references/design-tokens.md
5. **Add responsive styles** at standard breakpoints

## Design Identity

Warm, open, technical-but-approachable. Cream paper, navy ink, generous air.

- Cream canvas (`oklch(96.5% 0.015 80)`) -- never pure white backgrounds
- Navy ink for text (`oklch(15% 0.04 280)`) -- never pure black
- Sections breathe with 100-160px vertical padding
- White cards on cream: `border-radius: 16px`, no visible borders
- Accents (teal, orange, yellow) used sparingly in visuals, not text
- Headings are large but light-weight (400), not bold

## CSS Stack

Pure CSS, no preprocessors, no build step for styles.

```css
@layer reset, base, components, utilities;
```

- **OKLCH color space** with two-tier tokens (raw values + semantic names)
- **BEM naming** (`.block__element--modifier`) for all components
- **CSS custom properties** for all shared values
- **Native CSS nesting** for pseudo-classes, media queries, child selectors only

### Critical Rule

**No `&__element` BEM nesting.** Native CSS `&` is NOT string concatenation. `.navbar { &__inner {} }` produces `.navbar .navbar__inner`, not `.navbar__inner`. Keep BEM selectors flat.

Valid nesting: `&:hover`, `&::before`, `& svg`, `@media` blocks.

## Landing Page Sections

A typical page flows top-to-bottom:

1. **Navbar** -- Fixed top, logo left, links center, CTA right (navy button)
2. **Hero** -- Two-column: title + subtitle + CTA left, visual right
3. **Logo ticker** -- Horizontal muted logo row (or problem statement)
4. **Feature cards** -- Stacked white cards, text left + colored visual right
5. **Community** -- Centered header + 3-column card grid
6. **Newsletter** -- Email input + submit button
7. **Footer** -- Dark navy, logo + link columns + social icons

Each section component is documented with HTML structure and key CSS in references/components.md.

## Documentation Layout

- Sidebar navigation (left, 16rem) + content area (right, fluid)
- Prose styling for markdown: `--text-base`, `--leading-relaxed`, max-width 48rem
- Code blocks: dark navy background
- Callout boxes: teal border-left for info, orange for warnings

See references/docs-layout.md for full docs patterns.

## Responsive Breakpoints

```
1024px  -- tablet: 2-col to 1-col, reduce padding
768px   -- mobile: hide nav links, stack everything
480px   -- small mobile: reduce font sizes, tighter spacing
```

Responsive styles go OUTSIDE layers (for cascade override).

## Hugo Integration

When using Hugo, CSS files go in `themes/<theme>/assets/css/dagger/`. Files are concatenated via `resources.Concat` (Hugo does NOT resolve `@import`).

To add a new component:
1. Create `assets/css/dagger/components/my-component.css`
2. Wrap in `@layer components { }`
3. Register in `layouts/partials/dagger/css.html`

Two base templates:
- `index-baseof.html` -- Homepage only (inline CSS)
- `_default/baseof.html` -- All other pages (loads dagger CSS partial)

## CSS Framework Compatibility

This skill aligns with the container-registry/css-framework spec (same layers, tokens, BEM). The framework adds dashboard components (sidebar, table, modal) not used in landing pages but available for docs pages needing richer UI.

## Reference Files

- **Design tokens**: See references/design-tokens.md for full color, spacing, typography, and layout token values
- **Component patterns**: See references/components.md for HTML structure and CSS for each landing page section
- **Docs layout**: See references/docs-layout.md for documentation page patterns
- **Template**: The assets/ directory contains a complete dagger-clone HTML/CSS prototype that can be used as a starting point
