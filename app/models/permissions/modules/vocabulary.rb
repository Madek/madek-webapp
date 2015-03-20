module Permissions
  module Modules
    module Vocabulary
      extend ActiveSupport::Concern
      include ::Permissions::Modules::DefineDestroyIneffective
      included do
        belongs_to :vocabulary
        define_destroy_ineffective [{ view: false, use: false }]
      end
      PERMISSION_TYPES = [:view, :use]
    end
  end
end
