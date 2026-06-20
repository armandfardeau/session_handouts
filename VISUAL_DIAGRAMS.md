# Visual Flow Diagram

## User Journey

```
┌─────────────────────────────────────────┐
│         USER LANDS ON HOMEPAGE          │
│      /index.html (existing)             │
└─────────────────────────────────────────┘
                 ↓
        [Click "Categories" in nav]
                 ↓
┌─────────────────────────────────────────┐
│      /categories.html (UPDATED)         │
│  ┌──────────────┐  ┌──────────────┐    │
│  │  Catamaran   │  │  Croisière   │    │
│  │  5 posts     │  │  3 posts     │    │
│  └──────────────┘  └──────────────┘    │
│  ┌──────────────┐  ┌──────────────┐    │
│  │  Niveau 1    │  │  Niveau 3    │    │
│  │  2 posts     │  │  1 post      │    │
│  └──────────────┘  └──────────────┘    │
│  ┌──────────────┐  ┌──────────────┐    │
│  │  Pilotage    │  │  Manœuvre    │    │
│  │  4 posts     │  │  2 posts     │    │
│  └──────────────┘  └──────────────┘    │
└─────────────────────────────────────────┘
                 ↓
         [User clicks "Catamaran"]
                 ↓
┌─────────────────────────────────────────┐
│   /category/catamaran/ (AUTO-GENERATED) │
│                                         │
│  Categories / Catamaran                │
│                                         │
│  Catamaran                              │
│  5 posts in this category.             │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ Niveau 1 - Conserver une...    │   │
│  │ Catamaran, Niveau 1, Pilotage  │   │
│  │ Jun 20, 2026                    │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ Niveau 3 - Maintenir l'équi... │   │
│  │ Catamaran, Niveau 3, Pilotage  │   │
│  │ Jun 20, 2026                    │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ Cahier pratique -CAT3fev1992   │   │
│  │ Catamaran, Pilotage, Cahier... │   │
│  │ Jun 20, 2026                    │   │
│  └─────────────────────────────────┘   │
│  ...                                    │
└─────────────────────────────────────────┘
                 ↓
         [User clicks a post card]
                 ↓
┌─────────────────────────────────────────┐
│      /{post-slug}/ (existing)          │
│                                         │
│  [Catamaran] [Niveau 1] [Pilotage]     │
│                                         │
│  Niveau 1 - Conserver une trajectoire │
│  fixe                                   │
│                                         │
│  [Full article content here...]         │
└─────────────────────────────────────────┘
                 ↓
  [User clicks "Catamaran" link in post]
                 ↓
┌─────────────────────────────────────────┐
│      BACK TO /category/catamaran/      │
└─────────────────────────────────────────┘


BUILD PROCESS
=============

Git Push
   ↓
Build runs `bundle exec jekyll build`
   ↓
Jekyll scans all posts in `_posts/`
   ↓
Generator plugin (`_plugins/category_pages_generator.rb`) runs:
   - Finds unique category names
   - Generates slug for each
   - Creates Page objects for each category
   - Adds to site.pages
   ↓
Jekyll renders each category page:
   - Loads `_layouts/category.html`
   - Filters posts by category
   - Generates HTML
   ↓
Output to `_site/`:
   - /categories.html
   - /category/catamaran/index.html
   - /category/niveau-1/index.html
   - /category/niveau-3/index.html
   - /category/pilotage/index.html
   - etc.
   ↓
Deploy `_site/` folder
   ↓
Live site serves category pages
```

---

## File-Level Flow

### READ AT BUILD TIME
```
_posts/
  ├─ post1.md (categories: [Catamaran, Niveau 1])
  ├─ post2.md (categories: [Catamaran, Niveau 3])
  ├─ post3.md (categories: [Croisière, Manœuvre])
  ├─ post4.md (categories: [Catamaran, Pilotage])
  └─ ...

↓ Read by plugin ↓

_plugins/category_pages_generator.rb
  ├─ Scans all posts
  ├─ Extracts categories: ["Catamaran", "Niveau 1", "Niveau 3", "Croisière", "Manœuvre", "Pilotage"]
  ├─ Generates slugs: ["catamaran", "niveau-1", "niveau-3", "croisiere", "manoeuvre", "pilotage"]
  └─ Creates Page objects with:
     - layout: "category"
     - category: "Catamaran" (for example)
     - permalink: "/category/catamaran/"
     - title: "Catamaran"
```

### RENDER AT BUILD TIME
```
_layouts/category.html
  ├─ Receives page.category = "Catamaran"
  ├─ Filters posts: site.posts | where_exp "post.categories contains 'Catamaran'"
  ├─ Loops through filtered posts
  └─ For each post:
     ├─ Includes _includes/main-loop-card.html
     └─ Renders post card with link to post

_layouts/default.html
  ├─ Loads CSS/JS
  ├─ Renders navbar
  ├─ Renders content (from category.html)
  └─ Renders footer
```

### OUTPUT AT BUILD TIME
```
_site/
  ├─ categories.html (manually authored page, rendered)
  ├─ category/
  │   ├─ catamaran/
  │   │   └─ index.html (auto-generated)
  │   ├─ niveau-1/
  │   │   └─ index.html (auto-generated)
  │   ├─ niveau-3/
  │   │   └─ index.html (auto-generated)
  │   ├─ pilotage/
  │   │   └─ index.html (auto-generated)
  │   └─ ...
  └─ {post-slug}/
      └─ index.html (existing post pages)
```

---

## Data Flow

```
POST FRONTMATTER
  ↓ (read by plugin)
  ↓
CATEGORIES LIST
  ↓ (plugin generates)
  ↓
CATEGORY PAGE URLS
  ↓ (Jekyll renders)
  ↓
HTML FILES IN _site/
  ↓ (deployed)
  ↓
LIVE PAGES ON WEB
```

---

## Key Takeaway

**User clicks → Page loads → Done.**

The user never knows about:
- The plugin
- The build process
- The slug generation
- The Liquid filtering

They just see a clean, working category system. ✨