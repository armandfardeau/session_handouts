# Quick Start Checklist

## ✅ What's Been Done

- [x] Created Jekyll Generator plugin (`_plugins/category_pages_generator.rb`)
- [x] Created category layout (`_layouts/category.html`)
- [x] Updated categories page (`_pages/categories.html`)
- [x] Updated post layout to link to category pages
- [x] Updated post card include to link to category pages

## 🚀 Next Steps

### 1. Test Locally (Optional)

If you have Jekyll set up locally:

```bash
cd /Users/armandfardeau/WWW/session_handouts
bundle install
bundle exec jekyll build
bundle exec jekyll serve  # Visit http://localhost:4000
```

Then test:
- Navigate to `/categories.html` — should see a grid of categories
- Click any category card
- Should land on `/category/{slug}/` with posts filtered to that category

### 2. Deploy

Push the changes to your deployment repo/server:

```bash
git add _plugins/ _layouts/ _pages/ _includes/
git commit -m "Add auto-generated individual category pages"
git push
```

Your build system (GitHub Pages, Netlify, etc.) will:
1. Run `bundle install` (if needed)
2. Run `bundle exec jekyll build`
3. The generator plugin runs automatically during build
4. Category pages are created in `_site/category/{slug}/`
5. Deploy `_site/` folder

### 3. Verify Post-Deployment

After deployment, test:

- [ ] `/categories.html` loads and shows all categories as cards
- [ ] Click a category card → lands on `/category/{category-slug}/`
- [ ] Category page shows only posts from that category
- [ ] Category page shows correct post count
- [ ] Click a post from a category page
- [ ] From post detail: click category link in header → goes back to category page
- [ ] From post detail: click category link in post excerpt → goes to category page
- [ ] Breadcrumb on category page links back to `/categories.html`

### 4. Optional: Add Category Menu

If you want categories in your header nav, edit `_includes/menu-header.html`:

```html
<li class="nav-item">
  <a class="nav-link" href="{{site.baseurl}}/categories.html">Categories</a>
</li>
```

(This already exists, so you're good!)

### 5. Optional: Add Category Cloud or Recent Posts

You could enhance the category pages with:
- Related categories sidebar
- Recent posts in other categories
- Search within category

But start with the basic version first — it's clean and works well.

---

## 📋 File Changes Summary

| File | Change | Type |
|------|--------|------|
| `_plugins/category_pages_generator.rb` | New file | Generator plugin |
| `_layouts/category.html` | New file | Template |
| `_pages/categories.html` | Updated | UI improvement |
| `_includes/main-loop-card.html` | Updated | Navigation fix |
| `_layouts/post.html` | Updated | Navigation fix |

---

## 🐛 Troubleshooting

**Problem:** Categories page shows no categories.

**Solution:** Make sure at least one post has a `categories:` field in frontmatter.

```yaml
---
categories: [ Catamaran, Niveau 1, Pilotage ]
---
```

---

**Problem:** Category pages not being generated.

**Solution:** 
- Check `bundle exec jekyll build` output for errors
- Verify `_plugins/` folder exists and `category_pages_generator.rb` is there
- Check browser console for JavaScript errors
- Verify Jekyll plugins are enabled in `_config.yml` (they are by default)

---

**Problem:** Category links still point to old `categories.html#anchor` format.

**Solution:** This was fixed in the files. If you still see old links, do a hard browser refresh (Cmd+Shift+R on Mac, Ctrl+Shift+R on Windows/Linux).

---

**Problem:** Some categories are missing from `/categories.html` grid.

**Solution:** `site.categories` in Jekyll is populated at build time from all posts. If a category exists but doesn't show:
1. Rebuild: `bundle exec jekyll build`
2. Check post frontmatter has correct `categories:` field
3. Make sure category name matches exactly (case-sensitive in data, but Liquid filters handle it)

---

## 📚 Documentation

- `CATEGORY_PAGES_IMPLEMENTATION.md` — Full technical details
- `ARCHITECTURE_DIAGRAM.md` — Visual overview and slug examples
- This file — Quick start

---

## 💡 Pro Tips

1. **Category Naming:** Keep category names consistent. "Niveau 1" vs "Niveau1" will create two separate categories.

2. **Slug URLs:** Spaces become dashes. "Cahier Pratique" → `/category/cahier-pratique/`

3. **Post Count:** Automatically calculated on `/categories.html` and category pages.

4. **Breadcrumbs:** All category pages have a breadcrumb link back to `/categories.html` for easy navigation.

5. **SEO:** Each generated category page has a unique URL with metadata (title, description) for search engines.

---

**Ready?** Run `bundle exec jekyll build` and test! 🎉