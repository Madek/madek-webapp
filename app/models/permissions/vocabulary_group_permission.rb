module Permissions
  class VocabularyGroupPermission < ActiveRecord::Base
    include ::Permissions::Modules::Vocabulary
    belongs_to :group
  end
end
