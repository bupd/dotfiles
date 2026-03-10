# Component Patterns

HTML structure and key CSS for each landing page section.

## Navbar

```html
<nav class="navbar">
  <div class="navbar__inner">
    <a href="/" class="navbar__logo"><!-- SVG logo --></a>
    <div class="navbar__links">
      <a href="#" class="navbar__link">Docs</a>
      <a href="#" class="navbar__link">Blog</a>
      <a href="#" class="navbar__link">Community</a>
    </div>
    <div class="navbar__actions">
      <a href="#" class="navbar__github">
        <!-- GitHub SVG --> Star <span class="navbar__github-count">1,234</span>
      </a>
      <a href="#" class="navbar__cta">Get Started</a>
    </div>
  </div>
</nav>
```

Key CSS:
- Fixed top, z-index `--z-navbar`, transparent background
- Inner: flex, space-between, `max-width: var(--page-max-width)`
- CTA: navy background, white text, `--radius-md`, `--text-xs`
- GitHub badge: border, white background, star count with left border separator

## Hero

```html
<section class="hero">
  <div class="hero__inner">
    <div class="hero__content">
      <h1 class="hero__title">Tagline here</h1>
      <div class="hero__description">
        <p>First line of description.</p>
        <p>Second line of description.</p>
      </div>
      <div class="hero__actions">
        <a href="#" class="hero__cta">Get Started</a>
        <p class="hero__brew">install command here</p>
      </div>
    </div>
    <div class="hero__visual"></div>
  </div>
</section>
```

Key CSS:
- `padding-top: 152px` (accounts for fixed navbar)
- Inner: flex, center aligned, gap 20px
- Title: inherits `h1` (3.5rem, weight 400, leading 1.1)
- CTA: navy background, `--text-lg`, `--radius-md`
- Brew: monospace font, 20px, medium weight
- Visual: 420x471px, gray background, `--radius-lg`, placeholder for illustration

## Logo Ticker

```html
<section class="logo-ticker">
  <div class="logo-ticker__item"></div>
  <!-- repeat 5-7 items -->
</section>
```

Key CSS:
- Flex, center, gap 64px, height 120px, overflow hidden
- Items: 120x40px, muted gray background, `--radius-sm`

## Feature Cards

```html
<section class="features">
  <div class="features__list">
    <article class="feature-card">
      <div class="feature-card__content">
        <h2 class="feature-card__title">Feature Name</h2>
        <div class="feature-card__text">
          <p>Description paragraph 1.</p>
          <p>Description paragraph 2.</p>
        </div>
        <a href="#" class="feature-card__link">Read Docs</a>
      </div>
      <div class="feature-card__visual feature-card__visual--teal"></div>
    </article>
    <!-- more cards -->
  </div>
</section>
```

Key CSS:
- Section: `padding-top: 140px`
- List: flex column, gap 100px, max-width constrained
- Card: flex, white background, `--radius-lg`, `padding: 48px 80px`, min-height 450px
- Content: width 368px, flex column, gap 28px
- Text paragraphs: `--text-base`, regular weight
- Link: inline-flex, `--text-xs`, border outline, `--radius-md`
- Visual: flex 1, `--radius-lg`, min-height 350px
- Color modifiers: `--teal`, `--orange`, `--yellow`

## Community

```html
<section class="community">
  <div class="community__inner">
    <div class="community__header">
      <span class="community__label">Community</span>
      <h1 class="community__title">Join the community</h1>
      <p class="community__subtitle">Description text.</p>
    </div>
    <div class="community__cards">
      <a href="#" class="community__card">
        <div class="community__card-icon"><!-- SVG --></div>
        <h4 class="community__card-title">Card Title</h4>
        <p class="community__card-desc">Card description.</p>
      </a>
      <!-- 2 more cards -->
    </div>
  </div>
</section>
```

Key CSS:
- `padding-top: 160px`, text-align center
- Label: `::before` pseudo-element with colored dot (10px circle, teal)
- Cards: 3-column grid, gap 20px
- Card: white background, `--radius-lg`, padding 40px, flex column center
- Card hover: translateY(-2px), `--shadow-md`, opacity stays 1
- Icon: 64px, muted blue-gray color (`#D0E0F9`)

## Newsletter

```html
<section class="newsletter">
  <h4 class="newsletter__title">Get email updates</h4>
  <div class="newsletter__form">
    <div class="newsletter__input-wrap">
      <input type="email" class="newsletter__input" placeholder="email@example.com">
    </div>
    <button type="submit" class="newsletter__submit">Submit</button>
  </div>
</section>
```

Key CSS:
- Max-width constrained, flex column center, gap 24px
- Input wrap: 371px wide, 48px tall, white background, radius 10px
- Submit: navy background, white text, `--text-xs`, 48px tall

## Footer

```html
<footer class="footer">
  <div class="footer__inner">
    <div class="footer__top">
      <a href="/" class="footer__logo"><!-- Large SVG --></a>
      <div class="footer__columns">
        <div class="footer__column">
          <p class="footer__column-title">Resources</p>
          <div class="footer__column-links">
            <a href="#" class="footer__column-link">Docs</a>
            <a href="#" class="footer__column-link">Blog</a>
          </div>
        </div>
        <!-- 3 more columns -->
      </div>
    </div>
    <div class="footer__divider"></div>
    <div class="footer__bottom">
      <div class="footer__bottom-left">
        <span class="footer__copyright">Copyright text</span>
        <a href="#" class="footer__legal-link">Privacy</a>
      </div>
      <div class="footer__social">
        <a href="#" class="footer__social-link"><!-- SVG --></a>
      </div>
    </div>
  </div>
</footer>
```

Key CSS:
- Background: `rgb(26, 24, 51)`, white text
- Padding: 100px horizontal, 100px top, 40px bottom
- Top: flex space-between, logo left (169x56px), 4-column link grid right
- Column titles: 20px, gap 22px below
- Column links: flex column, gap 20px, `--text-base`
- Divider: 1px white at 10% opacity
- Bottom: flex space-between, copyright + legal left, social icons right
- Social icons: 20px SVGs, white

## Section Header Pattern (for Community, Features, etc.)

```html
<div class="section-header">
  <span class="section-label">
    <span class="section-label__dot"></span>
    Label Text
  </span>
  <h2 class="section-title">Section Title</h2>
  <p class="section-description">Description text.</p>
</div>
```

- Dot: 0.5rem circle, accent color (teal or orange)
- Title: clamp(2rem, 4vw, 3rem), weight 400
- Description: `--text-lg`, muted color, max-width 40rem
