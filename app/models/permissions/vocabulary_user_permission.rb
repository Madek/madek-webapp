module Permissions
  class VocabularyUserPermission < ActiveRecord::Base
    include ::Permissions::Modules::Vocabulary
    belongs_to :user
  end
end
