require "fileutils"
require "net/http"
require "uri"

EARLY_EXIT = false

base_url = Settings.madek_external_base_url.to_s.chomp("/")
puts "Sitemap: deleting old sitemaps..."
sitemap_path = "public/sitemaps"
if Dir.exist?(sitemap_path)
  FileUtils.rm_r(sitemap_path, secure: true)
else
  puts "Sitemap: no existing sitemaps to delete."
end

puts "Sitemap: generating new sitemaps..."
SitemapGenerator::Sitemap.default_host = base_url
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps"
SitemapGenerator::Sitemap.create_index = true
SitemapGenerator::Sitemap.compress = true

SitemapGenerator::Sitemap.create do
  helpers = Rails.application.routes.url_helpers

  # Lambda so it works inside group{} blocks
  abs_url = ->(path, lang = "de") do
    clean = "/#{path.to_s.sub(%r{^/}, "")}"
    suffix = (lang == "de") ? "" : "?lang=#{lang}"
    "#{base_url}#{clean}#{suffix}"
  end

  # -------------------- HOMEPAGE --------------------
  alternates_home = [
    {href: abs_url.call("/"), lang: "de"},
    {href: abs_url.call("/", "en"), lang: "en"},
    {href: abs_url.call("/"), lang: "x-default"}
  ]

  group(sitemaps_path: "sitemaps/de", filename: :sitemap) do
    add "/", lastmod: Time.current, changefreq: "daily", priority: 1.0, alternates: alternates_home
  end

  group(sitemaps_path: "sitemaps/en", filename: :sitemap) do
    add "/?lang=en", lastmod: Time.current, changefreq: "daily", priority: 1.0, alternates: alternates_home
  end

  # -------------------- MEDIA ENTRIES --------------------
  scope = "sitemaps/de"
  group(sitemaps_path: scope, filename: :media_entry) do
    stop = false
    MediaEntry.viewable_by_public.find_in_batches(batch_size: 1000) do |batch|
      break if stop
      batch.each do |media_entry|
        path = helpers.media_entry_path(media_entry) # e.g. "/entries/uuid"
        updated_at = media_entry.updated_at

        alternates = [
          {href: abs_url.call(path), lang: "de"},
          {href: abs_url.call(path, "en"), lang: "en"},
          {href: abs_url.call(path), lang: "x-default"}
        ]

        add path, lastmod: updated_at, changefreq: "daily", priority: 0.8, alternates: alternates

        if EARLY_EXIT
          stop = true
          break
        end
      end
    end
  end
  puts "Sitemap: added #{MediaEntry.viewable_by_public.count} media entries, scope: #{scope}"

  scope = "sitemaps/en"
  group(sitemaps_path: scope, filename: :media_entry) do
    stop = false
    MediaEntry.viewable_by_public.find_in_batches(batch_size: 1000) do |batch|
      break if stop
      batch.each do |media_entry|
        path = helpers.media_entry_path(media_entry)
        updated_at = media_entry.updated_at

        alternates = [
          {href: abs_url.call(path), lang: "de"},
          {href: abs_url.call(path, "en"), lang: "en"},
          {href: abs_url.call(path), lang: "x-default"}
        ]

        add "#{path}?lang=en", lastmod: updated_at, changefreq: "daily", priority: 0.8, alternates: alternates

        if EARLY_EXIT
          stop = true
          break
        end
      end
    end
  end
  puts "Sitemap: added #{MediaEntry.viewable_by_public.count} media entries, scope: #{scope}"

  # -------------------- COLLECTIONS --------------------
  scope = "sitemaps/de"
  group(sitemaps_path: scope, filename: :collection) do
    stop = false
    Collection.viewable_by_public.find_in_batches(batch_size: 1000) do |batch|
      break if stop
      batch.each do |collection|
        path = helpers.collection_path(collection) # e.g. "/sets/uuid"
        updated_at = collection.updated_at

        alternates = [
          {href: abs_url.call(path), lang: "de"},
          {href: abs_url.call(path, "en"), lang: "en"},
          {href: abs_url.call(path), lang: "x-default"}
        ]

        add path, lastmod: updated_at, changefreq: "daily", priority: 0.8, alternates: alternates

        if EARLY_EXIT
          stop = true
          break
        end
      end
    end
  end
  puts "Sitemap: added #{Collection.viewable_by_public.count} collections, scope: #{scope}"

  scope = "sitemaps/en"
  group(sitemaps_path: scope, filename: :collection) do
    stop = false
    Collection.viewable_by_public.find_in_batches(batch_size: 1000) do |batch|
      break if stop
      batch.each do |collection|
        path = helpers.collection_path(collection)
        updated_at = collection.updated_at

        alternates = [
          {href: abs_url.call(path), lang: "de"},
          {href: abs_url.call(path, "en"), lang: "en"},
          {href: abs_url.call(path), lang: "x-default"}
        ]

        add "#{path}?lang=en", lastmod: updated_at, changefreq: "daily", priority: 0.8, alternates: alternates

        if EARLY_EXIT
          stop = true
          break
        end
      end
    end
  end
  puts "Sitemap: added #{Collection.viewable_by_public.count} collections, scope: #{scope}"
end
puts "Sitemap: finished."
