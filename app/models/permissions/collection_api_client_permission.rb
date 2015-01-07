module Permissions
  class CollectionApiClientPermission < ActiveRecord::Base
    include ::Permissions::Modules::Collection
    belongs_to :api_client
  end
end
