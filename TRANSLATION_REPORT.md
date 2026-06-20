# French Translation — Summary

## What changed

Every user-facing English string has been replaced with French. UI strings now flow through a single source of truth: `_data/i18n.yml` (41 keys).

## Centralized translations

All strings live in **`_data/i18n.yml`** under the `fr:` key. Templates reference them via `{{ site.data.i18n.fr.<key> }}`. To change a string later, edit only the YAML.

If you ever add English, just create `_data/i18n_en.yml` with the same keys and switch `site.lang` per page.

## What was translated

| File | What changed |
|---|---|
| `_layouts/default.html` | `<html lang="fr">`; footer credits, copyright |
| `_layouts/post.html` | "Follow", "Share this", "Written by", newsletter copy, dates → French format |
| `_layouts/category.html` | "Categories", post count, "No posts found" |
| `_layouts/page.html`, `page-sidebar.html` | Untouched (no English strings) |
| `_pages/categories.html` | Title, post count |
| `_pages/tags.html` | Title |
| `_pages/authors-list.html` | Title, "(View Posts)" |
| `_pages/contact.md` | All form labels and intro text |
| `_pages/author-armand.html` | Title, "Follow", "Posts by" |
| `_pages/about.md` | Whole page rewritten in French with real bio |
| `index.html` | Title, description, "All Stories", "Read More", pagination, "In", category links → category pages, dates |
| `404.html` | "Page not found" |
| `_includes/main-loop-card.html` | "In", category links → category pages, dates |
| `_includes/sidebar-featured.html` | "Featured", "In" |
| `_includes/sidebar.html` | Replaced leftover "Mundana Jekyll Theme" demo block |
| `_includes/menu-header.html` | Home/Categories/Authors/Contact → French |
| `_includes/search-lunr.html` | Placeholder, "Close", "Search results for", "Sorry, no results" |
| `_includes/comments.html` | Disqus noscript fallback |
| `_data/authors.yml` | Bio → French, name → full name |
| `_config.yml` | Added `lang: fr`, updated author bio/name |

## Date format

Old: `%b %d, %Y` → e.g. `Jun 20, 2026`  
New: `%-d %b %Y` → e.g. `20 jun 2026`

(For full French month names you'd need a `_data/months_fr.yml` lookup — happy to add if you want.)

## What was intentionally NOT translated

- HTML form attributes (`name="subscribe"`, `value="Subscribe"`) — these are Mailchimp's API contract. The visible button text is French.
- HTML/CSS class names, JS variables, Liquid tags
- Disqus shortname, Formspree endpoint — internal infrastructure
- File names and permalinks (changing these would break external links)

## How to test

```bash
bundle exec jekyll build
bundle exec jekyll serve
```

Then browse:
- `/` — French home, "Lire la suite", "Toutes les fiches", pagination in French
- `/categories.html` — "Catégories", "5 fiches"
- `/category/catamaran/` — French category page with breadcrumb
- `/contact.html` — French form
- `/authors-list.html` — French author listing
- `/a-random-post/` — "Rédigé par", "Partager cet article", French dates
- `/some-broken-url/` — 404 page in French
- `/about.html` — French about page