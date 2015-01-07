module Permissions
  module Modules
    module MediaEntry
      extend ActiveSupport::Concern
      include ::Permissions::Modules::DefineDestroyIneffective
      included do
        belongs_to :updator, class_name: 'User'
        belongs_to :media_entry
      end
    end
  end
end
