require 'jekyll'
require 'liquid'

# Generates a page for each unique category at /category/{slug}/index.html
# Each generated page uses the `category` layout and filters posts by category name.
module Jekyll
  class CategoryPagesGenerator < Generator
    safe true
    priority :low

    CATEGORY_SLUG_REGEX = /[^a-z0-9]+/

    def generate(site)
      # Collect unique category names across all posts
      categories = []
      site.posts.docs.each do |post|
        next unless post.data['categories']
        cats = post.data['categories']
        cats = [cats] unless cats.is_a?(Array)
        cats.each do |cat|
          next if cat.nil? || cat.to_s.strip.empty?
          categories << cat.to_s.strip unless categories.include?(cat.to_s.strip)
        end
      end

      categories.each do |category_name|
        slug = category_name.downcase.gsub(CATEGORY_SLUG_REGEX, '-').gsub(/^-|-$/, '')
        next if slug.empty?

        # Build relative path under /category/{slug}/index.html
        dir = File.join('category', slug)
        index_path = File.join(dir, 'index.html')

        # Skip if a manually-authored page already exists at this path
        next if site.pages.any? { |p| p.path == index_path }

        page = PageWithoutAFile.new(site, site.source, dir, 'index.html')
        page.data['layout'] = 'category'
        page.data['title'] = category_name
        page.data['category'] = category_name
        page.data['permalink'] = "/category/#{slug}/"
        page.data['description'] = "Posts in the #{category_name} category"
        page.data['sitemap'] = true

        site.pages << page
      end
    end
  end
end