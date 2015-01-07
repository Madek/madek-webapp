module Permissions
  class FilterSetApiClientPermission < ActiveRecord::Base
    include ::Permissions::Modules::FilterSet
    belongs_to :api_client
  end
end
