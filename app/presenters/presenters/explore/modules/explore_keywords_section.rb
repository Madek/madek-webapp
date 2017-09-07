module Presenters
  module Explore
    module Modules
      class ExploreKeywordsSection < Presenter

        def initialize(limit: 24)
          @limit = limit
        end

        def empty?
          keywords.blank?
        end

        def content
          return if empty?
          {
            type: 'keyword',
            id: 'keywords',
            data: keywords_overview,
            show_all_link: true,
            show_all_text: 'Weitere anzeigen',
            show_title: true
          }
        end

        private

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

        def keywords
          @keywords ||= \
            MetaKey
            .find_by(id: 'madek_core:keywords')
            .try(:keywords)
            .try(:limit, @limit)
        end
      end
    end
  end
end
