module Concerns
  module MediaResources
    module Filters
      module MetaData
        module Helpers
          extend ActiveSupport::Concern

          included do
            # actors: user, person, group
            scope :filter_by_meta_datum_actor_type,
                  lambda { |id, actor_type|
                    actor_type_plural = actor_type.pluralize

                    joins(:meta_data)
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
