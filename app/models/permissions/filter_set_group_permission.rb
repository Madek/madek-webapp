module Permissions
  class FilterSetGroupPermission < ActiveRecord::Base
    include ::Permissions::Modules::FilterSet
    belongs_to :group
  end
end
