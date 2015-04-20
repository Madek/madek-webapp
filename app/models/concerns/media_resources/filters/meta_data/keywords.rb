module Concerns
  module MediaResources
    module Filters
      module MetaData
        module Keywords
          extend ActiveSupport::Concern
          include Concerns::MediaResources::Filters::MetaData::Helpers

          included do
            scope :filter_by_meta_datum_keywords, lambda { |id|
              joins(:meta_data)
                .joins('JOIN keywords ' \
              'ON keywords.meta_datum_id = meta_data.id')
                .joins('JOIN keyword_terms ' \
              'ON keywords.keyword_term_id = keyword_terms.id')
                .where(keyword_terms: { id: id })
            }
          end
        end
      end
    end
  end
end
