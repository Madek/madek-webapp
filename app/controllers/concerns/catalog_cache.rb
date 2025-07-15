module CatalogCache
  extend ActiveSupport::Concern

  CACHE_KEY = 'explore_catalog_section'.freeze

  def catalog_cache
    if AppSetting.first.try(:catalog_caching)
      Rails.cache.fetch(CACHE_KEY,
                        expires_in: CacheHelper.catalog_cache_duration) do
        yield
      end
    else
      yield
    end
  end
end
