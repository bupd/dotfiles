# Documentation Layout Patterns

Patterns for building documentation pages in the dagger-like style.

## Page Structure

```html
<div class="docs">
  <aside class="docs__sidebar">
    <nav class="docs-nav">
      <div class="docs-nav__section">
        <p class="docs-nav__title">Getting Started</p>
        <a href="#" class="docs-nav__link docs-nav__link--active">Quick Start</a>
        <a href="#" class="docs-nav__link">Installation</a>
      </div>
      <div class="docs-nav__section">
        <p class="docs-nav__title">Architecture</p>
        <a href="#" class="docs-nav__link">Overview</a>
        <a href="#" class="docs-nav__link">Components</a>
      </div>
    </nav>
  </aside>
  <main class="docs__content">
    <article class="prose">
      <!-- Markdown-rendered content -->
    </article>
  </main>
</div>
```

## Sidebar CSS

```css
@layer components {
  .docs {
    display: grid;
    grid-template-columns: 16rem 1fr;
    min-height: calc(100dvh - var(--navbar-height));
  }

  .docs__sidebar {
    position: sticky;
    top: var(--navbar-height);
    height: calc(100dvh - var(--navbar-height));
    overflow-y: auto;
    padding: var(--space-8) var(--space-6);
    border-right: 1px solid var(--color-border);
  }

  .docs-nav__section {
    margin-bottom: var(--space-6);
  }

  .docs-nav__title {
    font-size: var(--text-xs);
    font-weight: var(--weight-semibold);
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: var(--color-ink-muted);
    margin-bottom: var(--space-2);
  }

  .docs-nav__link {
    display: block;
    padding: var(--space-1) var(--space-3);
    font-size: var(--text-sm);
    color: var(--color-ink-muted);
    border-radius: var(--radius-sm);
    transition: color 0.15s ease, background 0.15s ease;
  }

  .docs-nav__link:hover {
    color: var(--color-ink);
    opacity: 1;
  }

  .docs-nav__link--active {
    color: var(--color-ink);
    background: var(--color-border);
    font-weight: var(--weight-medium);
  }
}
```

## Content Area CSS

```css
@layer components {
  .docs__content {
    padding: var(--space-8) var(--space-12);
    max-width: 48rem;
  }
}
```

## Prose Styling

For markdown-rendered content inside `.prose`:

```css
@layer components {
  .prose {
    font-size: var(--text-base);
    line-height: var(--leading-relaxed);
    color: var(--color-ink);
  }

  .prose h2 {
    font-size: var(--text-2xl);
    font-weight: var(--weight-medium);
    margin-top: var(--space-12);
    margin-bottom: var(--space-4);
    padding-bottom: var(--space-2);
    border-bottom: 1px solid var(--color-border);
  }

  .prose h3 {
    font-size: var(--text-xl);
    font-weight: var(--weight-medium);
    margin-top: var(--space-8);
    margin-bottom: var(--space-3);
  }

  .prose p {
    margin-bottom: var(--space-4);
  }

  .prose a {
    color: var(--color-teal);
    text-decoration: underline;
    text-underline-offset: 2px;
  }

  .prose code {
    font-family: var(--font-mono);
    font-size: 0.875em;
    background: var(--color-border);
    padding: 2px 6px;
    border-radius: var(--radius-sm);
  }

  .prose pre {
    background: oklch(var(--lch-navy-deep));
    color: oklch(90% 0.01 80);
    padding: var(--space-4) var(--space-6);
    border-radius: var(--radius-md);
    overflow-x: auto;
    margin-bottom: var(--space-6);
  }

  .prose pre code {
    background: none;
    padding: 0;
    font-size: var(--text-sm);
  }

  .prose ul, .prose ol {
    padding-left: var(--space-6);
    margin-bottom: var(--space-4);
  }

  .prose li {
    margin-bottom: var(--space-2);
  }

  .prose table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: var(--space-6);
  }

  .prose th {
    text-align: left;
    font-weight: var(--weight-medium);
    padding: var(--space-2) var(--space-3);
    border-bottom: 2px solid var(--color-border);
  }

  .prose td {
    padding: var(--space-2) var(--space-3);
    border-bottom: 1px solid var(--color-border);
  }

  .prose img {
    max-width: 100%;
    border-radius: var(--radius-md);
  }
}
```

## Callout Boxes

```html
<div class="callout callout--info">
  <p>Informational note here.</p>
</div>
<div class="callout callout--warning">
  <p>Warning note here.</p>
</div>
```

```css
@layer components {
  .callout {
    padding: var(--space-4) var(--space-6);
    border-left: 3px solid var(--color-teal);
    background: oklch(var(--lch-teal) / 0.08);
    border-radius: 0 var(--radius-md) var(--radius-md) 0;
    margin-bottom: var(--space-6);
  }

  .callout--warning {
    border-left-color: var(--color-orange);
    background: oklch(var(--lch-orange) / 0.08);
  }
}
```

## Responsive (Docs)

```css
/* 1024px: sidebar becomes collapsible overlay */
@media (max-width: 1024px) {
  .docs {
    grid-template-columns: 1fr;
  }
  .docs__sidebar {
    position: fixed;
    left: -16rem;
    width: 16rem;
    z-index: var(--z-navbar);
    background: var(--color-canvas);
    transition: left 0.2s ease;
  }
  .docs__sidebar--open {
    left: 0;
  }
}

/* 768px: tighter padding */
@media (max-width: 768px) {
  .docs__content {
    padding: var(--space-4) var(--space-6);
  }
}
```

## Hugo Integration for Docs

### Content structure
```
content/docs/
  _index.md          # Docs landing
  quickstart.md
  architecture.md
  configuration.md
```

### Layout template (`layouts/docs/single.html`)
```go-html-template
{{ define "main" }}
  {{ partial "dagger/navbar.html" . }}
  <div class="docs">
    <aside class="docs__sidebar">
      {{ partial "dagger/docs-sidebar.html" . }}
    </aside>
    <main class="docs__content">
      <article class="prose">
        {{ .Content }}
      </article>
    </main>
  </div>
  {{ partial "dagger/footer.html" . }}
{{ end }}
```
