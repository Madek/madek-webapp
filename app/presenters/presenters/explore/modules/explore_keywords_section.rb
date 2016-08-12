module Presenters
  module Explore
    module Modules
      module ExploreKeywordsSection

        private

        def keywords_section
          unless keywords.blank?
            { type: 'keyword',
              id: 'keywords',
              data: keywords_overview,
              show_all_link: @show_all_link }
          end
        end

        def keywords_overview
          {
            title: 'Häufige Schlagworte',
            url: '/explore/keywords',

            list: keywords.with_usage_count.map do |keyword|
              {
                url: prepend_url_context('/explore/catalog/madek_core:keywords'),
                keyword: \
                  Presenters::Keywords::KeywordIndexWithUsageCount.new(keyword)
              }
            end
          }
        end
      end
    end
  end
end
