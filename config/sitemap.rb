SitemapGenerator::Sitemap.default_host = Settings.madek_external_base_url
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/"
SitemapGenerator::Sitemap.create_index = true

SitemapGenerator::Sitemap.create do
  def create_url (path, lang = "de", with_base_url = true)
    postfix = lang == "de" ? "" : "?lang=#{lang}"
    if with_base_url
      "#{Settings.madek_external_base_url}#{path}#{postfix}"
    else
      "#{path}#{postfix}"
    end
  end

  add root_path, priority: 1.0, changefreq: 'daily'

  MediaEntry.viewable_by_public.find_in_batches(batch_size: 10000) do |batch|
    batch.each do |media_entry|
      ["de", "en"].each do |lang|
        priority = lang == "de" ? 0.8 : 0.7
        path = media_entry_path(media_entry)
        updated_at = media_entry.updated_at
        alternatives = [{
                          href: create_url(path, 'en'),
                          lastmod: updated_at,
                          lang: 'en'
                        }, {
                          href: create_url(path),
                          lastmod: updated_at,
                          lang: 'de'
                        }, {
                          href: create_url(path),
                          lastmod: updated_at,
                          lang: 'x-default'
                        }]

        add create_url(path, lang, false),
            lastmod: updated_at,
            priority: priority,
            alternates: alternatives
      end

      break
    end
    break
  end
  puts "Sitemap created with #{MediaEntry.viewable_by_public.count} sitemaps."

  Collection.viewable_by_public.find_each do |collection|

    ["de", "en"].each do |lang|
      priority = lang == "de" ? 0.8 : 0.7
      path = collection_path(collection)
      updated_at = collection.updated_at
      alternatives = [{
                        href: create_url(path, 'en'),
                        lastmod: updated_at,
                        lang: 'en'
                      }, {
                        href: create_url(path),
                        lastmod: updated_at,
                        lang: 'de'
                      }, {
                        href: create_url(path),
                        lastmod: updated_at,
                        lang: 'x-default'
                      }]

      add create_url(path, lang, false),
          lastmod: updated_at,
          priority: priority,
          alternates: alternatives
    end

    break
  end
  puts "Sitemap created with #{Collection.viewable_by_public.count} sitemaps."

end
