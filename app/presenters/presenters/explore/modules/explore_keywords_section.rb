module Presenters
  module Explore
    module Modules
      module ExploreKeywordsSection

        def keywords_section
          unless keywords.blank?
            { type: 'keyword',
              data: keywords_overview,
              show_all_link: true }
          end
        end

        private

        def keywords_overview
          {
            title: 'Häufige Schlagworte',
            url: '/explore/keywords',

            list: keywords.map do |keyword|
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
