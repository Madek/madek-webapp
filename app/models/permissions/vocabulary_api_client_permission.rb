module Permissions
  class VocabularyApiClientPermission < ActiveRecord::Base
    include ::Permissions::Modules::Vocabulary
    belongs_to :api_client
  end
end
