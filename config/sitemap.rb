require "fileutils"

base_url = Settings.madek_external_base_url.to_s.chomp("/")
puts "base_url: #{base_url}"

early_exit = false

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
  group(sitemaps_path: "sitemaps/de", filename: :media_entry) do
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

        if early_exit
          stop = true
          break
        end
      end
    end
  end

  group(sitemaps_path: "sitemaps/en", filename: :media_entry) do
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

        if early_exit
          stop = true
          break
        end
      end
    end
  end

  puts "Sitemap: added #{MediaEntry.viewable_by_public.count} media entries#{" (early exit)" if early_exit}."

  # -------------------- COLLECTIONS --------------------
  group(sitemaps_path: "sitemaps/de", filename: :collection) do
    stop = false
    Collection.viewable_by_public.find_in_batches(batch_size: 1000) do |batch|
      break if stop
      batch.each do |collection|
        path = helpers.collection_path(collection)  # e.g. "/sets/uuid"
        updated_at = collection.updated_at

        alternates = [
          {href: abs_url.call(path), lang: "de"},
          {href: abs_url.call(path, "en"), lang: "en"},
          {href: abs_url.call(path), lang: "x-default"}
        ]

        add path, lastmod: updated_at, changefreq: "daily", priority: 0.8, alternates: alternates

        if early_exit
          stop = true
          break
        end
      end
    end
  end

  group(sitemaps_path: "sitemaps/en", filename: :collection) do
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

        if early_exit
          stop = true
          break
        end
      end
    end
  end
end

# -------------------- robots.txt updater --------------------
module RobotsTxtHelper
  module_function

  def ensure_sitemap_line!(url:, path:)
    FileUtils.mkdir_p(File.dirname(path))
    content =
      if File.exist?(path)
        File.read(path)
      else
        "# robots.txt\nUser-agent: *\nAllow: /\n"
      end

    line = "Sitemap: #{url}"

    if content.match?(/^Sitemap:\s*\S+/)
      content = content.gsub(/^Sitemap:.*$/i, line)
    elsif !content.include?(line)
      content = content.rstrip + "\n" + line + "\n"
    end

    File.write(path, content)
    puts "robots.txt updated → #{line}"
  rescue => e
    warn "robots.txt update failed: #{e.class}: #{e.message}"
  end
end

RobotsTxtHelper.ensure_sitemap_line!(
  url: "#{base_url}/sitemaps/sitemap.xml.gz",
  path: Rails.root.join("public", "robots.txt")
)
