# config/sitemap.rb

base_url = Settings.madek_external_base_url.to_s.chomp('/')

puts "base_url: #{base_url}"

SitemapGenerator::Sitemap.default_host  = base_url
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps'   # no trailing slash
SitemapGenerator::Sitemap.create_index  = true
SitemapGenerator::Sitemap.compress      = true

SitemapGenerator::Sitemap.create do
  helpers = Rails.application.routes.url_helpers

  # Build ABSOLUTE URL for alternates; `add` will receive only PATHS.
  def absolute_with_lang(base_url, path, lang = 'de')
    path = "/#{path.to_s.sub(%r{^/}, '')}"
    postfix = (lang == 'de') ? '' : "?lang=#{lang}"
    "#{base_url}#{path}#{postfix}"
  end

  # ---------- Homepage (pass PATHS to `add`) ----------
  de_path = '/'            # path only
  en_path = '/?lang=en'

  de_abs = absolute_with_lang(base_url, '/')
  en_abs = absolute_with_lang(base_url, '/', 'en')

  alternates_home = [
    { href: de_abs, href_lang: 'de' },
    { href: en_abs, href_lang: 'en' },
    { href: de_abs, href_lang: 'x-default' }
  ]

  add de_path,
      lastmod: Time.current,
      changefreq: 'daily',
      priority: 1.0,
      alternates: alternates_home

  add en_path,
      lastmod: Time.current,
      changefreq: 'daily',
      priority: 0.9,
      alternates: alternates_home

  # ---------- Media entries ----------
  MediaEntry.viewable_by_public.find_in_batches(batch_size: 1000) do |batch|
    batch.each do |media_entry|
      path       = helpers.media_entry_path(media_entry)  # e.g. "/entries/uuid"
      updated_at = media_entry.updated_at

      de_path = path
      en_path = "#{path}?lang=en"

      de_abs = absolute_with_lang(base_url, path)
      en_abs = absolute_with_lang(base_url, path, 'en')

      alternates = [
        { href: de_abs, href_lang: 'de' },
        { href: en_abs, href_lang: 'en' },
        { href: de_abs, href_lang: 'x-default' }
      ]

      add de_path,
          lastmod:  updated_at,
          changefreq: 'daily',
          priority: 0.8,
          alternates: alternates

      add en_path,
          lastmod:  updated_at,
          changefreq: 'daily',
          priority: 0.7,
          alternates: alternates
      break
    end
    break
  end
  puts "Sitemap: added #{MediaEntry.viewable_by_public.count} media entries (de+en)."

  # ---------- Collections ----------
  Collection.viewable_by_public.find_in_batches(batch_size: 1000) do |batch|
    batch.each do |collection|
      path       = helpers.collection_path(collection)    # e.g. "/sets/uuid"
      updated_at = collection.updated_at

      de_path = path
      en_path = "#{path}?lang=en"

      de_abs = absolute_with_lang(base_url, path)
      en_abs = absolute_with_lang(base_url, path, 'en')

      alternates = [
        { href: de_abs, href_lang: 'de' },
        { href: en_abs, href_lang: 'en' },
        { href: de_abs, href_lang: 'x-default' }
      ]

      add de_path,
          lastmod:  updated_at,
          changefreq: 'daily',
          priority: 0.8,
          alternates: alternates

      add en_path,
          lastmod:  updated_at,
          changefreq: 'daily',
          priority: 0.7,
          alternates: alternates
      break
    end
    break
  end
  puts "Sitemap: added #{Collection.viewable_by_public.count} collections (de+en)."
end
