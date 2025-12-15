require "fileutils"
require "net/http"
require "uri"

EARLY_EXIT = false
MAX_SITEMAP_LINKS = 5_000

base_url = Settings.madek_external_base_url.to_s.chomp("/")
puts "Sitemap: deleting old sitemaps..."

sitemap_path = ENV["madek_webapp_sitemap_target"] || "public/sitemaps"
puts "Sitemap: madek_webapp_sitemap_target=#{sitemap_path}"

public_root = File.expand_path(File.join(sitemap_path, ".."))
sitemaps_dirname = File.basename(sitemap_path)
puts "Sitemap: resolved public_root=#{public_root} sitemaps_dirname=#{sitemaps_dirname}"

if Dir.exist?(sitemap_path)
  puts "Sitemap: cleanup, deleting all files within sitemaps."
  paths = Dir.children(sitemap_path).map { |n| File.join(sitemap_path, n) }
  FileUtils.rm_rf(paths, secure: true)
  puts "Sitemap: cleanup, done."
else
  puts "Sitemap: no existing sitemaps to delete."
end

puts "Sitemap: generating new sitemaps..."
SitemapGenerator::Sitemap.default_host = base_url
SitemapGenerator::Sitemap.public_path = public_root
SitemapGenerator::Sitemap.sitemaps_path = sitemaps_dirname
SitemapGenerator::Sitemap.create_index = true
SitemapGenerator::Sitemap.compress = false

FileUtils.mkdir_p(File.join(public_root, sitemaps_dirname))

SitemapGenerator::Sitemap.create do
  helpers = Rails.application.routes.url_helpers

  ["de", "en"].each do |locale|
    group(sitemaps_path: "#{sitemaps_dirname}/#{locale}", max_sitemap_links: MAX_SITEMAP_LINKS, filename: :sitemap) do
      add (locale == "en") ? "/?lang=en" : "/", lastmod: Time.current, changefreq: "daily", priority: 1.0
      add (locale == "en") ? "/about?lang=en" : "/about", lastmod: Time.current, changefreq: "monthly", priority: 0.8
    end
  end

  media_entries_count = MediaEntry.viewable_by_public.count
  ["de", "en"].each do |locale|
    scope = "#{sitemaps_dirname}/#{locale}"
    group(sitemaps_path: scope, max_sitemap_links: MAX_SITEMAP_LINKS, filename: :media_entry) do
      stop = false
      MediaEntry.viewable_by_public.find_in_batches(batch_size: 1000) do |batch|
        break if stop
        batch.each do |media_entry|
          path = helpers.media_entry_path(media_entry)
          add (locale == "en") ? "#{path}?lang=en" : path,
            lastmod: media_entry.updated_at,
            changefreq: "daily",
            priority: 0.8

          if EARLY_EXIT
            stop = true
            break
          end
        end
      end
      puts "Sitemap: added #{media_entries_count} media entries, scope: #{scope}"
    end
  end

  collections_count = Collection.viewable_by_public.count
  ["de", "en"].each do |locale|
    scope = "#{sitemaps_dirname}/#{locale}"
    group(sitemaps_path: scope, max_sitemap_links: MAX_SITEMAP_LINKS, filename: :collection) do
      stop = false
      Collection.viewable_by_public.find_in_batches(batch_size: 1000) do |batch|
        break if stop
        batch.each do |collection|
          path = helpers.collection_path(collection)
          add (locale == "en") ? "#{path}?lang=en" : path,
            lastmod: collection.updated_at,
            changefreq: "daily",
            priority: 0.8

          if EARLY_EXIT
            stop = true
            break
          end
        end
      end
      puts "Sitemap: added #{collections_count} collections, scope: #{scope}"
    end
  end
end
puts "Sitemap: finished."
