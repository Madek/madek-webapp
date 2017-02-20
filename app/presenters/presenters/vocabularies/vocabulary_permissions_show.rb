module Presenters
  module Vocabularies
    class VocabularyPermissionsShow < \
      Presenters::Shared::Resource::ResourcePermissionsShow

      def url
        prepend_url_context vocabulary_permissions_path(vocab_id: @app_resource)
      end

      def permission_types
        ::Permissions::Modules::Vocabulary::PERMISSION_TYPES
      end

      define_permissions_api Vocabulary
    end
  end
end
