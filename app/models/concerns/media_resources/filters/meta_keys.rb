module Concerns
  module MediaResources
    module Filters
      module MetaKeys
        extend ActiveSupport::Concern
        included do
          scope :filter_by_meta_key, lambda { |meta_key_id = nil|
            result = joins(:meta_data)
            if meta_key_id
              result.where(meta_data: { meta_key_id: meta_key_id })
            else
              result
            end
          }

          scope :filter_by_not_meta_key, lambda { |meta_key_id|
            joins(:meta_data)
              .where.not(meta_data: { meta_key_id: meta_key_id })
          }
        end
      end
    end
  end
end
