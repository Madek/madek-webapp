module Permissions
  module Modules
    module Collection
      extend ActiveSupport::Concern

      included do

        belongs_to :collection
        belongs_to :updator, class_name: 'User'

        def self.destroy_ineffective
          where(get_metadata_and_previews: false,
                edit_metadata_and_relations: false).delete_all
        end

      end

    end
  end
end
