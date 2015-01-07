module Permissions
  class FilterSetApiClientPermission < ActiveRecord::Base
    include ::Permissions::Modules::FilterSet
    belongs_to :api_client
    define_destroy_ineffective [{ get_metadata_and_previews: false,
                                  edit_metadata_and_filter: false }]
  end
end
