module Concerns
  module MediaResources
    module Filters
      module MetaData
        module Helpers
          extend ActiveSupport::Concern

          included do
            scope :filter_by_meta_key, lambda { |meta_key_id|
              joins(:meta_data)
                .where(meta_data: { meta_key_id: meta_key_id })
            }

            scope :filter_by_not_meta_key, lambda { |meta_key_id|
              joins(:meta_data)
                .where.not(meta_data: { meta_key_id: meta_key_id })
            }

            # actors: user, person, group
            scope :filter_by_meta_datum_actor_type,
                  lambda { |meta_key_id, id, actor_type|
                    actor_type_plural = actor_type.pluralize

                    filter_by_meta_key(meta_key_id)
                      .joins("JOIN meta_data_#{actor_type_plural} " \
                             "ON meta_data_#{actor_type_plural}.meta_datum_id " \
                             '= meta_data.id')
                      .where("meta_data_#{actor_type_plural}.#{actor_type}_id = ?",
                             id)
                  }

            private_class_method :filter_by_meta_datum_actor_type
          end
        end
      end
    end
  end
end
