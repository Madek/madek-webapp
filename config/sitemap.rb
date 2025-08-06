SitemapGenerator::Sitemap.default_host = Settings.madek_external_base_url
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/"
SitemapGenerator::Sitemap.create_index = true

SitemapGenerator::Sitemap.create do
  add root_path, priority: 1.0, changefreq: 'daily'

  binding.pry

  MediaEntry.viewable_by_public.find_in_batches(batch_size: 10000) do |batch|
    batch.each do |media_entry|

      binding.pry

      # url = media_entry_path(media_entry)

      # postfix = lang == "de" ? "" : "?lang=#{lang}"
      #
      # url = "#{media_entry_path(media_entry)}#{postfix}"
      # puts "url : #{url}"
      # updated_at = media_entry.updated_at
      # alternatives = [
      #   {
      #     href: url + "?lang=en",
      #     lastmod: updated_at,
      #     lang: 'en'
      #   }, {
      #     href: url,
      #     lastmod: updated_at,
      #     lang: 'de'
      #   }, {
      #     href: url,
      #     lastmod: updated_at,
      #     lang: 'x-default'
      #   }
      # ]



      puts "Processing MediaEntry: #{media_entry.id} - #{media_entry.title}"

      ["de", "en"].each do |lang|
        postfix = lang == "de" ? "" : "?lang=#{lang}"
        priority = lang ==  "de" ? 0.8 : 0.7


        url = "#{Settings.madek_external_base_url}#{media_entry_path(media_entry)}#{postfix}"
        puts "url : #{url}"
        updated_at = media_entry.updated_at
        alternatives = [
          {
            href: url ,
            lastmod: updated_at,
            lang: 'en'
          }, {
            href: url,
            lastmod: updated_at,
            lang: 'de'
          }, {
            href: url,
            lastmod: updated_at,
            lang: 'x-default'
          }
        ]

        # add "#{url}#{postfix}",

            # add collection_path(collection),
          # lastmod: updated_at,
          # priority: 0.7

        # add "#{media_entry_path(media_entry)}#{url}#{postfix}",
        add "#{media_entry_path(media_entry)}#{postfix}",
            lastmod: updated_at,
            priority: priority,
            # hreflang: lang,
            alternates: alternatives
      end

      break
    end
    break
  end
  puts "Sitemap created with #{MediaEntry.viewable_by_public.count} sitemaps."

  # Collection.viewable_by_public.find_each do |collection|
  #   add collection_path(collection),
  #       lastmod: collection.updated_at,
  #       priority: 0.7
  #   break
  # end
  # puts "Sitemap created with #{Collection.viewable_by_public.count} sitemaps."

end

# robots_txt_path = Rails.root.join('public', 'robots.txt')
# sitemap_url = "#{Settings.madek_external_base_url}/sitemaps/sitemap.xml.gz"
# sitemap_entry = "Sitemap: #{sitemap_url}"
#
# unless File.exist?(robots_txt_path)
#   File.write(robots_txt_path, "User-agent: *\nDisallow:\n")
# end
#
# unless File.readlines(robots_txt_path).any? { |line| line.strip == sitemap_entry }
#   File.open(robots_txt_path, 'a') { |file| file.puts "\n#{sitemap_entry}" }
# end
