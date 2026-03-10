# Design Tokens

Complete token values for the dagger-like design system.

## Two-Tier Color System

Tier 1 stores raw OKLCH lightness/chroma/hue. Tier 2 maps to semantic names.

```css
:root {
  /* Tier 1: Raw OKLCH values */
  --lch-cream: 96.5% 0.015 80;
  --lch-navy: 18% 0.04 280;
  --lch-navy-deep: 16% 0.04 280;
  --lch-white: 100% 0 0;
  --lch-teal: 70% 0.1 190;
  --lch-orange: 65% 0.18 50;
  --lch-yellow: 82% 0.17 90;
  --lch-gray-light: 92% 0.01 280;
  --lch-ink: 15% 0.04 280;
  --lch-ink-muted: 40% 0.02 280;

  /* Tier 2: Semantic colors */
  --color-canvas: oklch(var(--lch-cream));
  --color-surface: oklch(var(--lch-white));
  --color-ink: oklch(var(--lch-ink));
  --color-ink-muted: oklch(var(--lch-ink-muted));
  --color-navy: oklch(var(--lch-navy));
  --color-navy-deep: oklch(var(--lch-navy-deep));
  --color-teal: oklch(var(--lch-teal));
  --color-orange: oklch(var(--lch-orange));
  --color-yellow: oklch(var(--lch-yellow));
  --color-border: oklch(var(--lch-gray-light));
}
```

## Spacing

```css
--space-1:  0.25rem;   /* 4px */
--space-2:  0.5rem;    /* 8px */
--space-3:  0.75rem;   /* 12px */
--space-4:  1rem;      /* 16px */
--space-5:  1.25rem;   /* 20px */
--space-6:  1.5rem;    /* 24px */
--space-8:  2rem;      /* 32px */
--space-10: 2.5rem;    /* 40px */
--space-12: 3rem;      /* 48px */
--space-16: 4rem;      /* 64px */
--space-20: 5rem;      /* 80px */
--space-24: 6rem;      /* 96px */
--space-32: 8rem;      /* 128px */
```

## Typography

```css
/* Fonts */
--font-sans: "General Sans", system-ui, -apple-system, sans-serif;
--font-mono: "Source Code Pro", ui-monospace, monospace;

/* Scale */
--text-xs:   0.75rem;   /* 12px */
--text-sm:   0.875rem;  /* 14px */
--text-base: 1rem;      /* 16px */
--text-lg:   1.125rem;  /* 18px */
--text-xl:   1.25rem;   /* 20px */
--text-2xl:  1.5rem;    /* 24px */
--text-3xl:  2.5rem;    /* 40px */
--text-4xl:  3.5rem;    /* 56px */

/* Weights */
--weight-regular:  400;
--weight-medium:   500;
--weight-semibold: 600;

/* Line height */
--leading-tight:   1.1;
--leading-snug:    1.3;
--leading-normal:  1.4;
--leading-relaxed: 1.6;
```

## Layout

```css
--page-max-width: 1200px;
--page-padding:   60px;
--navbar-height:  69px;   /* can vary 69-93px */
```

## Borders and Radius

```css
--radius-sm:   4px;
--radius-md:   8px;
--radius-lg:   16px;
--radius-xl:   24px;
--radius-full: 9999px;
```

## Shadows

```css
--shadow-sm: 0 1px 2px oklch(0% 0 0 / 0.05);
--shadow-md: 0 4px 12px oklch(0% 0 0 / 0.08);
```

## Z-Index

```css
--z-base:   1;
--z-navbar: 10;
--z-modal:  100;
```

## Footer Dark Background

The footer uses a specific dark navy: `rgb(26, 24, 51)` or approximately `oklch(16% 0.04 280)`.
