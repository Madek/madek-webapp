module Concerns
  module MediaResources
    module Filters
      module MetaData
        module Keywords
          extend ActiveSupport::Concern
          include Concerns::MediaResources::Filters::MetaData::Helpers

          included do
            scope :filter_by_meta_datum_keywords, lambda { |meta_key_id, id|
              filter_by_meta_key(meta_key_id)
                .joins('JOIN keywords ' \
              'ON keywords.meta_datum_id = meta_data.id')
                .joins('JOIN keyword_terms ' \
              'ON keywords.keyword_term_id = keyword_terms.id')
                .where(keyword_terms: { id: id })
            }
            private_class_method :filter_by_meta_datum_keywords
          end
        end
      end
    end
  end
end
