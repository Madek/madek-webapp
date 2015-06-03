class FilterSet < ActiveRecord::Base

  VIEW_PERMISSION_NAME = :get_metadata_and_previews

  include Concerns::MediaResources

end
