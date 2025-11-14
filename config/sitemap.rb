require "fileutils"
require "net/http"
require "uri"

EARLY_EXIT = false

base_url = Settings.madek_external_base_url.to_s.chomp("/")
puts "Sitemap: deleting old sitemaps..."

sitemap_path = ENV["madek_webapp_sitemap_target"] || "public/sitemaps"
puts "Sitemap: madek_webapp_sitemap_target=#{sitemap_path}"

public_root = File.expand_path(File.join(sitemap_path, '..'))
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
SitemapGenerator::Sitemap.compress = true

# Ensure target directory exists
FileUtils.mkdir_p(File.join(public_root, sitemaps_dirname))

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

  group(sitemaps_path: "#{sitemaps_dirname}/de", filename: :sitemap) do
    add "/", lastmod: Time.current, changefreq: "daily", priority: 1.0, alternates: alternates_home
  end

  group(sitemaps_path: "#{sitemaps_dirname}/en", filename: :sitemap) do
    add "/?lang=en", lastmod: Time.current, changefreq: "daily", priority: 1.0, alternates: alternates_home
  end

  # -------------------- MEDIA ENTRIES --------------------
  scope = "#{sitemaps_dirname}/de"
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

  scope = "#{sitemaps_dirname}/en"
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
  scope = "#{sitemaps_dirname}/de"
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

  scope = "#{sitemaps_dirname}/en"
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
