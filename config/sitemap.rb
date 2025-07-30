SitemapGenerator::Sitemap.default_host = Settings.madek_external_base_url
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/"

SitemapGenerator::Sitemap.create do
  add root_path, priority: 1.0, changefreq: 'daily'
  
  MediaEntry.viewable_by_public.find_in_batches(batch_size: 10000) do |batch|
    batch.each do |media_entry|
      add media_entry_path(media_entry), 
          lastmod: media_entry.updated_at, 
          priority: 0.8
    end
  end
  
  Collection.viewable_by_public.find_each do |collection|
    add collection_path(collection), 
        lastmod: collection.updated_at, 
        priority: 0.7
  end
end
