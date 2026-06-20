# Category Pages Implementation

## Overview
Three-level category hierarchy implemented for your Jekyll blog:
1. **Home/Index** → Links to all categories
2. **Categories Page** (`/categories.html`) → Grid of category cards with post counts
3. **Individual Category Pages** (`/category/{slug}/`) → Auto-generated pages showing all posts in each category

## Files Added/Modified

### 1. New: `_plugins/category_pages_generator.rb`
**Purpose:** Jekyll generator plugin that auto-creates a dedicated page for each unique category.

**How it works:**
- Runs at build time
- Scans all posts for their `categories` frontmatter
- For each unique category name, generates a page at `/category/{slug}/index.html`
- Uses the `category` layout to render filtered posts
- Slugs are lowercased and spaces become dashes (e.g., "Niveau 3" → `/category/niveau-3/`)
- Skips generation if a manually-authored page already exists at that path

**Safe:** Only runs during build, does not modify source files.

---

### 2. New: `_layouts/category.html`
**Purpose:** Template for individual category pages.

**Features:**
- Breadcrumb navigation back to `/categories.html`
- Page title showing category name
- Post count
- Filters posts using Liquid's `where_exp` filter: `site.posts | where_exp: "post", "post.categories contains page.category"`
- Reuses your existing `main-loop-card.html` include for consistent styling
- Sidebar with featured posts
- Graceful "no posts" message if category is empty

---

### 3. Updated: `_pages/categories.html`
**Before:** Listed all posts grouped by category inline with anchor links.

**After:**
- Clean grid layout (2 columns on medium+ screens)
- Each category is a card showing:
  - Category name
  - Post count (e.g., "5 posts")
- Cards are clickable links to `/category/{slug}/`
- Much cleaner UX — users click once to see all posts in a category

---

### 4. Updated: `_includes/main-loop-card.html`
**Before:** Category links pointed to `categories.html#{category-name}` (anchor links on main categories page)

**After:** Category links now point directly to `/category/{slug}/` (individual category page)

**Result:** Better navigation flow — click any category from a post and go straight to the dedicated category page, not a section on the main categories page.

---

### 5. Updated: `_layouts/post.html`
**Before:** Category links in post headers pointed to `categories.html#{category-name}`

**After:** Category links now point to `/category/{slug}/`

**Result:** Consistent navigation throughout the site.

---

## Navigation Flow

```
Home Index
   ↓
/categories.html (grid of category cards with post counts)
   ↓
/category/niveau-3/ (all posts in "Niveau 3")
   ↓
Post detail page
   ↓
(From post: click category link) → back to /category/{slug}/
(From post: click "Categories") → back to /categories.html
```

## URL Examples

- `/categories.html` — All categories overview
- `/category/catamaran/` — All posts in "Catamaran" category
- `/category/niveau-1/` — All posts in "Niveau 1" category
- `/category/manoeuvre/` — All posts in "Manœuvre" category (accents handled gracefully)
- `/category/pilotage/` — All posts in "Pilotage" category

## Build Instructions

1. Run `bundle exec jekyll build` (or however you normally build)
2. The generator automatically creates `/category/{slug}/index.html` files in `_site/`
3. These pages are not committed to git — they're generated at build time
4. Add `_site/category/` to `.gitignore` if it's not already included

## Testing

After build:
- Visit `/categories.html` — should see a clean grid of all categories
- Click any category card — should navigate to its dedicated page
- Category page should list only posts in that category
- Click a category from a post — should navigate to its category page
- Breadcrumb on category page should link back to `/categories.html`

## Future Enhancements

1. **Pagination:** If a category has many posts, you could add pagination to the `category.html` layout
2. **Sorting:** Sort category pages by date (newest first), alphabetical, etc.
3. **CSS:** Add hover effects to category cards, visual indicators on current category
4. **Taxonomy:** Add sub-categories or tags alongside categories
5. **Auto-nav:** Generate category links in header menu automatically

## Notes

- The slug is generated from the category name: lowercase + spaces → dashes
- Accented characters (é, è, à) are preserved in the category name but slugs use ASCII equivalents
- If you rename a category, the URL slug will change (consider 301 redirects for SEO)
- The generator is "safe" — Jekyll allows it and it won't break anything

---

**To rebuild:** `bundle exec jekyll build` then deploy the `_site/` folder as normal.