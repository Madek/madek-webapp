module Permissions
  class CollectionGroupPermission < ActiveRecord::Base
    include ::Permissions::Modules::Collection
    belongs_to :group
  end
end
