module Permissions
  module Modules
    module FilterSet
      extend ActiveSupport::Concern
      include ::Permissions::Modules::DefineDestroyIneffective
      included do
        belongs_to :updator, class_name: 'User'
        belongs_to :filter_set
        define_destroy_ineffective [{ get_metadata_and_previews: false,
                                      edit_metadata_and_filter: false }]
      end
    end
  end
end
